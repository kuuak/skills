# Checks

Commands for steps 2 and 3 of [`SKILL.md`](SKILL.md). Run them from the Mac against the public site. CMS-specific paths and sources live in [`STACKS.md`](STACKS.md).

## Pace

Shared hosts ban an IP for about ten minutes after a burst of requests, on HTTP and SSH together and across all their servers: about a dozen requests in a minute did it at Infomaniak, failed TLS handshakes included. The office IP is shared, so a ban also blocks colleagues.

- Leave about 5 s between requests to the same site.
- Run one check-up per hosting provider at a time.
- With SSH, run the [server checks](#server) first.
- When requests start timing out, check the site from outside with check-host.net (TCP on port 443). Open there and closed here means a ban: wait ten minutes, then go on at a slower pace.

## Outside

### Target

`curl -sIL http://<host>/` follows the redirects. The final URL is `<site>` for every check below (it may carry a path, such as `/fr`), and its host is `<host>`. `<domain>` is the registered domain behind it.

### Soft 404 baseline

Sites answer a missing path in several ways (a web server 404, a CMS-themed 404, a 403). Take one baseline per kind of path before probing:

```bash
for p in check-up-$RANDOM.txt check-up-$RANDOM.php check-up-$RANDOM/; do
  curl -s -o /dev/null -w "$p %{http_code} %{size_download}\n" <site>/$p; sleep 5
done
```

A probe **exists** when it answers `200` or `206` with a body that is neither the site's HTML page nor the size of a baseline. A `403` means blocked: the file cannot be read, whether or not it exists.

### HTTPS

- Redirect: `curl -sI http://<host>/` answers `301` or `308` to `https://`.
- Certificate: `echo | openssl s_client -servername <host> -connect <host>:443 2>/dev/null | openssl x509 -noout -enddate -issuer -ext subjectAltName`. Record the days left.
- Old protocols: OpenSSL 3 refuses TLS 1.1 on its own side unless the security level is lowered:

  ```bash
  openssl s_client -tls1_1 -cipher 'DEFAULT:@SECLEVEL=0' -servername <host> -connect <host>:443 </dev/null
  ```

  Accepted only when a cipher is negotiated. `Cipher is (NONE)` or `alert protocol version` means refused: OpenSSL prints `Protocol: TLSv1.1` in both cases. Run it again with `-tls1` for TLS 1.0.

### Headers

`curl -sI <site>` once, then read:

- protection: `Strict-Transport-Security`, `Content-Security-Policy` (and its `frame-ancestors`), `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`;
- disclosure: `Server` carrying a version, `X-Powered-By`, `X-Generator`.

### Page content

Fetch `<site>` once as a browser and once as Googlebot (`-A 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'`), then:

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

### Email and domain

Only when the domain receives mail (`dig +short MX <domain>`):

- SPF: `dig +short TXT <domain>`, one `v=spf1` record ending in `-all` or `~all`;
- DMARC: `dig +short TXT _dmarc.<domain>`, and its policy (`p=none`, `quarantine`, `reject`);
- DKIM: `dig +short TXT <selector>._domainkey.<domain>` for the MX provider's selectors (`selector1` and `selector2` for Microsoft 365, `google`) and for each sender the SPF record includes (`k1` for Mailchimp, `default`). Selectors cannot be listed: a provider with none found is a limit, not a finding.

Domain: DNSSEC is on when `dig +short DS <domain>` returns a record. Expiry: `whois <domain>`; for `.ch` and `.li`, `whois -h whois.nic.ch <domain>` (the default server answers with the registry's own record), which hides the date: record it as a limit.

## Stack

**Repo:** the last commit date on the default branch (the last delivery), the first commit's year (when the site was built), and the lock files: `composer.lock`, `package-lock.json`, `Dockerfile` `FROM` lines, `.nvmrc`.

**Which version counts:** the server's, when SSH works; then what the outside shows; then the lock file. With automatic updates on, the lock can be months behind production. A vulnerability seen only through the lock, while production's version cannot be seen, is one to confirm (see [`RUBRIC.md`](RUBRIC.md)).

**Known vulnerabilities:** for libraries, the package audits and OSV listed in [`security-audit`'s sources](../security-audit/CHECKS.md#vulnerability-sources); for CMS core, plugins and modules, the sources in [`STACKS.md`](STACKS.md).

**Support status:** `curl -s https://endoflife.date/api/<product>.json` (`php`, `wordpress`, `drupal`, `nodejs`, `nginx`, `mysql`, `mariadb`, `ubuntu`) gives each branch's end of security support (`eol`) and latest release.

## Server

Only with SSH, read-only. Versions as in [`security-audit`'s inventory](../security-audit/CHECKS.md#inventory), then the CMS's server checks in [`STACKS.md`](STACKS.md), plus backups: a backup plugin's or module's last run, or the host's backup panel, which the user checks.
