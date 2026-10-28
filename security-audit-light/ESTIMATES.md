# Estimates

The catalog of actions the check-up offers, for step 4 of [`SKILL.md`](SKILL.md). Every estimate in a report comes from here, so two clients pay the same for the same work. The agency keeps this file current; the ranges below are starting values to adjust after real jobs.

## Conditions

- **Hourly rate:** CHF [to fill in]. While blank, the report shows hours only.
- **Validity:** estimates valid 60 days from the report date.
- **Included in every action:** a full backup before the work, and a check of the site afterwards.
- **Maintenance plan:** mises à jour suivies et testées, surveillance du site et un check-up chaque année. Price: [to fill in]. While the price is blank, the report offers the plan without one.

## Actions

The label is the report's wording in French; translate it for another language. A range covers a typical site; above the stated size, add the extra line.

| Key | Label | Hours | Fixes |
|---|---|---|---|
| `wp-updates` | Mise à jour de WordPress, des extensions et du thème, avec tests | 1.5–3 (up to 20 plugins; +1 per further 10; +1–2 when plugins come through Composer: lock update and deploy) | pending updates, known vulnerabilities fixed by an update |
| `drupal-updates` | Mise à jour de Drupal (cœur et modules), avec tests | 2–4 (+1–2 for a minor core release, such as 11.3 → 11.4) | pending updates, security releases |
| `plugin-major` | Mise à jour majeure d'une extension ou d'un module (changements incompatibles) | 2–4 each | a fix only available in a new major version |
| `plugin-replace` | Remplacement d'une extension ou d'un module abandonné | 2–6 each | closed, unsupported or unmaintained component |
| `fork-sync` | Mise à niveau d'une extension adaptée sur sa version d'origine | 2–4 each | a fork pinned behind its source |
| `unpatched-vuln` | Mesure de protection contre une faille sans correctif (désactivation, règle de pare-feu) et suivi du correctif | 0.5–2 | a vulnerability with no fixed release |
| `core-upgrade` | Passage du CMS à une version majeure maintenue | 4–12 | core branch near or past end of support, majors behind |
| `php-upgrade` | Passage à une version de PHP maintenue | 3–8 | PHP branch past or near end of support |
| `js-deps` | Mise à jour des dépendances du frontend (Node, npm) | 2–6 | Node branch or npm packages with vulnerabilities |
| `exposed-files` | Suppression des fichiers exposés et blocage de leur accès | 0.5–1 | exposed secrets, backups, logs, deploy files, listings |
| `secret-rotation` | Changement des mots de passe et clés exposés | 1–2 | a secret that was downloadable |
| `headers` | En-têtes de sécurité manquants | 1 | missing headers, header version disclosure |
| `csp` | Politique de sécurité du contenu (CSP) | 2–4 | no CSP |
| `hardening` | Durcissement du CMS (version affichée, pages d'installation, liste des utilisateurs, XML-RPC, inscriptions) | 0.5–1 | version disclosure, installer pages, user listing, XML-RPC, open registration |
| `login-protection` | Protection de la connexion (double authentification, limitation des essais) | 1–2 | login page open to all |
| `https` | Correction HTTPS et renouvellement automatique du certificat | 0.5–1 | redirect, certificate, old TLS, mixed content |
| `email-auth` | Configuration SPF, DKIM et DMARC | 1–2 | missing or weak email authentication |
| `admin-cleanup` | Revue des comptes administrateurs | 0.5 | former staff accounts |
| `backups` | Mise en place des sauvegardes externes et test de restauration | 2–3 | no backups, or backups on the same server |
| `monitoring` | Surveillance de disponibilité et d'expiration du certificat | 0.5 | no warning before downtime or expiry |
| `full-audit` | Audit de sécurité complet (journaux, fichiers, base de données) | 4–8 | signs of compromise, or a vulnerability exploited in the wild |
