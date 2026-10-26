# Report

The client reads this report to decide whether the site is safe and what to do next. Build it from a copy of [`template.html`](template.html): its CSS is the house style, and its body shows each component once.

## Files

In the audit folder chosen in step 1 of [`SKILL.md`](SKILL.md) (create it when missing): `Rapport-incident-<Client>-<YYYY-MM-DD>.html` and the `.pdf` that [`render.sh`](render.sh) makes from it (`Security-report-<Client>-<YYYY-MM-DD>` in English). Edit the HTML and re-render; the PDF is never edited by hand.

## Sections, in order

1. **Cover:** kicker, title naming the vulnerability (CVE ids with non-breaking hyphens, `&#8209;`, so they never split), subtitle with the client and its sites, and the meta strip: date, author (`git config user.name` and the agency), analysed period, classification "Confidentiel".
2. **Résumé:** one lead paragraph with the verdict, then one verdict card per site, then a short note when the sites were patched by different means.
3. **Contexte:** what the vulnerability is in plain words, affected and fixed versions, the indicators it leaves, and a timeline table from disclosure to the last patch on the client's sites. A `.note` states how each hosting was patched and how that was verified.
4. **Périmètre et méthode:** a hosting table (hosting, sites), a checks table (check, period or scope), and a **Limites** paragraph naming every gap from the hunt.
5. **Analyse <site>:** one section per site or per group of sites on the same hosting: a verdict sentence first, then one bullet per check family, each with its numbers. A `.note.alert` holds residual risk.
6. **Autres constats:** findings unrelated to the vulnerability that still need action.
7. **Conclusions et recommandations:** three checklists, **Déjà fait** (ticked), **Fortement recommandé**, **Dans les prochaines semaines**, then sources as one compact line.

In English: Summary, Context, Scope and method, Limits, Analysis, Other findings, Conclusions and recommendations, Done, Strongly recommended, In the coming weeks.

## Verdict card

Rows: the vulnerability's short name (exposure: "Non exposé", "Tentatives sans effet", "Aucune trace d'exploitation"), "Compromission", "PHP corrigé" (with the date and time), and "État au <date>". Badges: `b-ok` green for safe, `b-warn` orange for safe with an action pending, `b-bad` red for compromised or exposed, `b-info` blue for an item the agency handles. One muted line under the rows gives the main reason.

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

It writes the PDF beside the HTML and one PNG per page into the scratchpad folder it prints. Read every PNG; fix splits with `break-inside: avoid` on the element or by trimming text, and re-render until every page passes.
