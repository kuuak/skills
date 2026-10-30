# Report

The client reads this report to decide which actions to order. Build it from a copy of [`template.html`](template.html): its CSS is the house style, and its body shows each component once.

## Files

In the audit folder chosen in step 1 of [`SKILL.md`](SKILL.md) (create it when missing): `Check-up-securite-<Client>-<YYYY-MM-DD>.html` and the `.pdf` rendered from it (`Security-check-up-<Client>-<YYYY-MM-DD>` in English). `<Client>` is the display name without accents, spaces turned into hyphens (`Solmani-SA`). Edit the HTML and re-render; the PDF is never edited by hand.

## Sections, in order

Each section starts on a new page. The running header carries `<site>, check-up sécurité` and the month and year; set both in the template's `@page` rules.

1. **Cover** (full dark page): the sites as the title, the client below, the three buckets with their counts as superscripts, one sentence on the scope ("depuis l'extérieur", plus "et sur le serveur en lecture seule" with SSH), and the month and year.
2. **Résumé:** priority dots for the verdict, a lead of one or two sentences, a short paragraph naming the findings to fix, the three counts as large figures, then the bar and one monospace line with the date and author (`git config user.name` and the agency). The verdict follows the worst bucket present: ●●● "À corriger rapidement", ●●○ "À entretenir", ●○○ "En bon état". With an earlier check-up, the paragraph also says what changed since.
3. **À corriger** (dark pages): ●●● "Priorité haute", then the finding cards. With no finding to fix, leave the section out; the cover and résumé still show 0.
4. **À surveiller:** ●●○ "Priorité moyenne", then the finding cards.
5. **En ordre:** one table row per check that passed: the check in plain words, and its result. A finding fixed between the analysis and the report goes here, its result saying what was found and the date it was fixed.
6. **Actions proposées:** the reply instructions as the lead, the order table and its two totals, the legend with the validity line, then **Périmètre et limites** as a subsection: the date and method, every result step 4 marked not verifiable, and what an outside view cannot see (server files, logs, backups) when there was no SSH.
7. **Parlons-en.** (full dark page): the maintenance plan from [`ESTIMATES.md`](ESTIMATES.md) as the alternative to one-off actions, with its price when set, then the agency's contact block as in the template. For a current client (step 1), the paragraph names the next step under the current arrangement in place of the plan.

## Finding card

Findings are numbered once across both sections, the ones to fix first. Cards to fix sit two per row, about four to a dark page; with more, the section runs onto a second dark page, and an odd last card takes the full width (`finding wide`). Cards to watch sit two per row in the `compact` grid, which holds up to ten on one page. With more than ten, the section runs onto a second page. Each card holds the number, a title, and:

- **Ce que nous avons constaté:** what we saw, with the number that makes it concrete (days left, versions behind, the release that fixed it).
- **Ce que cela implique:** what it could cost the client in their own terms: a defaced site, leaked customer data, mail landing in spam, a browser warning on their home page. State each risk at its real size; the client trusts the "to fix" list because the "to watch" list stays calm.
- **Action:** the action numbers from the order table, in monospace.

A card to fix carries the full detail. A card to watch keeps its title and each part to one short sentence, which is what keeps ten on one page: the order table and a follow-up call carry the rest.

## Order table

One row per action, numbered `A1`, `A2`, …: actions covering a finding to fix first, then the rest. Columns: an empty box, the number, the label from [`ESTIMATES.md`](ESTIMATES.md), the findings it covers (● before findings to fix, ○ before findings to watch), and the hours range. With the hourly rate set, add a CHF column after the hours (hours × rate, rounded to the nearest 10). Every box stays empty: the client ticks.

An action outside the agency's stacks, or one the user gave no estimate for, reads "à discuter" in the hours column and stays out of the sums; a total that leaves one out says so ("5–9 h + A1 à discuter").

Two totals close the table, each the sum of the low ends and the sum of the high ends: the actions covering findings to fix (left out with no finding to fix), and all actions. The line below it explains ● and ○ and gives the validity from `ESTIMATES.md`. When actions go together or one must come first, a second line says so in one sentence ("A3 suppose A2 : les correctifs de l'extension demandent la nouvelle version de WordPress.").

Without estimates (step 1), the table ends at the findings column: no hours, CHF, totals or validity line, and no "à discuter". The boxes, numbers and labels stay.

## Writing for the client

- Plain words; a technical term gets a few words of explanation the first time.
- Dates as `dd.mm.yyyy`.
- A sensitive file found exposed is described by its kind and the kind of place it sat in. File paths and URLs stay out of the report.
- CVE ids, when cited, go in what we found, with non-breaking hyphens (`&#8209;`).

## Email

Write it into `email-<report name>.md` in the audit folder, in the report's language and in the register the client used with the agency (the French `tu` or `vous`; `vous` when unknown):

- **Subject:** "Check-up sécurité de <site>" ("Security check-up of <site>").
- **Opening**, by the case from step 1: for a past client, we built the site in <year>; software ages, so we ran a short external check-up. For a current client, the check-up is part of our follow-up; with an earlier audit, say which findings it already raised. For a prospect, who we are, and that we looked from the outside only, as any visitor could. Then: the report is attached.
- **En bref:** the three counts, then each finding to fix in one line.
- **Next step:** reply with the numbers of the actions they want; the total for the actions covering findings to fix, when the report carries estimates; the maintenance plan as the alternative.
- **Signature:** the author's name from `git config user.name`, and the agency.

## English

Every string of the template, for a report in English:

| French | English |
|---|---|
| check-up sécurité (running header, cover) · Confidentiel | security check-up · Confidential |
| Résumé, À corriger, À surveiller, En ordre, Actions proposées, Périmètre et limites, Parlons-en. | Summary, To fix, To watch, In order, Proposed actions, Scope and limits, Let's talk. |
| À corriger rapidement, À entretenir, En bon état | Fix soon, Needs upkeep, In good shape |
| Priorité haute, Priorité moyenne | High priority, Medium priority |
| Un regard sur la sécurité du site, depuis l'extérieur[ et sur le serveur en lecture seule]. Les exposants indiquent le nombre de points par catégorie. | A look at the site's security from the outside[ and on the server, read-only]. The superscripts give the number of points in each category. |
| points à corriger, points à surveiller, contrôles en ordre | points to fix, points to watch, checks in order |
| Établi le [date] par [Auteur], superhuit | Prepared on [date] by [Author], superhuit |
| Ce que nous avons constaté, Ce que cela implique, Action | What we found, What it means, Action |
| Contrôle, Résultat | Check, Result |
| Cochez les actions souhaitées et renvoyez ce document, ou répondez à notre e-mail avec leurs numéros (par exemple A1, A3). | Tick the actions you want and send this document back, or reply to our email with their numbers (for example A1, A3). |
| N°, Action, Points, Heures | No., Action, Points, Hours |
| Actions sur les points à corriger, Toutes les actions | Actions on the points to fix, All actions |
| à discuter | to be discussed |
| ● point à corriger ○ point à surveiller. Estimations valables [n] jours à compter de la date du rapport. Chaque action comprend une sauvegarde complète avant l'intervention et un contrôle du site après. | ● point to fix ○ point to watch. Estimates valid [n] days from the report date. Every action includes a full backup before the work and a check of the site afterwards. |
| L'analyse a été menée le [date] depuis l'extérieur, comme le ferait un visiteur : rien n'a été modifié sur le site ni sur ses serveurs, et aucun essai de connexion n'a été fait. | The analysis was run on [date] from the outside, as a visitor would: nothing was changed on the site or its servers, and no login was attempted. |
| Plutôt que des interventions ponctuelles, notre plan de maintenance couvre ces points dans la durée : [plan]. Nous vous en présentons volontiers les conditions, ou réalisons les actions que vous aurez cochées. | Rather than one-off work, our maintenance plan covers these points over time: [plan]. We are glad to present its terms, or to carry out the actions you ticked. |
| Suisse | Switzerland |

Set `<html lang="en">` and the `<title>` too.

## Render and check

```bash
<skill-dir>/../security-audit/render.sh <audit-folder>/<name>.html <scratchpad>/pages
```

It writes the PDF beside the HTML and one PNG per page into `<scratchpad>/pages`. Read every PNG; fix splits with `break-inside: avoid` on the element or by trimming text, and re-render until every page passes.
