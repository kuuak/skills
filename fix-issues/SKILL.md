---
name: fix-issues
description: Fix GitHub issues (ids, or a query like "ready-for-agent in milestone X") in parallel subagents, one worktree and PR per issue, then have fresh-eyes subagents review, fix, and comment on each PR, and optionally fix the nits and merge.
disable-model-invocation: true
argument-hint: <issue ids | query> [from <branch>] [and merge]
---

# fix-issues

You are the **orchestrator**. You decide which issues to fix, then run a **pipeline** of subagents: one fixer per issue, one reviewer per PR the moment its fixer returns, and, in a **merging run**, one merger per reviewed PR. All code is written by the subagents.

The request: `$ARGUMENTS`

## 1. Resolve the issue set

- Issue ids (`580`, `#580 #612`) are the set as given.
- A query becomes `gh issue list --state open` filters: `--label`, `--milestone`, `--assignee`, `--search`.
- The base branch is the one the request names (`from xyz`), else the repo's default branch. Every worktree starts from `origin/<base>` and every PR targets it.
- The run is a **merging run** when the request asks for it (`and merge`, "merge them"). Otherwise it ends at reviewed PRs for a human to merge.

The subagents move each issue through the labels `ready-for-agent` → `in-progress` → `ready-for-review` (PR ready for human review) → closed once merged, in a merging run. A subagent that hands back a question instead of a PR or a merge uses `ready-for-human` (requires a human). Create whichever of these four the repo lacks (`gh label list`, then `gh label create <name>`).

**Done when:** you hold a list of open issue numbers, a base branch that exists on origin, and all four labels exist.

## 2. Triage

Read each issue with its comments (`gh issue view <n> --json title,body,labels,comments`) and write its **acceptance criteria**: what must be true for it to close. When an issue only describes a symptom, the criterion is "the symptom no longer reproduces". Flag each issue that is:

- **ambiguous**: a criterion you cannot make checkable. It needs a question for the user.
- **blocked**: another issue that is still open must land first, even one in this set. It sits out this run. Blockers come from two sources: dependencies written in the body or comments ("blocked by #612", "depends on #580"), and GitHub's own "blocked by" relationships, which `gh issue view` omits:

  ```bash
  gh api repos/{owner}/{repo}/issues/<n>/dependencies/blocked_by --jq '.[] | select(.state == "open") | .number'
  ```
- **in-flight**: an open PR already addresses it. It sits out this run.
- **overlapping**: likely to touch the same code as another issue in the set. It still runs; the report plans the merge order.

Show the user a table (issue, title, criteria, flags) plus the base branch and whether the run merges, and ask the questions for the ambiguous issues. Wait for their go-ahead when the set came from a query, anything is flagged, or the run merges: a merging run lands on the base without asking again. A non-merging list of explicit ids with nothing flagged goes straight to step 3.

**Done when:** every issue has been checked against both sources of blockers, every issue left in the set has checkable criteria, and the user has approved the plan wherever approval was required.

## 3. Run the pipeline

Run at most **4 subagents at once**, all roles combined, unless the user sets another limit: parallel test suites compete for CPU, ports, and databases. When a slot frees, fill it in this priority: merger, reviewer, fixer. Each subagent is `general-purpose` and runs in the background. Each one reads its own brief, `FIXER.md`, `REVIEWER.md`, or `MERGER.md`: your prompt hands it the path, and your context stays free for the pipeline.

**Fixer** prompt, one per issue:

- the issue number, the base branch, and the acceptance criteria from triage
- `Read <this skill's base directory>/FIXER.md and follow it.`

When a fixer returns a PR, spawn its **reviewer** right away, before you start queued fixers. Reviewer prompt:

- the PR number, the issue number, and the worktree's absolute path
- `Read <this skill's base directory>/REVIEWER.md and follow it.`

The reviewer's prompt contains exactly those lines and nothing from the fixer's report: it judges the PR against the issue, never against the fixer's intent, and that independence is its whole value.

In a merging run, spawn a **merger** when a reviewer returns verdict `ready to merge` with nothing held back. Mergers run one at a time, the **merge lane**: each one updates its branch against a base no other merger is moving. Overlapping PRs take the lane in the order triage planned; the rest in the order their reviews finish. Merger prompt:

- `PR <pr>, issue <n>, worktree <absolute path>`
- `Read <this skill's base directory>/MERGER.md and follow it.`

A merger returning `blocked by branch protection` or `merge not permitted` closes the merge lane: every later merge would hit the same rule, so the remaining reviewed PRs wait for the user.

When a fixer returns a question, a reviewer returns anything needing a decision, or a merger hands back, record it for the report.

**Done when:** every issue has ended in a reviewed PR (merged, in a merging run with the lane open) or a recorded question.

## 4. Report

Confirm each review comment is on its PR (`gh pr view <pr> --comments`), every merged issue is closed, every other issue with a PR carries `ready-for-review`, and every handed-back issue carries `ready-for-human`; swap any still on `in-progress` yourself, and `gh pr ready` any reviewed PR still in draft. Then give the user the report, decisions first:

1. **Decisions**: every fixer question, review finding needing a decision, security finding held back, and merger hand-back, numbered so the user can answer by number. Write each as the decision, its options, and your recommendation. Leave the section out when there are none.
2. One table:

   | Issue | PR | Review comment | Fixed | Open | Status |
   |-------|----|----------------|-------|------|--------|

3. The issues that sat out and why, a merge order for the overlapping PRs still open, and the worktree paths still on disk.
