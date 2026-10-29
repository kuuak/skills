# skills

Claude Code skills for working through GitHub issues with subagents: each issue gets its own worktree and PR, and a fresh-eyes reviewer fixes what is wrong before a human sees it.

- `fix-issues` — fix GitHub issues (ids, or a query like "ready-for-agent in milestone X") in parallel subagents, one worktree and PR per issue, then review, fix, and comment on each PR; add `and merge` to also fix the nits and merge
- `implement-epic` — implement an epic's sub-issues in dependency order on an epic branch (fix, review, fix nits, merge), then review the epic PR and mark it ready
- `review-pr` — review existing PRs in subagents that fix what is wrong and comment their findings
- `merge-dependabot` — batch the open Dependabot PRs into one branch and draft PR, applying minor and patch bumps and asking about each major
- `cleanup-worktrees` — find a repo's stale worktrees and sibling checkout folders, prove each one's work has landed, and remove the ones you approve
- `security-audit` — audit a site's repo and servers (read-only over SSH) for known vulnerabilities in its stack and signs of exploitation, then render the client PDF report and draft the email that carries it
- `security-audit-light` — a passive check-up of a site we built but no longer maintain: findings sorted into OK, to watch and to fix, and a client PDF with numbered actions and estimated hours the client ticks to order

`fix-issues`, `implement-epic`, `review-pr` and `cleanup-worktrees` are user-invoked: run them as `/fix-issues 580 612`, `/implement-epic 42`, `/review-pr 701`, `/cleanup-worktrees`. `merge-dependabot` also triggers on its own when you ask to merge or batch Dependabot updates, or run it as `/merge-dependabot [branch]`. `security-audit` triggers when you ask for a security audit or whether a site is affected by a CVE, or run it as `/security-audit CVE-2026-109618 prod-host staging-host`. `security-audit-light` triggers when you ask for a light audit or security check-up, or run it as `/security-audit-light https://example.ch`; fill in the hourly rate and maintenance plan in its `ESTIMATES.md` first.

## Install

Link each skill folder into `~/.claude/skills/`. `implement-epic` and `review-pr` read the fixer, reviewer, and merger briefs from `fix-issues`, so keep the three side by side; `security-audit-light` reuses `security-audit`'s render script and check sources the same way:

```bash
git clone https://github.com/kuuak/skills.git
mkdir -p ~/.claude/skills
for skill in skills/*/; do ln -sfn "$PWD/$skill" ~/.claude/skills/"$(basename "$skill")"; done
```

The skills drive GitHub through the `gh` CLI, so it needs to be installed and signed in.

## Labels

The subagents track each issue with four labels, created on first run when the repo lacks them: `ready-for-agent` → `in-progress` → `ready-for-review`, and `ready-for-human` when an issue needs a decision only a person can make.

## License

[MIT](LICENSE)
