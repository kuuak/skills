# Rubric

Step 4 of [`SKILL.md`](SKILL.md): the bucket for each result, so two clients with the same problem get the same verdict.

## Principles

- **To fix**: exploitable today, or breaking soon: a known vulnerability in an installed version, a component with no more security fixes or losing them within about three months, a secret, backup or personal data anyone can download, a certificate about to expire.
- **To watch**: raises the risk without an open door today, or becomes "to fix" within about six months.
- **OK**: meets current practice. List it: the client sees what is fine.
- **Not verifiable**: the check could not run from where we stand. It goes to the report's limits, never into a bucket.

## By check

| Check | OK | To watch | To fix |
|---|---|---|---|
| HTTPS redirect | `301`/`308` to `https://` | redirect by script, or `302` | site served over plain HTTP |
| Certificate | over 30 days left | 14 to 30 days left, without automatic renewal | under 14 days, expired, or wrong name |
| Old TLS | TLS 1.0 and 1.1 refused | TLS 1.0 or 1.1 accepted | — |
| HSTS | present, `max-age` ≥ 15768000 (six months) | missing or shorter | — |
| Other security headers | `X-Content-Type-Options`, `Referrer-Policy`, frame protection and `Permissions-Policy` all present | any of them missing; no CSP | — |
| Version disclosure | none | any header, tag, file or page giving the exact version (`readme.html`, an installer page) | — |
| Mixed content | none | images over `http://` | scripts, styles or iframes over `http://` |
| CDN origin | answers only through the CDN | reachable directly by IP or another name | — |
| Exposed files | none, or `403` from a deny rule | `composer.json`, `composer.lock`, deploy scripts, a directory listing; a secret held back only by its file mode | `.env`, `auth.json`, `.git/`, config copies, database dumps, backup archives (code-only ones too: they hand over the whole code), `debug.log` with paths or queries, `phpinfo` |
| Personal uploads | none public | — | personal documents (IDs, CVs, form attachments) readable by anyone with the URL |
| API data | the API serves only what the public pages show | — | members-only or personal data readable without login |
| Staging or test copy | none public: behind a password or IP filter | public, current, without production data | public with production data or vulnerable versions |
| User listing | blocked | usernames public | — |
| Registration | closed | open, new accounts with the lowest role | open with any higher role |
| XML-RPC (WordPress) | disabled or filtered | enabled | — |
| Login page | behind a filter, basic auth, or 2FA we know of | reachable from anywhere, with or without a CAPTCHA | — |
| Host firewall | bans an IP after a burst of requests | — | — |
| CMS core | current branch, or an older branch still getting security fixes for over six months | security fixes ending in three to six months; two or more major versions behind | branch past its end of security support, or ending within three months; a known vulnerability in the installed version; a plugin's security fix that needs a newer core |
| Plugins, modules, themes | current, or one minor release behind | updates pending without a known vulnerability; not updated in over two years; a fork pinned well behind its source | a known vulnerability in the installed version; closed on wordpress.org; marked unsupported or insecure on drupal.org |
| Vulnerability without a fix | — | low or medium severity, no known exploitation | high or critical severity, or exploited in the wild |
| Vulnerability whose conditions are absent | — | the installed version is affected, but the feature, setting or host it needs is not there: say which | — |
| Vulnerability to confirm | — | seen only through the lock file or for a component whose version the outside cannot show, with a security release since the last delivery (for a prospect, within six months) | — |
| PHP, Node, framework, database, OS | branch in active support, or getting security fixes for over 12 months | security fixes ending in three to 12 months | branch past its end of security support, or ending within three months |
| OS or database run by the host | in support | past standard support, with the host's extended support possible | past every support, extended included |
| SPF | one record ending in `-all` or `~all`, under 10 lookups | ending in `?all` or `+all`; exactly 10 lookups | missing on a domain that sends mail; over 10 lookups |
| DMARC | `p=quarantine` or `p=reject` | `p=none` | missing on a domain that sends mail |
| DNSSEC | on | — (off is common; leave it out) | — |
| Integrity (SSH) | checksums match, or fail only on the host artefacts and forks [`STACKS.md`](STACKS.md) names | — | a modified core or plugin file (see compromise) |
| Server files (SSH) | secrets, keys and dumps readable by their owner only | readable by other accounts that are all ours; old dumps outside the web root; an unused runtime past support | readable by other customers' accounts |
| Administrators (SSH) | only current people | accounts of former staff or the agency | — |
| Backups (SSH or user) | recent and stored off the server | present but only on the same server, or never restored | none on the server and none in the host's panel |

Backups the site account cannot see, on managed hosting, go to the limits until the user checks the host's panel.

## Compromise

These mean the site may already be compromised. Stop the check-up and recommend a full `/security-audit`:

- spam links or text only Googlebot sees;
- a script from an unknown host, or obfuscated inline code, that the repo does not contain;
- obfuscated PHP anywhere in the web root (hex- or base64-packed function names, `eval` of decoded strings, `gzinflate` or `str_rot13` chains), the CMS root included;
- a core or plugin file failing checksums, beyond the artefacts [`STACKS.md`](STACKS.md) names;
- an administrator the user does not recognise: ask them about every account created after the last delivery before counting it here;
- a PHP file with content where the CMS keeps uploads ([`STACKS.md`](STACKS.md) names the folder).
