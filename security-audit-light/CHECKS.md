# Checks

Commands for steps 2 and 3 of [`SKILL.md`](SKILL.md). Run them from the Mac against the public site. CMS-specific paths and sources live in [`STACKS.md`](STACKS.md).

## Pace

Hosts ban an IP for about ten minutes, on HTTP and SSH together and across all their servers. The office IP is shared, so a ban also blocks colleagues.

- Pace each host that answers, not only the site's name: a frontend can proxy paths to its backend (Next.js rewrites send `/wp-content/uploads/*` to the WordPress host), so probes on the frontend count against the backend too.
- Leave about 5 s between requests to the same host, and 15 s on Infomaniak, with TLS handshakes 30 s apart.
- On Infomaniak, the Googlebot fetch is the last request of the whole check-up, SSH included: in four runs the ban followed it within seconds, whatever the pace before.
- Leave 10 s between Patchstack pages: it blocks after about a dozen quick loads.
- Run one check-up per hosting provider at a time.
- With SSH, run the [server checks](#server) first.
- When requests start timing out, check the site from outside with check-host.net (TCP on port 443). Open there and closed here means a ban: wait ten minutes, then go on at a slower pace.

## Outside

### Target

`curl -sIL http://<host>/` follows the redirects. The final URL is `<site>` for every check below (it may carry a path, such as `/fr`), and its host is `<host>`. `<domain>` is the registered domain behind it. A headless site has a second host, its backend ([`STACKS.md`](STACKS.md#headless-wordpress)): run the outside checks on both.

### Soft 404 baseline

Sites answer a missing path in several ways (a web server 404, a CMS-themed 404, a 403, a redirect). Take one baseline per kind of path before probing:

```bash
for p in check-up-$RANDOM.txt check-up-$RANDOM.php check-up-$RANDOM/; do
  curl -s -o /dev/null -w "$p %{http_code} %{size_download}\n" <site>/$p; sleep 5
done
```

A probe **exists** when it answers `200` or `206` with a body that is neither the site's HTML page nor the size of a baseline. A `403` means blocked: the file cannot be read, whether or not it exists. A redirect means not exposed: a headless backend sends every missing path to the frontend, and Vercel adds a trailing slash.

### HTTPS

- Redirect: `curl -sI http://<host>/` answers `301` or `308` to `https://`.
- Certificate: `echo | openssl s_client -servername <host> -connect <host>:443 2>/dev/null | openssl x509 -noout -enddate -issuer -ext subjectAltName`. Record the days left.
- Old protocols: OpenSSL 3 refuses TLS 1.1 on its own side unless the security level is lowered:

  ```bash
  openssl s_client -tls1_1 -cipher 'DEFAULT:@SECLEVEL=0' -servername <host> -connect <host>:443 </dev/null
  ```

  Accepted only when a cipher is negotiated. `Cipher is (NONE)` or `alert protocol version` means refused: OpenSSL prints `Protocol: TLSv1.1` in both cases. Run it again with `-tls1` for TLS 1.0.

### Headers

Read the headers of a GET, as a visitor gets them, on the home page and one inner page: `curl -s -D - -o /dev/null <site>`. A page cache serves GETs with other headers than the uncached `HEAD`, so `curl -I` can show protection the visitor never gets. Read:

- protection: `Strict-Transport-Security`, `Content-Security-Policy` (and its `frame-ancestors`), `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`;
- disclosure: `Server` carrying a version, `X-Powered-By`, `X-Generator`.

### CDN origin

Behind a CDN (`Server: cloudflare`, `x-vercel-id`, `x-amz-cf-id`), the origin should answer only through it. `dig +short <domain>` and `dig +short www.<domain>`: a name resolving outside the CDN that serves the site itself (a CMS redirect or page, not the CDN's) shows the origin reachable around the CDN, and its `Server` header names the real web server.

### Page content

Fetch `<site>` once as a browser and once as Googlebot (`-A 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'`; last of all on Infomaniak, see [Pace](#pace)), then:

- **cloaking**: `cmp` the two bodies. When they differ, compare their links and visible text; spam shows as links or words only Googlebot gets. A keyword grep alone misfires ("spécialisée" contains "cialis").
- **injected scripts**: `<script>` sources on hosts the site does not use, or obfuscated inline code (`eval(`, `atob(`, `String.fromCharCode`);
- **mixed content**: `http://` in the `src` of a script, image or iframe, or the `href` of a stylesheet. Plain `<a href>` links do not count.
- **versions**: as [`STACKS.md`](STACKS.md) says for the CMS.

### Exposed files

One request each, paced: `curl -s -o /dev/null -w '%{http_code} %{size_download}' -r 0-200 <site>/<path>`, judged against the baseline.

- secrets: `.env`, `.git/HEAD`, `auth.json` (premium plugin credentials), `.DS_Store`;
- dependencies and deploy files: `composer.json`, `composer.lock`, `vendor/`, `provision.sh`, `deploy.sh`;
- backups: `backup.zip`, `backup.sql`, `db-backup.sql`, `<host>.zip`, `<domain>.sql`;
- debug: `phpinfo.php`, `info.php`;
- the CMS's own paths from [`STACKS.md`](STACKS.md).

Backups with a timestamp or random suffix in their name escape this list; only the [web root listing](#server) finds them.

### Email and domain

Only when the domain receives mail (`dig +short MX <domain>`):

- SPF: `dig +short TXT <domain>`, one `v=spf1` record ending in `-all` or `~all`. Count its DNS lookups (`include`, `a`, `mx`, `ptr`, `exists`, `redirect`, and those inside each include): receivers reject a record past 10.
- DMARC: `dig +short TXT _dmarc.<domain>`, and its policy (`p=none`, `quarantine`, `reject`);
- DKIM: `dig +short TXT <selector>._domainkey.<domain>` for the MX provider's selectors (`selector1` and `selector2` for Microsoft 365, `google`) and for each sender the SPF record includes (`k1` for Mailchimp, `default`). Selectors cannot be listed: a provider with none found is a limit, not a finding.

Domain: DNSSEC is on when `dig +short DS <domain>` returns a record. Expiry: `whois <domain>`; for `.ch` and `.li`, `whois -h whois.nic.ch <domain>` (the default server answers with the registry's own record), which hides the date: record it as a limit.

## Stack

**Repo:** the last commit date on the default branch (the last delivery), the first commit's year (when the site was built), and the lock files: `composer.lock`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `Dockerfile` `FROM` lines, `.nvmrc`.

**Which version counts:** the server's, when SSH works; then what the outside shows; then the lock file. With automatic updates on, the lock can be months behind production. A vulnerability seen only through the lock, while production's version cannot be seen, is one to confirm (see [`RUBRIC.md`](RUBRIC.md)).

**Known vulnerabilities:** for libraries, the package audits and OSV listed in [`security-audit`'s sources](../security-audit/CHECKS.md#vulnerability-sources); for CMS core, plugins, modules and frameworks, the sources in [`STACKS.md`](STACKS.md). For each one, read what it needs to be exploited (a feature, a setting, a host) and check whether this site has it.

**Support status:** `curl -s https://endoflife.date/api/<product>.json` (`php`, `wordpress`, `drupal`, `nextjs`, `nodejs`, `nginx`, `mysql`, `mariadb`, `debian`, `ubuntu`) gives each branch's end of security support (`eol`) and latest release.

## Server

Only with SSH, read-only. Versions as in [`security-audit`'s inventory](../security-audit/CHECKS.md#inventory), then the CMS's server checks in [`STACKS.md`](STACKS.md), plus:

- **web root listing:** `ls -la` of the web root and its parent. Flag dumps, archives and files the repo does not explain: deploy scripts write names such as `db-backup-YYYYMMDD_HHMMSS.sql`, and each one found is probed from outside like the list above.
- **secrets:** read a secrets file's mode and whether the web serves it, never its content (`.env`, `auth.json`, `wp-config.php`). When the web answers `403`, find what blocks it: a deny rule holds, a file mode alone breaks at the next deploy that resets it.
- **readable by other accounts:** with other local accounts on the server (`/etc/passwd`), TLS keys, dumps and secrets files readable by all (`-rw-r--r--`).
- **backups:** a backup plugin's or module's last run, or the host's backup panel, which the user checks. On managed hosting the site account cannot see the host's backups.
