# Estimates

The catalog of actions the check-up offers, for step 4 of [`SKILL.md`](SKILL.md). Every estimate in a report comes from here, so two clients pay the same for the same work. The agency keeps this file current; the ranges below are starting values to adjust after real jobs.

## Conditions

- **Hourly rate:** CHF [to fill in]. While blank, the report shows hours only.
- **Validity:** estimates valid 60 days from the report date.
- **Included in every action:** a full backup before the work, and a check of the site afterwards.
- **Maintenance plan:** [one or two sentences on the agency's plan and its monthly price]. While blank, the report offers the plan without a price.

## Actions

The label is the report's wording in French; translate it for another language. A range covers a typical site; above the stated size, add the extra line.

| Key | Label | Hours | Fixes |
|---|---|---|---|
| `wp-updates` | Mise à jour de WordPress, des extensions et du thème, avec tests | 1.5–3 (up to 20 plugins; +1 per further 10) | pending updates, known vulnerabilities fixed by an update |
| `plugin-major` | Mise à jour majeure d'une extension (changements incompatibles) | 2–4 per plugin | a fix only available in a new major version |
| `plugin-replace` | Remplacement d'une extension abandonnée | 2–6 per plugin | closed or unmaintained plugin |
| `php-upgrade` | Passage à une version de PHP maintenue | 3–8 | PHP branch past or near end of support |
| `js-deps` | Mise à jour des dépendances du frontend (Node, npm) | 2–6 | Node branch or npm packages with vulnerabilities |
| `exposed-files` | Suppression des fichiers exposés et blocage de leur accès | 0.5–1 | exposed secrets, backups, logs, listings |
| `secret-rotation` | Changement des mots de passe et clés exposés | 1–2 | a secret that was downloadable |
| `headers` | En-têtes de sécurité (HSTS, protection contre l'intégration, etc.) | 1 | missing headers, version disclosure |
| `csp` | Politique de sécurité du contenu (CSP) | 2–4 | no CSP |
| `wp-hardening` | Durcissement WordPress (XML-RPC, liste des utilisateurs, version affichée) | 0.5–1 | XML-RPC, user listing, `readme.html`, generator tag |
| `login-protection` | Protection de la connexion (double authentification, limitation des essais) | 1–2 | login page open to all |
| `https` | Correction HTTPS et renouvellement automatique du certificat | 0.5–1 | redirect, certificate, old TLS, mixed content |
| `email-auth` | Configuration SPF, DKIM et DMARC | 1–2 | missing or weak email authentication |
| `admin-cleanup` | Revue des comptes administrateurs | 0.5 | former staff accounts |
| `backups` | Mise en place des sauvegardes externes et test de restauration | 2–3 | no backups, or backups on the same server |
| `monitoring` | Surveillance de disponibilité et d'expiration du certificat | 0.5 | no warning before downtime or expiry |
| `full-audit` | Audit de sécurité complet (journaux, fichiers, base de données) | 4–8 | signs of compromise, or a vulnerability exploited in the wild |
