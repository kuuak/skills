# Stacks

The CMS-specific half of [`CHECKS.md`](CHECKS.md). Tell the CMS from the home page: `/wp-content/` paths or a WordPress generator tag mean WordPress; `/core/` and `/sites/default/files/` paths or `X-Generator: Drupal` mean Drupal. Run that section only. For another CMS or framework, find its equivalent of each heading below and tell the user which ones you used.

## WordPress

**Versions.** Core: the `generator` meta tag, `<generator>` in `<site>/feed/`, `<site>/readme.html`. Plugins and themes: slugs from `/wp-content/plugins/<slug>/` and `/wp-content/themes/<slug>/` paths. `?ver=` on their assets is a hint only: some plugins put a timestamp or their asset's own version there. `<site>/wp-content/plugins/<slug>/readme.txt` gives the "Stable tag" when it is reachable.

**Exposed files.** `wp-config.php.bak`, `wp-config.php~`, `wp-config.old`, `wp-content/debug.log`, `wp-content/backup-db/`, `wp-content/updraft/`, `readme.html`, and an `Index of` page on `wp-content/uploads/` or `wp-content/plugins/`.

**Surface.**

- users listed: `<site>/wp-json/wp/v2/users` returning login slugs, or `<site>/?author=1` redirecting to `/author/<login>/`;
- XML-RPC: `<site>/xmlrpc.php` answering `405` with "XML-RPC server accepts POST requests only" means it is enabled;
- login page: `<site>/wp-login.php` reachable from anywhere, or behind basic auth, an IP filter or a renamed path; note a CAPTCHA when the page shows one;
- registration: `<site>/wp-login.php?action=register` showing a form means it is open.

**Status and vulnerabilities.**

- Plugin status on wordpress.org (brackets URL-encoded): `curl -s 'https://api.wordpress.org/plugins/info/1.2/?action=plugin_information&request%5Bslug%5D=<slug>'` returns `"closed": true` with date and reason for a closed plugin, and `version` and `last_updated` otherwise. Premium plugins are absent: read their vendor changelog.
- Vulnerabilities: Patchstack's public pages, `https://patchstack.com/database/wordpress/plugin/<slug>` (and `/theme/<slug>`), list each vulnerability with its affected and fixed versions, and mark the ones with no fix yet. `composer audit` stays silent on `wpackagist-plugin/*` packages, so an empty result proves nothing. Wordfence's feed needs an API key and WPScan's a token: use them only when the user has one.
- A site whose plugins come through Composer (`wpackagist-plugin/*` or a forked plugin in `composer.json`) is updated through its lock file and a deploy: note it for the estimate.

**Server.** `wp core version`, `wp plugin list --fields=name,version,update_version,status,auto_update`, `wp core verify-checksums`, `wp plugin verify-checksums --all`, `wp user list --role=administrator --fields=user_login,user_email,user_registered`, and PHP files with content under uploads: `find wp-content/uploads -name '*.php*' -size +0`. Some plugins drop empty `index.php` placeholders there; those are harmless.

**Compromise signs.** A PHP file with content under `wp-content/uploads/`.

## Drupal

**Versions.** `X-Generator` gives the major version only. The exact core version shows as `?v=<version>` on the assets of `<site>/core/install.php`, which is itself a version disclosure when it answers `200`. `CHANGELOG.txt` holds no version since Drupal 8. Modules and themes show by name in `/modules/contrib/<name>/` and `/themes/contrib/<name>/` paths, without a version.

**Exposed files.** `sites/default/settings.php.bak`, `settings.php~`, `settings.php.old`, `sites/default/settings.local.php`, `core/install.php`, `update.php`, `README.md`, and an `Index of` page on `sites/default/files/`.

**Surface.**

- users listed: `<site>/jsonapi/user/user` returning names, or `<site>/user/1` showing the username in its title;
- registration: `<site>/user/register` showing a form means it is open;
- login page: `<site>/user/login` reachable from anywhere; note a CAPTCHA when the page shows one.

**Status and vulnerabilities.** `curl -s https://updates.drupal.org/release-history/<project>/current` (the core project is `drupal`) lists each release with its terms ("Security update", "Insecure") and the project's support status. Advisories: SA-CORE and SA-CONTRIB on `https://www.drupal.org/security`. A module whose version the outside cannot show still counts when a security release came out after the last delivery (see [`RUBRIC.md`](RUBRIC.md)).

**Server.** `drush status`, `drush pm:list --status=enabled --format=table`, `drush pm:security`, and PHP files under `sites/default/files/`.

**Compromise signs.** A PHP file with content under `sites/default/files/`.
