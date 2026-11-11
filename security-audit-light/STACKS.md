# Stacks

The CMS-specific half of [`CHECKS.md`](CHECKS.md). Tell the stack from the home page: `/wp-content/` paths or a WordPress generator tag mean WordPress; `/core/` and `/sites/default/files/` paths or `X-Generator: Drupal` mean Drupal; `/_next/` paths or `x-nextjs-cache` mean Next.js. Run that section only; a Next.js site fed by WordPress also runs the headless and WordPress sections. For another CMS or framework, find its equivalent of each heading below and tell the user which ones you used.

## WordPress

**Versions.** Core: the `generator` meta tag, `<generator>` in `<site>/feed/`, `<site>/readme.html`. Plugins and themes: slugs from `/wp-content/plugins/<slug>/` and `/wp-content/themes/<slug>/` paths. `?ver=` on their assets is a hint only: some plugins put a timestamp or their asset's own version there. `<site>/wp-content/plugins/<slug>/readme.txt` gives the "Stable tag" when it is reachable.

**Exposed files.** `wp-config.php.bak`, `wp-config.php~`, `wp-config.old`, `wp-content/debug.log`, `wp-content/backup-db/`, `wp-content/updraft/`, `wp-content/ai1wm-backups/`, `readme.html`, and an `Index of` page on `wp-content/uploads/` or `wp-content/plugins/`. All-in-One WP Migration's `.wpress` archives carry a random suffix: a blocked listing of `ai1wm-backups/` still lets them download, and only the server finds their names.

**Surface.**

- users listed: `<site>/wp-json/wp/v2/users` returning login slugs, or `<site>/?author=1` redirecting to `/author/<login>/`;
- XML-RPC: `<site>/xmlrpc.php` answering `405` with "XML-RPC server accepts POST requests only" means it is enabled;
- login page: `<site>/wp-login.php` reachable from anywhere, or behind basic auth, an IP filter or a renamed path; note a CAPTCHA when the page shows one;
- registration: `<site>/wp-login.php?action=register` showing a form means it is open.

**Status and vulnerabilities.**

- Plugin status on wordpress.org (brackets URL-encoded): `curl -s 'https://api.wordpress.org/plugins/info/1.2/?action=plugin_information&request%5Bslug%5D=<slug>'` returns `"closed": true` with date and reason for a closed plugin, and `version`, `requires` (the core it needs) and `last_updated` otherwise. Premium plugins are absent: read their vendor changelog. Plugins published only on GitHub are in no database: read the repo's releases, and an archived repo means unmaintained.
- Vulnerabilities: Patchstack's public pages, `https://patchstack.com/database/wordpress/plugin/<slug>` (and `/theme/<slug>`), list each vulnerability with its affected and fixed versions, and mark the ones with no fix yet. A page of about 900 bytes with no list is Patchstack's block page, not "no vulnerabilities": wait and go on at the [pace](CHECKS.md#pace). `composer audit` stays silent on `wpackagist-plugin/*` packages, so an empty result proves nothing. Wordfence's feed needs an API key and WPScan's a token: use them only when the user has one.
- A site whose plugins come through Composer (`wpackagist-plugin/*` or a forked plugin in `composer.json`) is updated through its lock file and a deploy: note it for the estimate.

**Server.**

- `wp --version` first: the `auto_update` field needs WP-CLI 2.7; on older ones read the `auto_update_plugins` option. When the CLI's default PHP differs from the site's, call `php8.x $(which wp)`; `php -d error_reporting=0 $(which wp)` silences deprecation floods.
- `wp core version`, `wp plugin list --fields=name,version,update_version,status,auto_update`, `wp user list --role=administrator --fields=user_login,user_email,user_registered`. `update_version` stays empty when the update needs a newer core: compare each version with the wordpress.org API above.
- `wp core verify-checksums` and `wp plugin verify-checksums --all`. Host artefacts fail them without a compromise: Cloudways's `wp-salt.php`, a removed or renamed `readme.html`, the Docker image's `wp-config-docker.php`; our own forked plugins fail too, so compare those with the fork's repo.
- Unknown PHP files: `verify-checksums` names only extra `wp-*` files in the root. List the root's PHP files (`ls *.php`) and every PHP file under `wp-content/` outside plugins and themes (`find wp-content -name '*.php*' -not -path '*/plugins/*' -not -path '*/themes/*'`). Open each one that core and the repo do not explain. Some plugins drop empty `index.php` placeholders under uploads; those are harmless.
- In Docker, run each command as `docker exec <container> wp --allow-root …`, find the web root on the container's volume (`docker inspect <container>`), and read logs with `docker logs`: they go back only to the container's last creation.

**Compromise signs.** A PHP file with content under `wp-content/uploads/`.

## Headless WordPress

A WordPress backend behind a Next.js or other frontend: the frontend's host serves the pages, the backend's serves the admin and the API.

- **Backend:** its URL from the repo's environment and config (`WORDPRESS_URL` and the like, `next.config.js` rewrites, `ecosystem.config.js`) or from the asset hosts in the page. Run the outside checks and the WordPress section there, and the Next.js section on the frontend.
- **User listing over GraphQL:** `curl -s '<backend>/graphql?query=%7Busers%7Bnodes%7Bslug%7D%7D%7D'` returning slugs, even when `wp-json` is blocked.
- **Members-only data:** the frontend can gate content the API serves to anyone. From the repo, list the routes the frontend gates and the post types and fields they read, then query those anonymously over GraphQL and REST. With SSH, `wp post-type list --fields=name,public,show_in_rest,show_in_graphql` lists what the API exposes.

## Next.js

**Versions.** The outside shows none: take `next`, `react` and the other dependencies from the repo's lock file, and Node from `.nvmrc`, `engines` in `package.json`, or the host's settings. With SSH, `node -v` and the deployed `node_modules/next/package.json`.

**Exposed files.** `package.json`, `package-lock.json`, `.next/BUILD_ID`, `environments.json`, `ecosystem.config.js`, `.env.local`, `.env.production`, and source maps (`<script>.js.map` beside a script).

**Status and vulnerabilities.** Support from endoflife.date's `nextjs` and `nodejs`. Vulnerabilities from OSV for the npm ecosystem: `npm audit --package-lock-only` in the repo, or `curl -s -d '{"package":{"name":"next","ecosystem":"npm"},"version":"<version>"}' https://api.osv.dev/v1/query` per package. Many Next.js advisories need a host or feature to apply (self-hosted image optimisation, a middleware-only check): read each one's conditions, as [`CHECKS.md`](CHECKS.md#stack) says.

**Server.** On a self-managed server: `node -v`, the process manager's list (`pm2 ls`, `docker ps`), and the ports listening on all interfaces (`ss -tlnp`).

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
