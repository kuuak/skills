# Checks

Commands for steps 2 and 3 of [`SKILL.md`](SKILL.md). Run them from the Mac against the public site; `<site>` is `https://<host>`, and `<domain>` is the registered domain behind `<host>`.

## Outside

### Soft 404 baseline

Many sites answer `200` with a page for any path. Fetch a path that cannot exist first, and judge every probe below against it:

```bash
curl -s -o /dev/null -w '%{http_code} %{size_download}\n' <site>/check-up-$RANDOM.txt
```

A probe "exists" when its status or size differs from this baseline and its body is not the site's own HTML page.

### HTTPS

- Redirect: `curl -sI http://<host>/` answers `301` or `308` to `https://`.
- Certificate: `echo | openssl s_client -servername <host> -connect <host>:443 2>/dev/null | openssl x509 -noout -enddate -issuer -ext subjectAltName`. Record the days left.
- Old protocols: `openssl s_client -tls1_1 -connect <host>:443 </dev/null` must fail to handshake.

### Headers

`curl -sI <site>/` once, then read:

- protection: `Strict-Transport-Security`, `Content-Security-Policy` (and its `frame-ancestors`), `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`;
- disclosure: `Server` carrying a version, `X-Powered-By` (PHP version).

### Page content

Fetch the home page once as a browser and once as Googlebot (`-A 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'`), and compare:

- **cloaking**: links or text only Googlebot sees, often pharma, casino or loan spam;
- **injected scripts**: `<script>` sources on hosts the site does not use, or obfuscated inline code (`eval(`, `atob(`, `String.fromCharCode`);
- **mixed content**: `http://` sources for scripts, styles or iframes;
- **versions**: the `generator` meta tag, `?ver=` on assets under `/wp-content/plugins/<slug>/` and `/wp-content/themes/<slug>/`, and `<generator>` in `<site>/feed/`.

### Exposed files

One ranged request each: `curl -s -o /dev/null -w '%{http_code} %{size_download}' -r 0-200 <site>/<path>`.

- secrets and code: `.env`, `.git/HEAD`, `wp-config.php.bak`, `wp-config.php~`, `wp-config.old`, `composer.lock`, `.DS_Store`;
- backups: `backup.zip`, `backup.sql`, `<host>.zip`, `<domain>.sql`, `wp-content/backup-db/`, `wp-content/updraft/`;
- debug: `wp-content/debug.log`, `phpinfo.php`, `info.php`;
- listings: `wp-content/uploads/` and `wp-content/plugins/` answering an `Index of` page.

### WordPress surface

- users listed: `<site>/wp-json/wp/v2/users` returning login slugs, or `<site>/?author=1` redirecting to `/author/<login>/`;
- XML-RPC: `<site>/xmlrpc.php` answering `405` with "XML-RPC server accepts POST requests only" means it is enabled;
- login page: `<site>/wp-login.php` and `<site>/wp-admin/` reachable from anywhere, or behind basic auth, an IP filter or a renamed path;
- `<site>/readme.html` present (it states the core version).

For another stack, check its equivalents: Drupal's `CHANGELOG.txt`, a Next.js build id, a framework debug page.

### Email and domain

Only when the domain receives mail (`dig +short MX <domain>`):

- SPF: `dig +short TXT <domain>`, one `v=spf1` record ending in `-all` or `~all`;
- DMARC: `dig +short TXT _dmarc.<domain>`, and its policy (`p=none`, `quarantine`, `reject`);
- DKIM: `dig +short TXT <selector>._domainkey.<domain>` for the provider's selector (`google`, `selector1` and `selector2` for Microsoft 365, `k1` for Mailchimp, `default`); none found among these is a limit, not a finding.

Domain expiry: `whois <domain>`. Swiss `.ch` and `.li` registries hide the date; record it as a limit.

## Stack

**Repo:** the last commit date on the default branch (the last delivery), `composer.lock` (WordPress core package, `wpackagist-plugin/*`, PHP constraint), `package-lock.json`, `Dockerfile` `FROM` lines, `.nvmrc`.

**Known vulnerabilities:** the package audits, OSV, and the WordPress plugin databases listed in [`security-audit`'s sources](../security-audit/CHECKS.md#vulnerability-sources), run against the production version where the outside showed it.

**Plugin status on wordpress.org**, for each plugin slug (the brackets must be URL-encoded):

```bash
curl -s 'https://api.wordpress.org/plugins/info/1.2/?action=plugin_information&request%5Bslug%5D=<slug>'
```

It returns `"closed": true` with the date and reason for a closed plugin, and `version` and `last_updated` otherwise. Premium plugins are absent: read their vendor changelog.

**Support status:** `curl -s https://endoflife.date/api/<product>.json` (`php`, `wordpress`, `nodejs`, `nginx`, `mysql`, `mariadb`, `ubuntu`) gives each branch's end of security support (`eol`) and latest release.

## Server

Only with SSH, read-only. Versions as in [`security-audit`'s inventory](../security-audit/CHECKS.md#inventory), plus:

- integrity: `wp core verify-checksums`, `wp plugin verify-checksums --all`;
- administrators: `wp user list --role=administrator --fields=user_login,user_email,user_registered`;
- backups: a backup plugin's last run (`wp option get updraft_last_backup`, or the plugin's own folder dates), or the host's backup panel, which the user checks.
