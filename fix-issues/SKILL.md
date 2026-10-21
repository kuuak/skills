---
name: fix-issues
description: Fix GitHub issues (ids, or a query like "ready-for-agent in milestone X") in parallel subagents, one worktree and PR per issue, then have fresh-eyes subagents review, fix, and comment on each PR.
disable-model-invocation: true
argument-hint: <issue ids | query> [from <branch>]
---

# fix-issues

You are the **orchestrator**. You decide which issues to fix, then run a **pipeline** of subagents: one fixer per issue, and one reviewer per PR the moment its fixer returns. All code is written by the subagents.

The request: `$ARGUMENTS`

## 1. Resolve the issue set

- Issue ids (`580`, `#580 #612`) are the set as given.
- A query becomes `gh issue list --state open` filters: `--label`, `--milestone`, `--assignee`, `--search`.
- The base branch is the one the request names (`from xyz`), else the repo's default branch. Every worktree starts from `origin/<base>` and every PR targets it.

The subagents move each issue through the labels `ready-for-agent` → `in-progress` → `ready-for-review` (PR ready for human review). A fixer that hands back a question instead of a PR uses `ready-for-human` (requires a human). Create whichever of these four the repo lacks (`gh label list`, then `gh label create <name>`).

**Done when:** you hold a list of open issue numbers, a base branch that exists on origin, and all three labels exist.

## 2. Triage

Read each issue with its comments and write its **acceptance criteria**: what must be true for it to close. When an issue only describes a symptom, the criterion is "the symptom no longer reproduces". Flag each issue that is:

- **ambiguous**: a criterion you cannot make checkable. It needs a question for the user.
- **blocked**: another issue that is still open must land first, even one in this set. It sits out this run. Blockers come from two sources: dependencies written in the body or comments ("blocked by #612", "depends on #580"), and GitHub's own "blocked by" relationships, which `gh issue view` omits:

  ```bash
  gh api repos/{owner}/{repo}/issues/<n>/dependencies/blocked_by --jq '.[] | select(.state == "open") | .number'
  ```
- **in-flight**: an open PR already addresses it. It sits out this run.
- **overlapping**: likely to touch the same code as another issue in the set. It still runs; the report plans the merge order.

Show the user a table (issue, title, criteria, flags) plus the base branch, and ask the questions for the ambiguous issues. Wait for their go-ahead when the set came from a query or anything is flagged. A list of explicit ids with nothing flagged goes straight to step 3.

**Done when:** every issue has been checked against both sources of blockers, every issue left in the set has checkable criteria, and the user has approved the plan wherever approval was required.

## 3. Run the pipeline

Run at most **4 subagents at once**, fixers and reviewers combined, unless the user sets another limit: parallel test suites compete for CPU, ports, and databases. Each subagent is `general-purpose` and runs in the background. Each one reads its own brief, `FIXER.md` or `REVIEWER.md`: your prompt hands it the path, and your context stays free for the pipeline.

**Fixer** prompt, one per issue:

- the issue number, the base branch, and the acceptance criteria from triage
- `Read <this skill's base directory>/FIXER.md and follow it.`

When a fixer returns a PR, spawn its **reviewer** right away, before you start queued fixers. Reviewer prompt:

- the PR number, the issue number, and the worktree's absolute path
- `Read <this skill's base directory>/REVIEWER.md and follow it.`

The reviewer's prompt contains exactly those lines and nothing from the fixer's report: it judges the PR against the issue, never against the fixer's intent, and that independence is its whole value.

When a fixer returns a question instead of a PR, record it for the report.

**Done when:** every issue has ended in a reviewed PR or a recorded question.

## 4. Report

Confirm each review comment is on its PR (`gh pr view <pr> --comments`) and every issue with a PR now carries `ready-for-review` and every handed-back issue carries `ready-for-human`; swap any still on `in-progress` yourself, and `gh pr ready` any reviewed PR still in draft. Then give the user one table:

| Issue | PR | Review comment | Fixed | Open | Status |
|-------|----|----------------|-------|------|--------|

Below it, list the open questions per issue, the issues that sat out and why, a suggested merge order for overlapping PRs, and the worktree paths.
