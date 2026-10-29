---
name: security-audit-light
description: Run a passive security check-up of a site we built but no longer maintain, and deliver a client report sorting findings into OK, to watch and to fix, with estimated actions the client ticks. Use when the user asks for a light audit or security check-up, or a report to offer maintenance to a past client.
argument-hint: [site URLs] [ssh host] [--no-estimates]
---

# security-audit-light

A **check-up** of a site the agency built and no longer maintains: what is fine, what to watch, what to fix, and what each fix costs. The client reads the report as an offer: they tick the actions they want and reply with their numbers. The deliverable is a client PDF built from [`template.html`](template.html).

Every probe is **passive** and **paced**: a GET or HEAD request of the kind a visitor's browser sends, at the pace set in [`CHECKS.md`](CHECKS.md#pace). Login attempts, form submissions and scanners belong to a signed engagement. When SSH still works, servers stay read-only, as in [`security-audit`](../security-audit/SKILL.md).

A sign of **compromise** turns the check-up into an incident. When a check listed under [`RUBRIC.md`](RUBRIC.md#compromise) fires, stop, show the user what you saw, and recommend a full `/security-audit` in place of this report.

## 1. Scope

In the site's repo, read the project memory (the `<project>-hosting-forensics` note, when an earlier audit wrote one), `CLAUDE.md`, deploy docs and `~/.ssh/config`, then pick the audit folder by the rule in step 1 of [`security-audit`](../security-audit/SKILL.md#1-scope). With no repo on this machine, the audit folder defaults to `~/Documents/check-ups/<site>/`, and the year the site was built comes from the user. Read any earlier check-up report in the audit folder: the new summary says what changed since.

Check that the site is ours: the repo, or the agency named in the site's footer credit. When the footer names another agency, tell the user before going on.

Then ask, in one `AskUserQuestion`, only what is still unknown:

- the production URL of each site;
- the SSH alias, or "no access";
- the report language;
- the client's display name;
- the year the site was built, when no repo gives it;
- whether the report carries **estimates** (yes by default; no when the work is already covered elsewhere, such as a prospect or a client about to sign a redo of the site), unless `--no-estimates` was passed;
- the audit folder, when the repo does not settle it.

**Done when:** every site has a URL, access is an alias or a recorded "no access", and the language, client name, build year, estimates and audit folder are set.

## 2. Outside

Tell the site's CMS from its home page and read its section of [`STACKS.md`](STACKS.md). With SSH, run the [server checks](CHECKS.md#server) first. Then run every check in [`CHECKS.md`](CHECKS.md#outside) against every site, at its pace.

**Done when:** every check has a result, or a stated reason it could not run, for every site.

## 3. Stack

List every component: CMS core, plugins, modules, themes, packages, PHP or Node, web server. Give each one a version and the source of that version, in the order [`CHECKS.md`](CHECKS.md#stack) sets; when sources disagree, record both. Then look up its vulnerabilities and support status as `CHECKS.md` and `STACKS.md` say.

**Done when:** every component has a version and its source (or "not visible"), its open vulnerabilities, and whether its branch still gets security fixes.

## 4. Classify

Sort every result into **OK**, **to watch** or **to fix** by [`RUBRIC.md`](RUBRIC.md). For a result the rubric does not name, apply its principles and tell the user which bucket you chose.

Then give each finding to watch or fix an action from [`ESTIMATES.md`](ESTIMATES.md); one action may cover several findings. When no action fits, ask the user for an estimate and add the action to the catalog. When the user declines to give one, or the action is on a stack outside the agency's (see `ESTIMATES.md`), the action goes in the report "à discuter", outside the totals. A report without estimates still takes its action labels from the catalog and skips the hours.

**Done when:** every result has a bucket, every finding to watch or fix has an action, and every estimate comes from `ESTIMATES.md`.

## 5. Report

Write the report by [`REPORT.md`](REPORT.md) into the audit folder, render it, and look at every page image.

**Done when:** the PDF and its HTML source sit side by side in the audit folder, and every page is checked: no finding or table row split across pages, no heading alone at a page bottom, no near-empty last page.

## 6. Deliver

Draft the email by [`REPORT.md`](REPORT.md#email). When the user reports it sent, record it as in [`security-audit`'s delivery](../security-audit/DELIVERY.md#clickup-record), with the task named "Check-up sécurité <site> – <dd.mm.yyyy>".

Write or update the project memory note `<project>-hosting-forensics`: site URLs, access, audit folder, the host's ban behaviour when one hit, and the date of this check-up.

After a correction to the report, update the HTML, re-render, re-check the pages, and keep the email draft consistent with it.
