# skills

Claude Code skills for working through tickets (GitHub issues) with subagents: each ticket gets its own worktree and PR, and a fresh-eyes reviewer fixes what is wrong before a human sees it.

- `implement-tickets` — implement tickets, whether bugs, features or chores (GitHub issue ids, or a query like "ready-for-agent in milestone X"), in parallel subagents, one worktree and PR per ticket, then review, fix, and comment on each PR; add `and merge` to also fix the nits and merge
- `implement-epic` — implement an epic's sub-issues in dependency order on an epic branch (implement, review, fix nits, merge), then review the epic PR and mark it ready
- `review-pr` — review existing PRs in subagents that fix what is wrong and comment their findings
- `merge-dependabot` — batch the open Dependabot PRs into one branch and draft PR, applying minor and patch bumps and asking about each major
- `git-cleanup` — find a repo's stale worktrees, sibling checkout folders, branches and stashes, prove each one's work has landed or is obsolete, and remove the ones you approve
- `security-audit` — audit a site's repo and servers (read-only over SSH) for known vulnerabilities in its stack and signs of exploitation, then render the client PDF report and draft the email that carries it
- `security-audit-light` — a passive check-up of a site we built but no longer maintain: findings sorted into OK, to watch and to fix, and a client PDF with numbered actions and estimated hours the client ticks to order

`implement-tickets`, `implement-epic`, `review-pr` and `git-cleanup` are user-invoked: run them as `/implement-tickets 580 612`, `/implement-epic 42`, `/review-pr 701`, `/git-cleanup` (or `/git-cleanup branches stashes` to skip the worktrees). `merge-dependabot` also triggers on its own when you ask to merge or batch Dependabot updates, or run it as `/merge-dependabot [branch]`. `security-audit` triggers when you ask for a security audit or whether a site is affected by a CVE, or run it as `/security-audit CVE-2026-109618 prod-host staging-host`; add `--v1-layout` to build a new report in the earlier blue layout, to match one already delivered. `security-audit-light` triggers when you ask for a light audit or security check-up, or run it as `/security-audit-light https://example.ch`; fill in the hourly rate and maintenance plan in its `ESTIMATES.md` first.

## Install

Link each skill folder into `~/.claude/skills/`. `implement-epic` and `review-pr` read the implementer, reviewer, and merger briefs from `implement-tickets`, so keep the three side by side; `security-audit-light` reuses `security-audit`'s render script and check sources the same way:

```bash
git clone https://github.com/kuuak/skills.git
mkdir -p ~/.claude/skills
for skill in skills/*/; do ln -sfn "$PWD/$skill" ~/.claude/skills/"$(basename "$skill")"; done
```

`implement-tickets` was called `fix-issues` until November 2026. If you linked it under the old name, remove that link with `rm ~/.claude/skills/fix-issues`, then run the loop above again to link `implement-tickets`: `implement-epic` and `review-pr` read their briefs from `~/.claude/skills/implement-tickets/`.

The skills drive GitHub through the `gh` CLI, so it needs to be installed and signed in.

## Labels

The subagents track each ticket with four labels, created on first run when the repo lacks them: `ready-for-agent` → `in-progress` → `ready-for-review`, and `ready-for-human` when a ticket needs a decision only a person can make.

## License

[MIT](LICENSE)
