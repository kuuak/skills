# Rubric

Step 4 of [`SKILL.md`](SKILL.md): the bucket for each result, so two clients with the same problem get the same verdict.

## Principles

- **To fix**: exploitable today, or breaking soon: a known vulnerability in an installed version, a component with no more security fixes, a secret or backup anyone can download, a certificate about to expire.
- **To watch**: raises the risk without an open door today, or becomes "to fix" within about six months.
- **OK**: meets current practice. List it: the client sees what is fine.
- **Not verifiable**: the check could not run from where we stand. It goes to the report's limits, never into a bucket.

## By check

| Check | OK | To watch | To fix |
|---|---|---|---|
| HTTPS redirect | `301`/`308` to `https://` | redirect by script, or `302` | site served over plain HTTP |
| Certificate | over 30 days left | 14 to 30 days left, without automatic renewal | under 14 days, expired, or wrong name |
| Old TLS | TLS 1.0 and 1.1 refused | TLS 1.1 accepted | — |
| HSTS | present, `max-age` ≥ 6 months | missing or short | — |
| Other security headers | at least `X-Content-Type-Options`, `Referrer-Policy` and frame protection | any of them missing; no CSP alone | — |
| Version disclosure | none | `Server` or `X-Powered-By` with a version, `generator` tag, `readme.html` | — |
| Mixed content | none | images over `http://` | scripts or iframes over `http://` |
| Exposed files | none | `composer.lock`, directory listing of uploads or plugins | `.env`, `.git/`, config copies, database dumps, backup archives, `debug.log` with paths or queries, `phpinfo` |
| User listing | blocked | login slugs public | — |
| XML-RPC | disabled or filtered | enabled | — |
| Login page | behind a filter, basic auth or 2FA we know of | reachable from anywhere | — |
| Core, plugins, themes | current, or one minor release behind | updates pending without a known vulnerability; a plugin not updated in over two years | a known vulnerability in the installed version; a plugin closed on wordpress.org |
| PHP, Node, database, OS | branch in active support | security fixes only, ending within 12 months | branch past its end of security support |
| SPF / DMARC | SPF ending in `-all` or `~all`; DMARC `quarantine` or `reject` | DMARC `p=none`, or SPF without DKIM found | no SPF or no DMARC on a domain that sends mail |
| Integrity (SSH) | checksums match | — | a modified core or plugin file (see compromise) |
| Administrators (SSH) | only current people | accounts of former staff or the agency | — |
| Backups (SSH or user) | recent and stored off the server | present but only on the same server, or never restored | none found |

## Compromise

These mean the site may already be compromised. Stop the check-up and recommend a full `/security-audit`:

- spam links or text only Googlebot sees;
- a script from an unknown host, or obfuscated inline code, that the repo does not contain;
- a core or plugin file failing checksums;
- an administrator nobody recognises;
- a PHP file answering `200` in uploads.
