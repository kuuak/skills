# skills

Claude Code skills for working through GitHub issues with subagents: each issue gets its own worktree and PR, and a fresh-eyes reviewer fixes what is wrong before a human sees it.

- `fix-issues` — fix GitHub issues (ids, or a query like "ready-for-agent in milestone X") in parallel subagents, one worktree and PR per issue, then review, fix, and comment on each PR
- `implement-epic` — implement an epic's sub-issues in dependency order on an epic branch (fix, review, fix nits, merge), then review the epic PR and mark it ready
- `review-pr` — review existing PRs in subagents that fix what is wrong and comment their findings

All three are user-invoked: run them as `/fix-issues 580 612`, `/implement-epic 42`, `/review-pr 701`.

## Install

Link each skill folder into `~/.claude/skills/`. `implement-epic` and `review-pr` read the fixer and reviewer briefs from `fix-issues`, so keep the three side by side:

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
