# Hosting types

Where each hosting type keeps its logs and what it hides. The project memory note from step 7 of [`SKILL.md`](SKILL.md) records the specifics of each host; this file covers what holds across hosts of one type.

## Own VPS (Ubuntu, nginx, PHP-FPM)

- Logs: `/var/log/nginx/<vhost>-{access,error}.log*`, often 14 days of daily rotation, `combined` format (no request size or body). PHP errors of a pool land in the nginx error log as FastCGI stderr; `/var/log/php*-fpm.log*` is root-only and rotates weekly.
- Patch time: `/var/log/dpkg.log*`, and the FPM restart in the FPM log.
- Several sites often share one FPM pool and one web user: a compromise of one reaches the others, so the audit covers every vhost on that pool.
- Docroots are usually readable only with `sudo`.

## Infomaniak shared hosting and Cloud Managé

- Logs: `~/ik-logs/`, one file for all vhosts with the vhost as the first field. Access logs keep about 30 days; error and PHP-FPM logs about 7.
- No `sudo`, often no view of the PHP-FPM processes, no journald.
- Infomaniak patches PHP in place without changing the version string. Prove the patch with the PHP binary's build date and modification time, not the version.
- Maintenance mode turns a basic-auth `401` into a `503`, so browsers never show the login prompt.
- Self-hosted Node frontends behind Infomaniak's HAProxy do not appear in `ik-logs`; their logs are files in the site folder.

## Infomaniak Cloud with Docker

- The image ships its own PHP: host-side patches never reach it, only an image rebuild and redeploy does.
- Container logs are wiped at each redeploy, and the load balancer and Varnish logs belong to Infomaniak. The vulnerable period before a redeploy usually has no log: state it as a limit and recommend rotating the site's secrets.
- Old anonymous volumes can survive a redeploy and hold the previous container's files.
- Persistent uploads live on a separate shared-storage host; check them there.

## Cloudways

- Logs: `~/applications/<app-id>/logs/`, one folder per application, named by an id rather than the domain; map ids to domains from the vhost config.
- Security tooling logs (Imunify360) may exist under `/var/log/` without being readable.

## Serverless frontends (Vercel, Netlify)

A static or Next.js frontend there runs no PHP: list it in the report as not exposed to a PHP vulnerability, and audit its backend instead.
