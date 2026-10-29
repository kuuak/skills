# Report

The client reads this report to decide whether the site is safe and what to do next. Build it from a copy of [`template.html`](template.html): its CSS is the house style, the monochrome one [`security-audit-light`](../security-audit-light/template.html) shares, and its body shows each component once. With `--v1-layout`, follow [`REPORT-v1.md`](REPORT-v1.md) instead.

## Files

In the audit folder chosen in step 1 of [`SKILL.md`](SKILL.md) (create it when missing): `Rapport-incident-<Client>-<YYYY-MM-DD>.html` and the `.pdf` that [`render.sh`](render.sh) makes from it (`Security-report-<Client>-<YYYY-MM-DD>` in English). Edit the HTML and re-render; the PDF is never edited by hand. A correction edits that HTML, so the report keeps the layout it was built in.

## Sections, in order

Each section starts on a new page with a large title and a lead of one or two sentences. The running header carries `<Client>, rapport d'incident · confidentiel` and the month and year; set both in the template's `@page` rules.

1. **Cover** (full dark page): the client's short name as the title, the incident below it (CVE ids with non-breaking hyphens, `&#8209;`, so they never split), the sites as the list with each site's state as its superscript ("compromis", "exposé", "sain"), one sentence on the scope and the analysed period, and the month and year.
2. **Résumé:** priority dots for the verdict, the lead, a short paragraph with what grounds it and what stays open, one verdict block per site, a muted line for any environment left out, then two or three key figures that carry the verdict, the bar and one monospace line with the date, the author (`git config user.name` and the agency) and the analysed period. The verdict follows the worst site: ●●● "Intervention urgente" (compromised, or exposed without a fix), ●●○ "Action à prévoir" (safe with an action pending), ●○○ "Aucune trace d'exploitation".
3. **Contexte:** what the vulnerability is in plain words, then the affected and fixed versions and the indicators it leaves, one bullet each. With two unrelated subjects (a webshell and a framework CVE), one `h3` each.
4. **Chronologie:** a timeline table from disclosure (or first intrusion) to the last patch on the client's sites, then a `.note` stating how each hosting was patched and how that was verified, or the most likely scenario.
5. **Périmètre et méthode:** the lead says how and when the analysis ran (read-only), a line gives the time zone, then a hosting table (hosting, sites), a checks table (check, period or scope), and **Limites** naming every gap from the hunt.
6. **Analyse <site>:** one section per site or per group of sites on the same hosting, on a dark page when it is compromised or exposed. Priority dots as in the summary, the verdict sentence as the lead, up to three key figures, then one bullet per check family with its numbers. A `.note.alert` holds residual risk.
7. **Autres constats:** findings unrelated to the vulnerability that still need action, one numbered card each, two per row.
8. **Conclusions et recommandations:** three checklists, **Déjà fait** (ticked), **Fortement recommandé**, **Dans les prochaines semaines**, each open item with who does it under it.
9. **Parlons-en.** (full dark page): the offer to carry out the follow-ups, with the estimate when the user gave one, the agency's contact block as in the template, and the sources as one compact line at the bottom.

In English: Summary, Context, Timeline, Scope and method, Limits, Analysis, Other findings, Conclusions and recommendations, Done, Strongly recommended, In the coming weeks, Let's talk.; verdicts "Urgent action", "Action needed", "No sign of exploitation".

## Verdict per site

Rows: the vulnerability's short name (exposure: "Non exposé", "Tentatives sans effet", "Aucune trace d'exploitation"), "Compromission", "PHP corrigé" (with the date and time) or the stack's own patch, and "État au <date>". Each state is a `.state`: `s-bad` (filled) for compromised or exposed, `s-warn` (outlined) for safe with an action pending or a result the logs cannot settle, `s-ok` (plain) for safe. One muted line under the rows gives the main reason.

## Key figures

A figure is a count or a duration the client can repeat: "2 ans" of exposure, "17/22" plugins behind, "0" calls to the webshell. Its caption says what it counts in a few words. Keep each figure to six characters or fewer so three fit on a row.

## Writing for the client

- Dates as `dd.mm.yyyy`, times in the client's local time; the method section names the time zone once.
- A sensitive file found exposed is described by its kind and the kind of place it sat in. File paths and URLs stay out of the report.
- Access events the user confirmed in step 5 leave the findings.
- Recommendations are follow-ups the agency offers to carry out; when the user gives an estimate, state it with the offer to re-estimate a subset.
- An action the user reports done during the session moves to **Déjà fait**. Each open item names who does it: the client, the agency, or the hosting provider.

## Render and check

```bash
<skill-dir>/render.sh <audit-folder>/<name>.html
```

It writes the PDF beside the HTML and one PNG per page into the scratchpad folder it prints. Read every PNG; fix splits with `break-inside: avoid` on the element or by trimming text, and re-render until every page passes. A section that runs a few lines onto a second page is trimmed rather than left to spill.
