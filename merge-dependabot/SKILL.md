---
name: merge-dependabot
description: Batch-apply open Dependabot PRs into a single branch. Handles npm, GitHub Actions, Composer, and other ecosystems. Applies minor/patch automatically; asks for confirmation on majors. Use when user says "merge dependabot PRs", "apply dependabot updates", "batch dependabot", "combine dependabot", or "squash dependabot PRs".
---

# merge-dependabot

Batch all open Dependabot PRs into a single branch, classifying each update by semver bump type and asking for confirmation on anything major or breaking.

## Arguments

```
/merge-dependabot [branch-name]
```

- `branch-name` — target branch (default: `chore/dependabot-updates`)

## Phase 1 — Preflight

1. Confirm you are inside a git repository.
2. Detect the base branch:
   ```bash
   git remote show origin | grep 'HEAD branch' | awk '{print $NF}'
   ```
3. Check if `branch-name` already exists locally or remotely:
   ```bash
   git branch --list <branch-name>
   git ls-remote --heads origin <branch-name>
   ```
   **If it exists → abort.** Tell the user which branch exists and ask them to either delete it or supply a different name via `/merge-dependabot <new-branch>`.

## Phase 2 — Enumerate and classify

Fetch all open Dependabot PRs:

```bash
gh pr list --author "app/dependabot" --state open \
  --json number,title,headRefName,baseRefName,labels
```

For each PR, extract the version bump from the title (standard format: `bump <pkg> from <old> to <new>` — some PRs list multiple packages; extract all pairs).

**Semver classification rule:**

Given `old` → `new`:
1. Parse both as `MAJOR.MINOR.PATCH` (strip leading `v` if present).
2. If `MAJOR` changes → **major**.
3. If `MAJOR` is the same and `MINOR` changes → **minor**.
4. If both are the same and only `PATCH` changes → **patch**.

For packages at `0.x.y`: treat a `MINOR` bump as **major** (breaking changes are common in pre-1.0 packages).

**Ecosystem detection** from `headRefName`:
- `dependabot/npm_and_yarn/…` → npm
- `dependabot/github_actions/…` → GitHub Actions
- `dependabot/composer/…` → Composer
- `dependabot/pip/…` or `dependabot/poetry/…` → pip
- Anything else → generic (cherry-pick strategy)

**Output a classification table** before doing anything:

| PR | Package(s) | Old → New | Type | Ecosystem |
|----|-----------|-----------|------|-----------|
| #n | name | x.y.z → a.b.c | patch/minor/major | npm |

## Phase 3 — Confirm majors

For each **major** bump, ask the user one at a time with the following context:

- The exact version change
- A one-sentence summary of what changed (check the PR body for release notes / breaking change callouts)
- Your recommendation (skip or include)

Wait for a yes/no answer before moving on to the next major. If approved, it will land in the same branch as the minor/patch updates.

## Phase 4 — Create the branch

```bash
git checkout -b <branch-name> <base-branch>
```

## Phase 5 — Apply updates

Apply all confirmed PRs (minor + patch + approved majors). Strategy varies by ecosystem.

### npm / yarn

The key insight: dependabot branches are often **stale** — they were cut from an older base commit and carry a large diff of unrelated work. **Never merge or cherry-pick the full branch.** Extract only the dependency changes.

**Step 1 — Identify direct dep changes** (changes to `package.json` / `yarn.lock` that touch the `dependencies`/`devDependencies`/`overrides` fields):

```bash
git diff $(git merge-base <base> origin/<dep-branch>) origin/<dep-branch> -- package.json
```

If the diff touches `package.json`, apply that change to the working tree manually (edit the version string).

**Step 2 — Identify transitive-only changes** (only `package-lock.json` / `yarn.lock` changed, `package.json` unchanged):

Collect the package names from the PR title. Then:

```bash
npm update <pkg1> <pkg2> ... --package-lock-only
```

Or for yarn:

```bash
yarn upgrade <pkg1> <pkg2> ...
```

**Sub-projects** (e.g., `/wordpress`, `/backend`): apply the same logic per sub-project directory, running the update command in that directory.

If a dependabot PR removes a package (e.g., `serialize-javascript` removed when it was no longer needed by an updated dependency), verify after `npm update` that the package is gone from the lock file:

```bash
node -e "const l=require('./package-lock.json'); console.log(l.packages['node_modules/<pkg>']?.version ?? 'removed');"
```

### GitHub Actions

Actions bumps only touch `.github/workflows/*.yml`. Extract the diff cleanly:

```bash
git diff $(git merge-base <base> origin/<dep-branch>) origin/<dep-branch> -- .github/workflows/
```

Apply the diff with `git apply` or by editing the file directly. Only the `uses:` line version strings should change.

### Composer

```bash
git diff $(git merge-base <base> origin/<dep-branch>) origin/<dep-branch> -- composer.json
```

Apply the version change in `composer.json`, then regenerate the lock file:

```bash
composer update <vendor>/<package> --no-install
```

### pip / Poetry / other

Extract the exact diff and apply it directly:

```bash
git diff $(git merge-base <base> origin/<dep-branch>) origin/<dep-branch> -- requirements.txt pyproject.toml
```

Apply with `git apply` or edit the file. For Poetry, run `poetry lock --no-update` afterwards to refresh `poetry.lock`.

### Generic fallback

For any ecosystem not listed above: extract the diff of only the manifest/lock files from the dependabot branch and apply it with `patch`. If the diff does not apply cleanly, flag the conflict to the user.

## Phase 6 — Verify

For npm: confirm the target versions landed in the lock file:

```bash
node -e "
  const l = require('./package-lock.json');
  ['pkg1','pkg2'].forEach(p => console.log(p, l.packages['node_modules/'+p]?.version));
"
```

For other ecosystems: re-read the changed manifest and confirm the version strings match expectations.

## Phase 7 — Commit

Stage only the dependency manifests and lock files:

```bash
git add package.json package-lock.json wordpress/package-lock.json  # adjust as needed
```

Commit message format:

```
chore(deps): apply dependabot minor/patch updates

<Ecosystem>:
- <package> <old> → <new> (patch|minor)
- <package> removed (no longer needed by <other-package>)

<Ecosystem>:
- <package> <old> → <new> (minor)

Closes: #<n> #<n> #<n>
Skipped: #<n> (<package> <old>→<new>, major — requires separate migration)
```

## Phase 8 — Push and open draft PR

```bash
git push -u origin <branch-name>
gh pr create \
  --title "chore(deps): apply dependabot minor/patch updates" \
  --body "$(cat <<'EOF'
## Summary

Batch of Dependabot minor/patch updates applied to a single branch.

| Package | Change | Type | Ecosystem |
|---------|--------|------|-----------|
| name | old → new | patch | npm |

## Skipped

| PR | Package | Reason |
|----|---------|--------|
| #n | name | major bump — requires dedicated migration |

## Test plan
- [ ] CI passes
- [ ] App builds locally
EOF
)" \
  --draft \
  --base <base-branch>
```

Return the PR URL to the user.
