---
name: security-audit
description: Audit a site for known vulnerabilities in its stack, hunt its servers' logs and files for exploitation, and deliver the client PDF report. Use when the user asks for a security audit or incident report, or whether a site is affected by a CVE.
argument-hint: [CVE ids or technology] [ssh hosts]
---

# security-audit

Answer two questions for every environment of the site (production, staging, any sibling site on the same hosting): **is it exposed** to a known vulnerability in its stack, and **is there evidence it was exploited**. The deliverable is a client-facing PDF built from [`template.html`](template.html).

Servers stay **read-only**: read files, run read-only WP-CLI, and copy logs to your scratchpad. A write on a server (moving a file, logging users out, rotating a key) runs only when the user asks for that specific action; propose remediation work as its own session with a brief naming the one write it may perform.

A client email the user pastes is context for the email draft in step 8. The report answers the audit's own questions.

## 1. Scope

Read the project memory (hosting and forensics notes from earlier audits), `CLAUDE.md`, deploy docs and config (`wp-cli.yml` aliases, deploy scripts, CI files) and `~/.ssh/config` for host aliases matching the project. Then ask, in one `AskUserQuestion`, only what is still unknown:

- the SSH alias of each environment, or "no access";
- the start of the analysis window (default: the earliest of the advisory's first observed exploitation and the user's date; signature searches cover the whole log retention);
- the report language;
- the client's display name.

**Done when:** every environment has an alias or a recorded "no access", and the window, language and client name are set.

## 2. Inventory

Record the version of every runtime layer per environment: OS, web server, PHP or Node, CMS core, plugins and packages, database, container image. Read the repo (lock files, `Dockerfile`, CI) and each server; commands in [`CHECKS.md`](CHECKS.md#inventory). Read [`HOSTING.md`](HOSTING.md) for the hosting type: some hosts patch PHP without changing its version string, and some stacks ship their own PHP that host patches never reach.

**Done when:** a table lists each layer's version per environment, and each PHP version carries proof of when that binary was built or installed.

## 3. Vulnerabilities

For each CVE the user named, read `~/.claude/security-advisories/<CVE-ID>.md` first; parallel audits of other projects reuse it. When it is missing, research the CVE (sources in [`CHECKS.md`](CHECKS.md#vulnerability-sources)) and write that file: affected and fixed versions, preconditions, exploitation timeline, the **indicators** it leaves in logs and on disk, and source links.

With no CVE named, run the package audits and update checks in [`CHECKS.md`](CHECKS.md#vulnerability-sources) against the inventory, and research each runtime version's open advisories.

**Done when:** every applicable vulnerability has its fixed version, its indicators, and an exposure window per environment (vulnerable since, patched at).

## 4. Hunt

Copy each environment's logs to `<scratchpad>/logs/<env>/` in one `tar` over SSH, then run every check in [`CHECKS.md`](CHECKS.md#hunt) against every environment, plus the vulnerability's own indicators from step 3. Record each result with its **limit**: a log format without request bodies, a retention that starts after the exposure, container logs wiped by a redeploy.

**Done when:** every check has a result or a stated reason it could not run, for every environment.

## 5. Confirm

List the access events the logs cannot explain: admin logins from unknown IPs, SSH logins, plugin installs, new privileged users, sessions still open. Ask the user which ones are theirs or their team's.

**Done when:** each event is confirmed (it leaves the findings) or unknown (it becomes a finding with a recommendation).

## 6. Report

Write the report by [`REPORT.md`](REPORT.md) into `doc/audits/` of the audited repo, render it with [`render.sh`](render.sh), and look at every page image it prints.

**Done when:** the PDF and its HTML source sit side by side in that folder, and every page is checked: no card split across pages, no heading alone at a page bottom, no near-empty last page.

## 7. Remember

Write or update the project memory note `<project>-hosting-forensics`: host aliases per environment, log paths and retention, access level (sudo, WP-CLI path), and the quirks step 4 hit.

**Done when:** the note holds everything step 1 had to discover.

## 8. Deliver

Draft the client email, then log the delivery in ClickUp when the user reports it sent: [`DELIVERY.md`](DELIVERY.md).

After a correction to the report, update the HTML, re-render, re-check the pages, and keep the email draft consistent with it.
