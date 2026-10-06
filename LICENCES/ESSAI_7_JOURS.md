# Essai LapiGestion — 7 jours complets

Cette version ajoute un niveau technique `trial` destiné aux personnes qui veulent découvrir LapiGestion avant de choisir leur niveau définitif.

- L'essai donne accès à **toute l'application**, y compris le mode Élevage et les fonctions sans limite.
- Les 7 jours commencent **à la première activation de la clé**, pas au moment où la clé est créée.
- La clé reste liée à une seule installation, comme les autres licences.
- Une récupération vers un nouvel appareil **ne remet pas les 7 jours à zéro**.
- Les renouvellements en ligne n'allongent pas la période : la date de fin reste fixe.
- À l'expiration, les données sont conservées et l'utilisateur peut activer une clé définitive de niveau 1 à 4.
- Le profil propriétaire reste permanent et inchangé.

## Ordre de déploiement sur le service déjà en production

1. Sauvegarder les licences depuis LapiGestion Admin.
2. Appliquer **une seule fois** `lapigestion-admin/migrations/0002_trial_7_days.sql` sur la base D1 existante.
3. Déployer le nouveau `lapigestion-admin/worker-dashboard.mjs` sur le Worker existant, sans changer les secrets ni les variables.
4. Vérifier la console : le choix **Essai 7 jours · accès complet** doit apparaître.
5. Pousser les fichiers Flutter/Android de la version +48 et attendre le build vert.
6. Installer l'APK par-dessus la version actuelle et vérifier que le profil propriétaire reste actif.
7. Créer une clé d'essai et la tester sur une installation disponible.

Ne régénère ni `SIGNING_PRIVATE_JWK`, ni `RATE_PEPPER`, ni `licence_config.dart` : cette évolution conserve l'infrastructure existante.
