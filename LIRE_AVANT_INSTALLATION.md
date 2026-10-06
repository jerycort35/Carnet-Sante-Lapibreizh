# LapiGestion V3.1.47 — Application, licences et console

**Important : configure d’abord Cloudflare. Ne génère pas encore l’APK avec le fichier `lib/licence_config.dart` vide fourni.** Ce fichier doit être remplacé par le fichier public généré dans la console après la configuration du service.

Ce dossier complète le projet actuel ; il ne crée pas une nouvelle application Android. Base examinée : V3.1.46, commit `943fbd59419c30884b9e523831b0bc8860a80a4a` du dépôt `jerycort35/Carnet-Sante-Lapibreizh`.

## Ordre de mise en service

1. Conserve le ZIP et fais une sauvegarde de tes données depuis l’application actuellement installée. Garde aussi l’APK V46 précédente.
2. Suis `LICENCES/DEPLOIEMENT.md` pour le nouveau Worker LapiGestion, D1 et l’accès privé à la console. Aucun changement sur le Worker Les Lapibreizh existant.
3. Dans la page privée de préparation, génère les paramètres du service. Sauvegarde les secrets dans un endroit privé. Crée les deux secrets dans Cloudflare, puis télécharge le fichier **public** `licence_config.dart`.
4. Remplace `lib/licence_config.dart` par ce fichier téléchargé. Dans la console, crée ton profil **PROPRIÉTAIRE / ADMIN** et conserve sa clé avant la mise à jour de ton téléphone.
5. Copie les fichiers de ce ZIP aux mêmes emplacements dans ton projet actuel, sans supprimer les autres fichiers du dépôt. Aucun nouveau workflow ni nouvelle signature à ajouter. N’ajoute aucun secret Cloudflare dans GitHub.
6. Pousse toi-même les fichiers, comme habituellement. Le workflow Android actuel produira l’APK V47 avec la signature permanente existante.
7. Contrôle cette APK et installe-la par-dessus la version actuelle, **sans désinstaller**. Entre ta clé propriétaire. Tes fiches existantes restent présentes ; aucun lapin fictif n’est ajouté.
8. Effectue les vérifications sur téléphone décrites dans `LICENCES/VERIFICATION_ANDROID.md`, puis distribue l’APK et les clés utilisateurs.

## Contenu

- `lib/`, `assets/`, `pubspec.yaml` : application cumulant les correctifs existants et les licences.
- `android/app/src/main/kotlin/fr/leslapibreizh/carnetsante/` : pont Android et vérification cryptographique ; clé d’installation créée dans Android Keystore, différente de la clé de signature de l’APK.
- `lapigestion-admin/` : nouveau service Cloudflare, console, base SQL et scripts.
- `LICENCES/` : fonctionnement, déploiement, sauvegarde et vérification Android.
- `test/`, `VALIDATION_47/` : tests et résultats, distincts des données de production.

**Aucune APK finale signée n’est incluse.** La clé privée Android reste dans ton workflow actuel. Aucun déploiement, aucun push GitHub, aucune installation sur ton téléphone n’a été effectué depuis cet environnement.


## Ajout Essai 7 jours
Cette version ajoute une clé `trial` : accès complet pendant 7 jours à partir de la première activation, sur une seule installation. Avant de déployer le nouveau Worker sur une base existante, appliquer `lapigestion-admin/migrations/0002_trial_7_days.sql` une seule fois. Les licences existantes et l’accès propriétaire sont conservés.
