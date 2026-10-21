---
name: implement-epic
description: Implement every sub-issue of a GitHub epic in dependency order on an epic branch (fixer, reviewer, and merger subagents per sub-issue), then review the epic PR and mark it ready once every sub-issue has landed.
disable-model-invocation: true
argument-hint: <epic issue> [from <branch>]
---

# implement-epic

You are the **orchestrator**. You turn an epic into an ordered set of sub-issues, then run a **pipeline** of subagents per sub-issue: a **fixer** opens a PR, a **reviewer** fixes what is wrong, a **merger** fixes the nits worth fixing, merges, and closes the sub-issue. Every sub-issue PR targets the **epic branch**. The work reaches the base branch through one **epic PR**: a draft until every sub-issue has landed, then reviewed as a whole and marked ready for a human to merge. All code is written by the subagents. Your context holds one status line per sub-issue and nothing else: you never read a diff, a log, or a file the subagents touch.

The request: `$ARGUMENTS`

## 1. Resolve the epic

- `gh issue view <epic> --comments`.
- The sub-issues are the union of GitHub's sub-issues and the issues the epic's task list references (`- [ ] #612`):

  ```bash
  gh api repos/{owner}/{repo}/issues/<epic>/sub_issues --paginate --jq '.[] | "\(.number) \(.state) \(.title)"'
  ```

  A sub-issue with sub-issues of its own is expanded into its leaves. Closed sub-issues are already done.
- The **base branch** is the one the request names (`from xyz`), else the repo's default branch. It is where the epic PR lands.

The subagents move each sub-issue through the labels `ready-for-agent` → `in-progress` → `ready-for-review` → closed once merged into the epic branch, with `ready-for-human` for a sub-issue handed back. The epic itself carries `in-progress` while the run works on it. Create whichever of these four the repo lacks (`gh label list`, then `gh label create <name>`).

**Done when:** you hold every open sub-issue number, a base branch that exists on origin, and all four labels exist.

## 2. Find or create the epic branch

The epic branch is the epic's linked development branch, `epic/<epic>-<slug>`. Look for one already there:

```bash
gh issue develop --list <epic>
git ls-remote --heads origin 'epic/<epic>-*'
```

- One found: use it, and `git fetch origin <epic branch>`.
- Several found: ask the user which one.
- None: create it from the base, linked to the epic so it shows in the issue's Development panel:

  ```bash
  gh issue develop <epic> --base <base> --name epic/<epic>-<slug>
  ```

Then look for the epic PR from an earlier run: `gh pr list --head <epic branch> --base <base> --state open --json number,isDraft`.

**Done when:** the epic branch exists on origin and is linked to the epic, and you know whether the epic PR is already open.

## 3. Triage and order

Read each open sub-issue with its comments and write its **acceptance criteria**: what must be true for it to close. When a sub-issue only describes a symptom, the criterion is "the symptom no longer reproduces".

Then build the **order**: for each sub-issue, the sub-issues that must land on the epic branch before it starts.

- **Dependencies** come from two sources: links written in the body or comments ("blocked by #612", "depends on #580"), and GitHub's "blocked by" relationships, which `gh issue view` omits:

  ```bash
  gh api repos/{owner}/{repo}/issues/<n>/dependencies/blocked_by --jq '.[] | select(.state == "open") | .number'
  ```

  A blocker inside the epic is an ordering edge. A blocker outside the epic that is still open makes the sub-issue **sit out**, along with everything ordered after it.
- **Overlap**: two sub-issues likely to touch the same code get an edge too, the earlier one in the epic's order first, so their PRs never race to merge.
- **Resume**: an earlier run leaves open PRs against the epic branch (`gh pr list --base <epic branch> --state open --json number,headRefName,closingIssuesReferences`). Each enters the pipeline at its stage: at the merger when it carries an `## Automated review` comment with verdict `ready to merge`, else at the reviewer. Its worktree is the one on its `headRefName` in `git worktree list`, else `git worktree add <repo root>/.claude/worktrees/review-<pr> <headRefName>` after `git fetch origin <headRefName>`. A sub-issue already on `ready-for-human` sits out.
- **Ambiguous**: a criterion you cannot make checkable needs a question for the user.

Show the user one table (order, sub-issue, title, criteria, after, flags) plus the epic branch and the base, ask the questions for the ambiguous sub-issues, and wait for their go-ahead: the run merges into the epic branch without asking again. On the go-ahead, `gh issue edit <epic> --add-label in-progress --remove-label ready-for-human`.

**Done when:** every open sub-issue has checkable criteria or sits out with a reason, the order has no cycle, and the user has approved the plan.

## 4. Run the pipeline

A sub-issue is **ready** when everything ordered before it has landed on the epic branch. Run at most **4 subagents at once** unless the user sets another limit: parallel test suites compete for CPU, ports, and databases. When a slot frees, fill it in this priority: merger, reviewer, fixer. Finishing a sub-issue unblocks its dependents; starting one does not.

Each subagent is `general-purpose` and runs in the background, and each reads its own brief: your prompt hands it the path and the numbers, so its context starts with only its own sub-issue.

**Fixer**, one per ready sub-issue. The epic branch is its base branch: its worktree starts from `origin/<epic branch>` and its PR targets the epic branch.

- the issue number, `base branch <epic branch>`, and the acceptance criteria from triage
- `Read /Users/Shared/dotfiles/claude/skills/fix-issues/FIXER.md and follow it.`

**Reviewer**, the moment a fixer returns a PR:

- `PR <pr>, issue <n>, worktree <absolute path>`
- `Read /Users/Shared/dotfiles/claude/skills/fix-issues/REVIEWER.md and follow it.`

The reviewer prompt holds exactly those lines and nothing from the fixer's report: it judges the PR against the issue, never against the fixer's intent.

**Merger**, when a reviewer returns with nothing needing a decision. Mergers run one at a time, the **merge lane**: each one updates its branch against an epic branch no other merger is moving.

- `PR <pr>, issue <n>, worktree <absolute path>`
- `Read <this skill's base directory>/MERGER.md and follow it.`

When the first merger returns `merged` and no epic PR is open, open it as a draft:

```bash
gh pr create --draft --base <base> --head <epic branch> --title "<epic title>" --body "Closes #<epic>"
```

It stays a draft through the rest of the run: only the epic review in step 5 marks it ready.

A sub-issue **stalls** when its fixer returns a question, its reviewer returns anything needing a decision, or its merger hands back. Everything ordered after a stalled sub-issue stalls with it; the rest of the epic keeps running. A merger that reports the merge blocked by branch protection closes the merge lane for the whole run: every later merge would hit the same rule, so finish the reviews already in flight and go to step 6.

Keep one line per sub-issue (stage, PR, outcome) as the subagents return.

**Done when:** every sub-issue has landed on the epic branch, stalled with a recorded reason, or sat out.

## 5. Review the epic PR

Run this step only when every sub-issue of the epic is closed; otherwise the epic PR stays a draft and you go to step 6.

Set up a worktree on the epic branch: the one on it in `git worktree list`, else `git worktree add <repo root>/.claude/worktrees/epic-<epic> <epic branch>`. Then spawn one more reviewer, in the background, with exactly these lines:

- `PR <epic pr>, issue <epic>, worktree <absolute path>`
- `Read /Users/Shared/dotfiles/claude/skills/fix-issues/REVIEWER.md and follow it.`

It reviews the integrated work against the epic, pushes its fixes onto the epic branch, comments its findings, and marks the epic PR ready as its last act, so the PR turns ready exactly when the review is finished. Nothing else writes to the epic branch while it runs.

**Done when:** the epic reviewer has returned, and the epic PR is ready with its review comment, or a sub-issue is still open and the PR is a draft.

## 6. Report

Write the report: one table, then each stalled sub-issue with its question and what stalled behind it, the sub-issues that sat out and why, the epic review's findings needing a decision, and the worktree paths still on disk.

| Order | Sub-issue | PR | Fixed in review | Nits fixed | Status |
|-------|-----------|----|-----------------|------------|--------|

Put it in the epic PR's body below `Closes #<epic>` (`gh pr edit <epic pr> --body-file <file>`), and post it on the epic (`gh issue comment <epic> --body-file <file>`). `Closes` only fires on merges into the default branch: with any other base, the report says the epic needs closing by hand once its PR merges.

Confirm every landed sub-issue is closed and every stalled one carries `ready-for-human`; fix any label still on `in-progress` yourself. The epic ends on `ready-for-review` after its review, or on `ready-for-human` when a sub-issue is stalled or the review left a decision open.

**Done when:** the report is in the epic PR's body and on the epic, every label matches its sub-issue's outcome, and the user has the same report with the epic PR's URL and whether it is ready or still a draft.
