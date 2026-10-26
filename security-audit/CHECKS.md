# Checks

Commands for steps 2 to 4 of [`SKILL.md`](SKILL.md). Every command on a server is read-only. Where docroots or logs need root, use `sudo -n` (it fails instead of prompting); run WP-CLI as the docroot owner: `sudo -n -u <owner> wp --path=<docroot>`.

The audit runs on macOS: decompress with `gzcat` or `gzip -dc` (`zcat` looks for `.Z` files), keep `awk` programs to POSIX syntax (BSD awk rejects gawk extensions), and edit in place with `sed -i ''`.

## Inventory

**Repo:** `composer.json` and `composer.lock` (PHP constraint, WordPress core package, plugins), `package-lock.json`, `Dockerfile` `FROM` lines (the image tag fixes the PHP version), `.nvmrc`, CI files.

**Server:**

- OS: `cat /etc/os-release`.
- PHP: `php -v`, `php -i | grep -i 'build date'`, and the binary's date: `ls -l --time-style=full-iso "$(readlink -f "$(command -v php)")"`, the same for `php-fpm*`. On Debian/Ubuntu, `grep -E ' (upgrade|install) php' /var/log/dpkg.log*` gives the patch time. In a container: `docker exec <c> php -v`.
- Web server: `nginx -v`, `apache2 -v` or `httpd -v`; vhost config for the site (`fastcgi_pass` gives the PHP pool).
- WordPress: `wp core version`, `wp plugin list --fields=name,version,update_version,status`, `wp theme list --fields=name,version,update_version,status`.
- Database: `mysql --version` or `mariadb --version`.

## Vulnerability sources

**A named CVE:**

- CVE record: `curl -s https://cveawg.mitre.org/api/cve/<CVE-ID>` and `curl -s 'https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=<CVE-ID>'`.
- The project's own advisories, when it publishes them on GitHub: `gh api repos/<owner>/<repo>/security-advisories` (PHP: `php/php-src`).
- Security-research write-ups (vendor blog, Datadog, Rapid7, Tenable, Sansec, Wiz): they carry the indicators and the exploitation timeline the record lacks. Search `<CVE-ID> <product>`; a bare CVE id returns unrelated CVEs.

**No CVE named:**

- Composer: `composer audit --locked --format=json`.
- npm: `npm audit --omit=dev --json`.
- Any ecosystem: `curl -s https://api.osv.dev/v1/querybatch -d '{"queries":[{"package":{"name":"<pkg>","ecosystem":"Packagist"},"version":"<v>"}]}'` (`npm`, `PyPI` and others work the same).
- WordPress: `wp core check-update`, `wp plugin list --update=available`; for each outdated plugin, read its changelog for security fixes and look it up on Wordfence Intelligence, Patchstack or WPScan.
- Runtimes (PHP, Node, nginx, OS packages): the vendor's security page for the installed branch, and whether that branch still gets security fixes.

## Hunt

### Logs

Copy once, then analyse locally: `ssh <host> 'cd <logdir> && sudo -n tar czf - <files>' | tar xzf - -C <scratchpad>/logs/<env>`. Concatenate rotations oldest first into one file per log.

**Access logs**, over the analysis window:

- requests per hour with POST, 5xx and 499 counts; spikes against the days before;
- POST requests by path, excluding the site's known traffic (frontend API calls, cron);
- `.php` paths answering 2xx: one that is not core, a plugin or the theme is the strongest sign of a webshell;
- successful logins (`POST /wp-login.php` answering 302) by IP and day;
- admin actions: `plugin-install`, `plugin-editor`, `theme-editor`, `user-new`, `async-upload`, REST `wp/v2/users` and `wp/v2/plugins` writes;
- scanners and probes (`.env`, `.git`, known webshell names), noted as background, plus the vulnerability's own request indicators.

**Error logs** (web server, PHP-FPM, `kern.log`, `syslog`): fatal errors, memory exhaustion, `Unknown on line 0`, segfaults, FPM children exiting on a signal, and the vulnerability's own error indicators.

**Server access:** accepted SSH logins by user and IP (`auth.log`, or `last`), `sudo` commands, `authorized_keys` of every account with their dates.

### Files

- Changed since the window start, by inode change time (it cannot be backdated): `find <docroots> -newerct '<date>' -not -path '*/cache/*' -not -path '*/wflogs/*'`.
- Executable types under uploads: `*.php*`, `*.phtml`, `*.phar`, `.htaccess`, `.user.ini`.
- Webshell signatures in PHP: `eval`, `assert` or `preg_replace /e` fed by `base64_decode`, `gzinflate`, `str_rot13` or `$_POST`/`$_GET`/`$_REQUEST`/`$_COOKIE`; command functions (`system`, `shell_exec`, `passthru`, `proc_open`) fed by request input; lines over 2000 characters outside known libraries.
- Integrity: `wp core verify-checksums`, `wp plugin verify-checksums --all`. Premium plugins have no public checksums: compare their file hashes between production and staging.
- PHP auto-loading: `auto_prepend_file` in `.user.ini` and PHP config, `mu-plugins/`.
- Sensitive files in docroots, to depth 8: `*.sql`, `*.sql.gz`, `*.zip`, `*.tar.gz`, `debug.log`, `.env`, `.git/`, `*.bak`, `.htdigest`. Check reachability with a ranged request (`curl -s -o /dev/null -w '%{http_code}' -r 0-0 <url>`).

### Database

Administrators and their creation dates, users created since the window start, application passwords (`wp user application-password list <user>`), open sessions (`wp user session list <user>`), options carrying code (`siteurl`, `home`, `active_plugins`, widgets and posts containing `<script` or `eval(`), and `wp cron event list`.

### Processes

Processes of the web user other than the PHP and web server workers, outbound connections (`ss -tnp state established`), listening sockets, and the crontabs of the web user and the site account.
