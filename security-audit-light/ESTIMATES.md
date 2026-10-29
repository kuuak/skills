# Estimates

The catalog of actions the check-up offers, for step 4 of [`SKILL.md`](SKILL.md). Every estimate in a report comes from here, so two clients pay the same for the same work. The agency keeps this file current; the ranges were set from a first panel of nine check-ups (10.2026) and get adjusted after real jobs.

## Conditions

- **Hourly rate:** CHF [to fill in]. While blank, the report shows hours only.
- **Validity:** estimates valid 60 days from the report date.
- **Included in every action:** a full backup before the work, and a check of the site afterwards.
- **Maintenance plan:** mises à jour suivies et testées, surveillance du site et un check-up chaque année. Price: [to fill in]. While the price is blank, the report offers the plan without one.

## Reading the ranges

- A range covers a typical site; add the extra lines that apply.
- **Our stacks:** the agency estimates WordPress and Next.js/React work. An action on any other stack (Drupal, another CMS or framework) reads "à discuter" ("to be discussed") in the hours column and stays out of the sums.
- **Headless** (a WordPress backend behind a Next.js or other frontend): each upgrade is tested against the frontend too, so add the headless line where an action has one.
- **Order:** plugin fixes that need a newer core come after the core upgrade; say so under the order table when it applies.
- **Labels in parentheses** list examples: in the report, keep only the items this site's findings name.

## Actions

The label is the report's wording in French; translate it for another language.

### Updates and upgrades

| Key | Label | Hours | Fixes |
|---|---|---|---|
| `wp-updates` | Mise à jour de WordPress, des extensions et du thème, avec tests | 1–2 (up to 10 pending updates; +1 per further 10; +1 when plugins come through Composer; +2 headless) | pending updates, known vulnerabilities fixed by an update |
| `drupal-updates` | Mise à jour de Drupal (cœur et modules), avec tests | à discuter | pending updates, security releases |
| `wp-core-major` | Passage de WordPress à la version majeure actuelle | 3–6 (+2 headless) | core two or more majors behind, plugin fixes that need a newer core |
| `core-upgrade` | Passage du CMS à une version majeure maintenue | à discuter | a non-WordPress core near or past end of support (such as Drupal 10 → 11) |
| `plugin-major` | Mise à jour majeure d'une extension ou d'un module (changements incompatibles) | 2–4 each | a fix only available in a new major version |
| `plugin-replace` | Remplacement d'une extension ou d'un module abandonné | 1–2 each for a single-purpose plugin; 2–6 when it shapes the front end | closed, unsupported or unmaintained component |
| `fork-sync` | Mise à niveau d'une extension adaptée sur sa version d'origine | 2–4 each | a fork pinned behind a living source |
| `fork-adopt` | Reprise d'une extension abandonnée par son auteur (maintenance de notre copie) | 2–4 each | a fork whose source is dead |
| `headless-api` | Mise à jour de la couche API du site (WPGraphQL et ses extensions) et des requêtes du frontend | 4–8 | WPGraphQL or its add-ons majors behind, archived add-ons |
| `unpatched-vuln` | Mesure de protection contre une faille sans correctif (désactivation, règle de pare-feu) et suivi du correctif | 0.5–2 | a vulnerability with no fixed release |
| `php-upgrade` | Passage à une version de PHP maintenue | 1–3 where PHP is a hosting-panel setting (+1 per further app on the same server); 3–6 on a self-managed server or Docker image | PHP branch past or near end of support |
| `next-upgrade` | Passage de Next.js à une version maintenue | 4–8 (+4–8 when it brings React 19 or an App Router migration) | Next.js major past end of support |
| `js-deps` | Mise à jour des dépendances du frontend (Node, npm) | 2–6 | Node branch or npm packages with vulnerabilities, within the same framework major |

### Exposure and access

| Key | Label | Hours | Fixes |
|---|---|---|---|
| `exposed-files` | Suppression des fichiers exposés et des anciennes sauvegardes, et blocage de leur accès | 0.5–1 | exposed secrets, backups (`.sql`, `.wpress`), logs, deploy files, listings, leftovers on the server |
| `secret-rotation` | Changement des mots de passe et clés exposés | 1–2 | a secret that was downloadable |
| `access-control` | Protection des contenus et fichiers réservés (règles d'accès de l'API, pièces jointes privées) | 2–5 | members-only data readable through the API, private uploads public by URL |
| `staging-lockdown` | Protection ou suppression de la copie de test publique | 0.5–1 (+1–2 when it holds production data to purge) | a public staging or test copy |
| `headers` | En-têtes de sécurité manquants | 0.5–1 (0.5 when they are one framework config block) | missing headers, header version disclosure |
| `csp` | Politique de sécurité du contenu (CSP) | 2–4; 3–6 with a tag manager or many third-party services | no CSP |
| `hardening` | Durcissement du CMS (version affichée, pages d'installation, liste des utilisateurs, XML-RPC, inscriptions) | 0.5–1 | version disclosure, installer pages, user listing (REST or GraphQL), XML-RPC, open registration |
| `login-protection` | Protection de la connexion (double authentification, limitation des essais) | 1–2 | login page open to all |
| `admin-cleanup` | Revue des comptes administrateurs | 0.5 | former staff or agency accounts |

### Hosting, network and email

| Key | Label | Hours | Fixes |
|---|---|---|---|
| `https` | Correction de la configuration HTTPS | 0.5–1 (0.5 when it is a CDN setting) | redirect, certificate renewal, old TLS, mixed content |
| `cdn-origin` | Passage de tout le trafic par le CDN et fermeture du serveur aux accès directs | 1–2 | origin reachable around the CDN |
| `server-hardening` | Nettoyage et durcissement du serveur (ports internes, permissions, anciennes versions et sauvegardes) | 0.5–2 | internal ports open to all, keys or dumps readable by other accounts, unused old runtimes |
| `host-request` | Demande à l'hébergeur d'un serveur à jour, et contrôle du site après le déplacement | 0.5–1 | a host-managed OS or database past support, where the host can move the site |
| `hosting-migration` | Migration vers un serveur ou une base de données maintenus | 2–4 (+1 per further site on the same hosting) | an OS or database past support that only a move fixes |
| `email-auth` | Configuration SPF, DKIM et DMARC | 1–2 | missing or weak email authentication, SPF at the lookup limit |
| `backups` | Mise en place des sauvegardes externes et test de restauration | 2–3 | no backups, or backups on the same server |
| `monitoring` | Surveillance de disponibilité et d'expiration du certificat | 0.5 | no warning before downtime or expiry |

### Incidents

| Key | Label | Hours | Fixes |
|---|---|---|---|
| `full-audit` | Audit de sécurité complet (journaux, fichiers, base de données) | 4–8; 8–16 when a compromise is confirmed or logs are lost on each rebuild | signs of compromise, or a vulnerability exploited in the wild |
| `incident-cleanup` | Nettoyage après intrusion (suppression du code malveillant, réinstallation du cœur et des extensions, changement des accès) | 4–8 | a confirmed compromise |
