# Report

The client reads this report to decide which actions to order. Build it from a copy of [`template.html`](template.html): its CSS is the house style, and its body shows each component once.

## Files

In the audit folder chosen in step 1 of [`SKILL.md`](SKILL.md) (create it when missing): `Check-up-securite-<Client>-<YYYY-MM-DD>.html` and the `.pdf` rendered from it (`Security-check-up-<Client>-<YYYY-MM-DD>` in English). Edit the HTML and re-render; the PDF is never edited by hand.

## Sections, in order

1. **Cover:** kicker, title naming the sites, subtitle with the client, and the meta strip: date, author (`git config user.name` and the agency), scope ("Analyse externe", or "Analyse externe et serveur" with SSH), classification "Confidentiel".
2. **Résumé:** the overall verdict badge, the three counts, then a lead paragraph of two or three sentences. The verdict follows the worst bucket present: "À corriger rapidement" (`b-bad`), "À entretenir" (`b-warn`), "En bon état" (`b-ok`). With an earlier check-up, one more sentence says what changed since.
3. **À corriger:** one finding card per finding.
4. **À surveiller:** the same, in orange.
5. **En ordre:** one table row per check that passed: the check in plain words, and its result.
6. **Actions proposées:** the order table, its two totals, the reply instructions, the validity line, and the maintenance plan note.
7. **Périmètre et limites:** the date and method, then every result step 4 marked not verifiable, and what an outside view cannot see (server files, logs, backups) when there was no SSH.

In English: Summary, To fix, To watch, In order, Proposed actions, Scope and limits; verdicts "Fix soon", "Needs upkeep", "In good shape".

## Finding card

Findings are numbered once across both sections, the ones to fix first. Each card holds:

- **Constat:** what we saw, with the number that makes it concrete (days left, versions behind, the release that fixed it).
- **Risque:** what it could cost the client in their own terms: a defaced site, leaked customer data, mail landing in spam, a browser warning on their home page. State each risk at its real size; the client trusts the "to fix" list because the "to watch" list stays calm.
- **Action:** the action number from the order table.

## Order table

One row per action, numbered `A1`, `A2`, …: actions covering a finding to fix first, then the rest. Columns: an empty box, the number, the label from [`ESTIMATES.md`](ESTIMATES.md), the findings it covers, the hours range, and the CHF range when the hourly rate is set (hours × rate, rounded to the nearest 10). Every box stays empty: the client ticks.

Two totals close the table, each the sum of the low ends and the sum of the high ends: the actions covering findings to fix, and all actions.

Below it: "Pour commander, cochez les actions souhaitées et renvoyez ce document, ou répondez à notre e-mail avec leurs numéros (par exemple A1, A3)." Then the validity from `ESTIMATES.md`, and a `.note` offering the maintenance plan as the alternative that covers these points over time.

## Writing for the client

- Plain words; a technical term gets a few words of explanation the first time.
- Dates as `dd.mm.yyyy`.
- A sensitive file found exposed is described by its kind and the kind of place it sat in. File paths and URLs stay out of the report.
- CVE ids, when cited, go in the **Constat** with non-breaking hyphens (`&#8209;`).

## Email

Write it into `email-<report name>.md` in the audit folder, in the report's language and in the register the client used with the agency (the French `tu` or `vous`; `vous` when unknown):

- **Subject:** "Check-up sécurité de <site>".
- **Opening:** we built the site in <year>; software ages, so we ran a short external check-up; the report is attached.
- **En bref:** the three counts, then each finding to fix in one line.
- **Next step:** reply with the numbers of the actions they want; the total for the actions covering findings to fix; the maintenance plan as the alternative.

## Render and check

```bash
<skill-dir>/../security-audit/render.sh <audit-folder>/<name>.html
```

It writes the PDF beside the HTML and one PNG per page into the scratchpad folder it prints. Read every PNG; fix splits with `break-inside: avoid` on the element or by trimming text, and re-render until every page passes.
