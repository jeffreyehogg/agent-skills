#!/usr/bin/env bash
# ==============================================================================
# worktree.sh
# Deterministic helper to manage isolated Git worktrees for agent tasks.
# ==============================================================================

set -euo pipefail

COMMAND="${1:-list}"
BRANCH="${2:-}"
WORKTREES_ROOT="../.worktrees"

case "$COMMAND" in
  create)
    if [ -z "$BRANCH" ]; then
      echo "Error: Missing branch name. Usage: $0 create <branch-name>"
      exit 1
    fi
    SAFE_DIR_NAME="${BRANCH//\//-}"
    TARGET_PATH="$WORKTREES_ROOT/$SAFE_DIR_NAME"

    echo "Creating worktree at $TARGET_PATH for branch '$BRANCH'..."
    mkdir -p "$WORKTREES_ROOT"
    git worktree add -b "$BRANCH" "$TARGET_PATH" HEAD

    # Copy local env files if present
    for envfile in .env .env.local .env.development; do
      if [ -f "$envfile" ]; then
        cp "$envfile" "$TARGET_PATH/$envfile"
        echo "Copied $envfile to worktree"
      fi
    done

    echo "✓ Worktree created successfully at: $TARGET_PATH"
    ;;

  list)
    echo "=== Active Git Worktrees ==="
    git worktree list
    ;;

  remove)
    if [ -z "$BRANCH" ]; then
      echo "Error: Missing branch name. Usage: $0 remove <branch-name>"
      exit 1
    fi
    SAFE_DIR_NAME="${BRANCH//\//-}"
    TARGET_PATH="$WORKTREES_ROOT/$SAFE_DIR_NAME"

    echo "Removing worktree at $TARGET_PATH..."
    git worktree remove "$TARGET_PATH"
    git worktree prune
    echo "✓ Worktree removed. Git branch '$BRANCH' remains intact."
    ;;

  prune)
    echo "Pruning stale worktrees..."
    git worktree prune -v
    ;;

  *)
    echo "Usage: $0 {create <branch> | list | remove <branch> | prune}"
    exit 1
    ;;
esac
