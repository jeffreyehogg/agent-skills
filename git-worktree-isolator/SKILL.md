---
name: git-worktree-isolator
description: >-
  Creates and manages isolated Git worktree sandboxes for multi-file refactors,
  risky migrations, or parallel branch development without touching the user's
  active working tree. Activates when the user requests worktree isolation, safe
  sandboxing in a dirty repo, or parallel branch execution in the current session.
  DO NOT trigger for read-only tasks, single-file edits, or when delegating to subagents that already specify Workspace: 'share' or 'branch'.
---

# Git Worktree Sandboxing & Isolation

## Overview
When agents perform significant refactorings, test suite runs, or multi-file migrations directly inside the developer's primary working tree, they risk:
1. Overwriting uncommitted local changes.
2. Breaking the developer's active editor environment mid-flow.
3. Leaving dirty git state if a task is abandoned or errors out.

This skill provides an automated, isolated **Git Worktree Sandbox** workflow that allows the agent to build, test, and verify features in an independent directory while the developer continues uninterrupted in the main branch.

> [!TIP]
> **Native Subagent Workspace Alternative:** When delegating work to a subagent via `invoke_subagent`, prefer setting `Workspace: 'share'` (shared git object store, analogous to a worktree) or `Workspace: 'branch'` directly in the tool call. Use this skill ([`./scripts/worktree.sh`](./scripts/worktree.sh)) when executing commands in the **current** session or when persistent branch worktrees are required.

---

## 1. Step-by-Step Instructions

### Step 1: Provision & Hydrate the Worktree via `worktree.sh`
Always use the deterministic helper script [`./scripts/worktree.sh`](./scripts/worktree.sh) rather than raw `git worktree` commands. It automatically resolves the repository root, handles existing branches idempotently, copies `.env*` files, symlinks `node_modules` / `.venv` if present, and prints machine-parseable `KEY=VALUE` output:

```bash
# Create worktree from HEAD (default)
/path/to/git-worktree-isolator/scripts/worktree.sh create feat/user-auth-revamp

# Optional: Carry uncommitted tracked modifications from the primary repo into the worktree
/path/to/git-worktree-isolator/scripts/worktree.sh create feat/user-auth-revamp --carry-dirty
```

Parse the `WORKTREE_PATH=<absolute_path>` line from the script output.

### Step 2: Execute Agent Tasks Inside the Worktree
* **CRITICAL (`run_command` Rule):** **NEVER** run `cd "$WORKTREE_PATH"`. Instead, pass the absolute `WORKTREE_PATH` as the `Cwd` parameter on every `run_command` call, and use absolute paths inside `WORKTREE_PATH` for all `view_file`, `replace_file_content`, and `write_to_file` calls.

### Step 3: Verification & Scoped Commit
Once tests and linter checks pass inside `Cwd: "$WORKTREE_PATH"`:
1. Inspect `git status --short` inside `Cwd: "$WORKTREE_PATH"`.
2. Stage **only** intended source files (avoid blind `git add .` which can sweep up `.audit/`, `SPEC.md`, or `.env` files):
   ```bash
   git add -u
   # Explicitly add any newly created source/test files
   git commit -m "feat(auth): implement token refresh with rate limiting"
   ```
3. Push the branch to the remote if requested.

### Step 4: Safe Teardown
Once work is committed:
```bash
/path/to/git-worktree-isolator/scripts/worktree.sh remove feat/user-auth-revamp
```
*Note: `worktree.sh remove` refuses to delete a worktree with uncommitted or untracked changes (exit code `2`), and automatically unlinks symlinked dependency directories (`node_modules`, `.venv`) before removing the worktree directory. The git branch and all commits remain safely preserved in repository history.*

---

## 2. Safety & Edge-Case Rules
* **Never delete a worktree with uncommitted changes without explicit user consent.** Use `git status` inside `Cwd: "$WORKTREE_PATH"` before teardown.
* **Never alter the primary repository's git stash, index, or working tree.** If `--carry-dirty` is used, `worktree.sh` applies a non-destructive `git diff HEAD` patch into the sandbox without mutating the primary workspace.
* **Merge Conflict Handling:** If rebasing or merging the worktree branch back into `main` produces conflicts, resolve them inside the worktree (`Cwd: "$WORKTREE_PATH"`) and re-run the test suite before fast-forwarding the primary branch.
