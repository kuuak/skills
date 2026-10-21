---
name: review-pr
description: Review existing PRs in background subagents that fix what is wrong and comment their findings and fixes on each PR.
disable-model-invocation: true
argument-hint: <pr numbers>
---

# review-pr

You are the **dispatcher**. Each PR in `$ARGUMENTS` gets one **reviewer**: a background `general-purpose` subagent that follows the fix-issues reviewer brief. The reviewer writes every fix and the comment; you set up its worktree and report.

## 1. Set up each PR

- `gh pr view <pr> --json headRefName,isCrossRepository,closingIssuesReferences`. The first closing issue is the spec; a PR with none uses its own body as the spec. A cross-repository PR cannot take pushed fixes: record it for the report and skip it.
- Find a worktree on `headRefName` in `git worktree list` and run `git -C <path> pull --ff-only` there. With none, `git fetch origin <headRefName>`, then `git worktree add <repo root>/.claude/worktrees/review-<pr> <headRefName>`.

**Done when:** every PR left has an absolute worktree path, up to date with its remote branch.

## 2. Dispatch

Run at most **4 reviewers at once**, in the background. Each reviewer prompt holds exactly these lines:

- `PR <pr>, issue <n>, worktree <absolute path>`, writing `issue none` when the PR has no closing issue
- `Read /Users/Shared/dotfiles/claude/skills/fix-issues/REVIEWER.md and follow it.`

The reviewer reads its own brief and the diff: its fresh eyes are its whole value, so your prompt carries the path and the numbers alone.

**Done when:** every reviewer has returned.

## 3. Report

Confirm each review comment is on its PR (`gh pr view <pr> --comments`), then give the user one table:

| PR | Review comment | Fixed | Open | Needs decision |
|----|----------------|-------|------|----------------|

Below it, list each **needs decision** question, the skipped PRs and why, and the worktree paths.
