#!/usr/bin/env bash
# ==============================================================================
# worktree.sh
# Deterministic helper to manage isolated Git worktrees for agent tasks.
# ==============================================================================

set -euo pipefail

COMMAND="${1:-list}"
BRANCH="${2:-}"
FLAG="${3:-}"

if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "STATUS=ERROR"
  echo "ERROR_CODE=NOT_A_GIT_REPO"
  echo "MESSAGE=Current directory is not inside a Git repository."
  exit 1
fi

REPO_NAME="$(basename "$REPO_ROOT")"
WORKTREES_ROOT="$(cd "$(dirname "$REPO_ROOT")" && pwd)/.${REPO_NAME}-worktrees"

case "$COMMAND" in
  create)
    if [ -z "$BRANCH" ]; then
      echo "STATUS=ERROR"
      echo "ERROR_CODE=MISSING_BRANCH"
      echo "MESSAGE=Usage: $0 create <branch-name> [--carry-dirty]"
      exit 1
    fi
    SAFE_DIR_NAME="${BRANCH//\//-}"
    TARGET_PATH="$WORKTREES_ROOT/$SAFE_DIR_NAME"

    mkdir -p "$WORKTREES_ROOT"

    if [ -d "$TARGET_PATH/.git" ] || [ -f "$TARGET_PATH/.git" ]; then
      echo "INFO=Reusing existing worktree at $TARGET_PATH"
    elif git -C "$REPO_ROOT" show-ref --verify --quiet "refs/heads/$BRANCH"; then
      git -C "$REPO_ROOT" worktree add "$TARGET_PATH" "$BRANCH" >/dev/null
    else
      git -C "$REPO_ROOT" worktree add -b "$BRANCH" "$TARGET_PATH" HEAD >/dev/null
    fi

    # Optionally carry over uncommitted tracked diffs without touching primary tree
    if [ "$FLAG" = "--carry-dirty" ]; then
      if ! git -C "$REPO_ROOT" diff --quiet HEAD; then
        git -C "$REPO_ROOT" diff HEAD | git -C "$TARGET_PATH" apply -
        echo "DIRTY_PATCH_APPLIED=true"
      fi
    fi

    # Copy local env files if present
    for envfile in .env .env.local .env.development .env.test; do
      if [ -f "$REPO_ROOT/$envfile" ] && [ ! -f "$TARGET_PATH/$envfile" ]; then
        cp "$REPO_ROOT/$envfile" "$TARGET_PATH/$envfile"
        echo "ENV_COPIED=$envfile"
      fi
    done

    # Symlink heavy dependency directories if present and missing in worktree
    for depdir in node_modules .venv; do
      if [ -d "$REPO_ROOT/$depdir" ] && [ ! -e "$TARGET_PATH/$depdir" ]; then
        ln -s "$REPO_ROOT/$depdir" "$TARGET_PATH/$depdir"
        echo "DEP_LINKED=$depdir"
      fi
    done

    echo "STATUS=OK"
    echo "BRANCH=$BRANCH"
    echo "WORKTREE_PATH=$TARGET_PATH"
    ;;

  list)
    echo "STATUS=OK"
    git -C "$REPO_ROOT" worktree list --porcelain
    ;;

  remove)
    if [ -z "$BRANCH" ]; then
      echo "STATUS=ERROR"
      echo "ERROR_CODE=MISSING_BRANCH"
      echo "MESSAGE=Usage: $0 remove <branch-name> [--force]"
      exit 1
    fi
    SAFE_DIR_NAME="${BRANCH//\//-}"
    TARGET_PATH="$WORKTREES_ROOT/$SAFE_DIR_NAME"

    if [ ! -e "$TARGET_PATH" ]; then
      echo "STATUS=OK"
      echo "MESSAGE=Worktree already absent: $TARGET_PATH"
      exit 0
    fi

    # Remove symlinked dependency folders first so git status / worktree remove is clean
    for depdir in node_modules .venv; do
      if [ -L "$TARGET_PATH/$depdir" ]; then
        rm "$TARGET_PATH/$depdir"
      fi
    done

    # Guard against uncommitted changes unless --force is explicitly passed
    if [ "$FLAG" != "--force" ] && [ -n "$(git -C "$TARGET_PATH" status --porcelain 2>/dev/null)" ]; then
      # Re-link dependencies if we aborted removal
      for depdir in node_modules .venv; do
        if [ -d "$REPO_ROOT/$depdir" ] && [ ! -e "$TARGET_PATH/$depdir" ]; then
          ln -s "$REPO_ROOT/$depdir" "$TARGET_PATH/$depdir"
        fi
      done
      echo "STATUS=ERROR"
      echo "ERROR_CODE=DIRTY_WORKTREE"
      echo "WORKTREE_PATH=$TARGET_PATH"
      echo "MESSAGE=Worktree has uncommitted or untracked changes. Commit, clean, or pass --force."
      exit 2
    fi

    if [ "$FLAG" = "--force" ]; then
      git -C "$REPO_ROOT" worktree remove --force "$TARGET_PATH"
    else
      git -C "$REPO_ROOT" worktree remove "$TARGET_PATH"
    fi
    git -C "$REPO_ROOT" worktree prune
    echo "STATUS=OK"
    echo "REMOVED_PATH=$TARGET_PATH"
    echo "BRANCH_PRESERVED=$BRANCH"
    ;;

  prune)
    git -C "$REPO_ROOT" worktree prune -v
    echo "STATUS=OK"
    ;;

  *)
    echo "STATUS=ERROR"
    echo "ERROR_CODE=UNKNOWN_COMMAND"
    echo "MESSAGE=Usage: $0 {create <branch> [--carry-dirty] | list | remove <branch> [--force] | prune}"
    exit 1
    ;;
esac
