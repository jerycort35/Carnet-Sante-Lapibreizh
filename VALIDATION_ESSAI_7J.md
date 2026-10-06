# Validation — Essai 7 jours

- Backend Cloudflare : 23 tests automatisés réussis, dont activation trial, expiration fixe, récupération sans remise à zéro.
- JavaScript : vérification syntaxique réussie pour worker, console admin et bundle dashboard.
- Migration D1 : exercée par les tests SQLite à partir du schéma V47.
- Flutter : l'environnement local de cette session ne contient pas le SDK Flutter ; la compilation et les tests Flutter doivent donc être confirmés par le workflow GitHub habituel. Le projet est préparé en version `1.0.0+48`.
- `licence_config.dart` conserve l'URL et la clé publique déjà validées en production.

## Déploiement obligatoire dans cet ordre
1. Sauvegarder les licences depuis la console.
2. Appliquer `lapigestion-admin/migrations/0002_trial_7_days.sql` une fois sur la D1 existante.
3. Déployer `lapigestion-admin/worker-dashboard.mjs` sur le Worker existant.
4. Vérifier que la console affiche `Essai 7 jours · accès complet`.
5. Pousser cette archive dans le dépôt puis attendre le build vert.
