---
name: git-cleanup
description: Find a repo's stale git worktrees, branches and stashes, prove each one's work has landed or is obsolete, and remove the ones the user approves.
disable-model-invocation: true
argument-hint: [repo path] [worktrees|branches|stashes]
---

# git-cleanup

Remove what has **landed**: every commit is on the default branch or on a remote branch that stays, and no uncommitted change, local-only file or stashed idea goes away with it. Unlanded work is the one thing a cleanup can lose, and every step below exists to find it.

Run from the main checkout of the repo in `$ARGUMENTS`, or the current one. Kinds named in `$ARGUMENTS` limit the run to them; with none, clean all three, in the order worktrees, branches, stashes (a branch checked out in a worktree cannot be deleted until the worktree goes).

## 1. Inventory

`git fetch --prune origin`, then collect every candidate:

- **Worktrees**: each entry of `git worktree list --porcelain` other than the main checkout. Under `.claude/worktrees/`, `agent-*` folders are subagent worktrees; other names (`hungry-roentgen-303f59`) belong to Claude desktop sessions, which may still be open. Add each folder in the main checkout's parent directory named `<repo>-*`, registered or not; a standalone clone gets the same evidence as a worktree. A match that is no checkout at all (a `.zip` backup, a plain folder) goes in the report untouched.
- **Branches**: local branches (`git for-each-ref refs/heads`) and remote ones (`refs/remotes/origin`). The default branch, protected branches (`gh api --paginate 'repos/{owner}/{repo}/branches?protected=true' --jq '.[].name'`), long-lived ones (`develop`, `staging`, `release/*`, a milestone's dev branch) and `dependabot/*` are owned elsewhere: list them as kept and gather nothing more.
- **Stashes**: `git stash list --format='%gd|%H|%ci|%gs'`. Record each stash's SHA: indexes shift as stashes are dropped, the SHA does not.

**Done when:** every candidate is listed with its kind, and its branch or detached HEAD (worktree), upstream (branch), or SHA, date and message (stash).

## 2. Gather evidence

**Worktrees and branches** share the landed test. Record per candidate:

- **dirty** (worktrees): `git -C <wt> status --porcelain` prints anything.
- **unpushed**: `git rev-list --count <ref> --not --remotes`. A local branch whose upstream shows `[gone]` lost its remote copy: its commits count as unpushed until proven landed.
- **ahead**: `git rev-list --count origin/<default>..<ref>`. Zero means every commit is in the default branch's history.
- **PR**: `gh pr list --state all --head <branch> --json number,state,title,headRefOid`. A merged PR covers only the commits up to its `headRefOid`: when `git rev-list --count <headRefOid>..<ref>` is not zero, the commits made after the merge need their own landed proof. For a detached HEAD, or a branch with no PR, take the issue number from the branch name or commit subjects and look up its issue and how it closed.
- **landed**: proof that commits ahead of the default branch are on it. Squash merges rewrite every commit, so `git cherry` and `ahead` report merged work as missing; prove it instead with a merged PR, an issue closed as completed (`gh issue view <n> --json state,stateReason`; one closed as not planned proves nothing), or the change itself on `origin/<default>` (`git diff <ref> origin/<default> -- <files the branch changed>` prints nothing, `git grep <text> origin/<default> -- <path>`).
- **local files** (worktrees): `git -C <wt> status --porcelain --ignored` minus build output (`node_modules`, `.next`, caches, `logs/`). Diff each env file (`.env*.local`) against the main checkout's copy; one that differs, or that the main checkout lacks, is local-only.
- **size** (worktrees): `du -sh <wt>`.

**Stashes** have no PR to prove them; the question is whether the default branch has made each one **obsolete**. Record:

- **base**: `git log -1 --format='%h %ci %s' <sha>^1`, and the branch named in its message.
- **files**: `git stash show --stat --include-untracked <sha>`. Untracked files live in `<sha>^3`; read them with `git show <sha>^3:<path>`.
- **on default**: whether each touched path still exists on `origin/<default>`, and whether the stash's distinctive added lines or feature (a component name, a string, a script) appear there (`git grep`).
- **obsolete or holding**: obsolete when the default branch has the change or has replaced the code it touched with an equivalent; holding when the feature it carries exists nowhere else. Say what the feature is in one line.

**Done when:** every worktree and branch has all its fields, and every stash a one-line summary and an obsolete-or-holding call backed by what `origin/<default>` contains.

## 3. Classify and ask

- **Finished**: landed with nothing local left, and its PR merged or closed (or no PR, and ahead is zero or its issue closed as completed). Finished worktrees and local branches go without asking. A finished remote branch is asked about, since deleting it changes the shared repo.
- **Live**: landed, but its PR is still open, or it is a desktop-session worktree. Branches of open PRs stay; live worktrees are asked about.
- **Abandoned**: unlanded, and its PR was closed unmerged or its issue closed as not planned. Ask, naming the commits that go with it.
- **Obsolete** (stashes): ask.
- **Holding work**: dirty, an unlanded commit, a local-only file, or a holding stash. Keep it and name exactly what it holds. Offer to save it: push the commits, copy the files out, or turn a stash into a branch (step 4) or an issue that follows the repo's issue conventions. It goes only on an instruction naming it.

Ask in one multi-select question, one option per group (live worktrees, finished remote branches, abandoned branches, obsolete stashes), each stating its count, evidence and size. Count from the names listed in step 1, so the number in the question is the number deleted.

**Done when:** every candidate carries a verdict, and every asked one an answer.

## 4. Remove

Act only on names from step 1. Branches and stashes created while this ran belong to someone else's work; list them as kept.

- **Worktrees**: `git worktree remove --force <path>`; the force is safe because step 2 already cleared the folder. A removal can unregister the worktree, then stop on `Directory not empty` with files left behind: confirm `git -C <path> rev-parse --git-dir` now fails, then `rm -rf` the leftover folder. Then `git worktree prune`.
- **Local branches**: `git branch -D <names>` (`-d` refuses squash-merged branches). Record each tip SHA first, for the report.
- **Remote branches**: `git push origin --delete <names>`.
- **Stashes**: resolve each approved SHA to its current `stash@{n}`, then `git stash drop` them from the highest index down. To save a holding stash as a branch without touching the main checkout: `git worktree add -b <name> <tmp> <sha>^1`, `git -C <tmp> stash apply <sha>`, `git -C <tmp> add -A` (the stash's untracked files come back untracked), commit, push, remove the worktree, then drop the stash.

**Done when:** `git worktree list`, `git branch -a` and `git stash list` show only the main checkout and what was kept.

## 5. Report

One table per kind: name, verdict, evidence, and size (worktrees). Then the total space freed; the SHA of each deleted branch and stash, which restores it while git still holds the object (`git branch <name> <sha>`, `git stash store -m <message> <sha>`); what was kept and why; anything left untouched.
