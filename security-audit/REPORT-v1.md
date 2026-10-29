# Report, v1 layout

The blue layout used before the monochrome one, kept so a report delivered in it keeps its look when a follow-up report must match it. Use it only with `--v1-layout`. Build the report from a copy of [`template-v1.html`](template-v1.html); files, writing rules and the render check are those of [`REPORT.md`](REPORT.md).

## Sections, in order

1. **Cover:** kicker, title naming the vulnerability (CVE ids with non-breaking hyphens, `&#8209;`, so they never split), subtitle with the client and its sites, and the meta strip: date, author (`git config user.name` and the agency), analysed period, classification "Confidentiel".
2. **Résumé:** one lead paragraph with the verdict, then one verdict card per site, then a short note when the sites were patched by different means.
3. **Contexte:** what the vulnerability is in plain words, affected and fixed versions, the indicators it leaves, and a timeline table from disclosure to the last patch on the client's sites. A `.note` states how each hosting was patched and how that was verified.
4. **Périmètre et méthode:** a hosting table (hosting, sites), a checks table (check, period or scope), and a **Limites** paragraph naming every gap from the hunt.
5. **Analyse <site>:** one section per site or per group of sites on the same hosting: a verdict sentence first, then one bullet per check family, each with its numbers. A `.note.alert` holds residual risk.
6. **Autres constats:** findings unrelated to the vulnerability that still need action.
7. **Conclusions et recommandations:** three checklists, **Déjà fait** (ticked), **Fortement recommandé**, **Dans les prochaines semaines**, then sources as one compact line.

## Verdict card

Rows as in [`REPORT.md`](REPORT.md#verdict-per-site). Badges: `b-ok` green for safe, `b-warn` orange for safe with an action pending, `b-bad` red for compromised or exposed, `b-info` blue for who handles an open item. One muted line under the rows gives the main reason.
