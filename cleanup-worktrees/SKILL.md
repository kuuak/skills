---
name: cleanup-worktrees
description: Find a repo's stale git worktrees and sibling checkout folders, prove each one's work has landed, and remove the ones the user approves.
disable-model-invocation: true
argument-hint: [repo path]
---

# cleanup-worktrees

Remove worktrees whose work has **landed**: every commit is on a remote branch or already on the default branch, and no uncommitted change or local-only file goes away with the folder. A removal keeps the branch, so a wrongly removed worktree is one `git worktree add` away; unlanded work is the one thing a removal can lose, and every step below exists to find it.

Run from the main checkout of the repo in `$ARGUMENTS`, or the current one.

## 1. Inventory

`git fetch --prune origin`, then collect every candidate:

- each entry of `git worktree list --porcelain` other than the main checkout. Under `.claude/worktrees/`, `agent-*` folders are subagent worktrees; other names (`hungry-roentgen-303f59`) belong to Claude desktop sessions, which may still be open.
- each folder in the main checkout's parent directory named `<repo>-*`, registered or not. A standalone clone gets the same evidence as a worktree.

A match that is no checkout at all (a `.zip` backup, a plain folder) goes in the report untouched.

**Done when:** every candidate path is listed with its branch or detached HEAD.

## 2. Gather evidence

Record five fields per candidate:

- **dirty**: `git -C <wt> status --porcelain` prints anything.
- **unpushed**: `git -C <wt> rev-list --count HEAD --not --remotes`.
- **PR**: `gh pr list --state all --head <branch> --json number,state,title`. For a detached HEAD, take the issue number from the commit subjects and look up its PR or issue.
- **landed**: proof that unpushed commits are on the default branch. Squash merges rewrite every commit, so `git cherry` and `git rev-list origin/main..<branch>` report merged work as missing; prove it instead with a merged PR, a closed issue, or the change itself on `origin/<default>` (`git grep <text> origin/main -- <path>`, `git show origin/main:<path>`).
- **local files**: `git -C <wt> status --porcelain --ignored` minus build output (`node_modules`, `.next`, caches, `logs/`). Diff each env file (`.env*.local`) against the main checkout's copy; one that differs, or that the main checkout lacks, is local-only.

Add `du -sh <wt>` for the report.

**Done when:** every candidate has all five fields.

## 3. Classify and ask

- **Finished**: clean, every commit pushed or landed, no local-only file, and its PR merged or closed (or no PR and its issue closed). Remove it without asking.
- **Live**: landed, but its PR is still open, or it is a desktop-session worktree. Ask.
- **Holding work**: dirty, an unlanded commit, or a local-only file. Keep it and name exactly what it holds. It goes only on an instruction naming that worktree, after offering to push the commits or copy the files out.

Ask about every live candidate in one multi-select question, one option per group (open PRs, agent worktrees, session worktrees), each stating its evidence and size.

**Done when:** every candidate carries a verdict, and every live one an answer.

## 4. Remove

- `git worktree remove --force <path>`; the force is safe because step 2 already cleared the folder.
- `git branch -D` the local branch of each finished worktree (`-d` refuses squash-merged branches). Branches of open PRs stay, and remote branches stay as they are.
- A removal can unregister the worktree, then stop on `Directory not empty` with files left behind. Confirm `git -C <path> rev-parse --git-dir` now fails, then `rm -rf` the leftover folder.
- `git worktree prune`.

**Done when:** `git worktree list` and a listing of the parent directory show only the main checkout and what was kept.

## 5. Report

A table of path, verdict, evidence and size; the total space freed; the branches kept and why; anything left untouched.
