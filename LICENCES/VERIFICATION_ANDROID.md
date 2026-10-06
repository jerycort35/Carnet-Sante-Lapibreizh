# APK, signature et tests sur téléphone

Base : application `fr.leslapibreizh.carnetsante`, alias de signature `lapibreizh`. `android/app/build.gradle`, le manifeste et `.github/workflows/build_apk.yml` ont été conservés ; seuls trois fichiers Kotlin nécessaires aux licences sont ajoutés/modifiés. La version passe de `1.0.0+46` à `1.0.0+47`.

Les secrets de signature permanents existants restent `LAPIBREIZH_KEYSTORE_B64` et `LAPIBREIZH_KEYSTORE_PASSWORD`. Ne remplace ni ces secrets ni le keystore. La clé d’installation Android Keystore des licences est **distincte** et ne change pas la signature de l’APK.

L’empreinte SHA-256 relevée précédemment sur ton APK de référence est :

`54d2b9c7de7c8997f64e24bab95627adbca4684b36fda9a7d45c909b5b63c892`

L’APK finale ne peut pas être signée ici avec la clé privée qui reste dans ton workflow. La compilation Kotlin vérifie les nouvelles classes, pas l’assemblage Gradle complet ni une installation réelle. Aucun téléphone ou émulateur Android n’est connecté dans cet environnement.

## Contrôle après génération avec le workflow existant

Sur un ordinateur avec Android SDK Build Tools, `apksigner verify --verbose --print-certs app-release.apk` doit confirmer une signature valide et exactement la même empreinte que ton APK actuel. `aapt dump badging app-release.apk` doit afficher `fr.leslapibreizh.carnetsante`, versionCode `47`, label LapiGestion ; aucune variante debug à distribuer.

Sauvegarde tes données dans la V46 avant toute opération. Installe ensuite la V47 **par-dessus**, sans désinstaller. L’autorisation Android pour une source externe est normale. Si Android annonce que l’application est incompatible avec le paquet déjà installé, arrête : ne désinstalle pas pour contourner le problème ; vérifie la signature et l’identifiant.

## Parcours à tester avant distribution

| Test | Résultat attendu |
|---|---|
| Mise à jour de ton téléphone V46 → V47 | Installation acceptée, anciennes fiches conservées |
| Clé propriétaire préparée avant la mise à jour | Toutes les fonctions, aucun quota, maintien après redémarrage/hors ligne |
| Installation neuve sur un autre appareil | Aucun lapin fictif, activation requise |
| Niveau 1 | Première fiche acceptée, seconde refusée, mode Élevage interdit |
| Niveau 2 | Plusieurs fiches acceptées, mode Élevage interdit |
| Niveau 3 | Plusieurs fiches, Élevage, deux reproducteurs actifs ; troisième refusé |
| Niveau 4 | Élevage et nombreux reproducteurs acceptés |
| Nouvelle saillie niveau 3 | Deux partenaires actifs nécessaires |
| Clé invalide, inexistante, révoquée | Message explicite, aucune activation abusive |
| Même clé sur deux installations | Première liée, seconde refusée |
| Mise à niveau depuis la console | Nouveau niveau au contrôle en ligne suivant |
| Réinstallation utilisateur et propriétaire | Récupération via console, nouvelle clé ; restauration des fiches séparée |
| Déclassement vers niveau 1 avec plusieurs fiches | Aucune perte automatique, consultation/sauvegarde, restriction des écritures |
| Absence Internet | Droits utilisateurs encore valides pendant la période hors ligne ; propriétaire déjà activé permanent |
| Révocation pendant utilisation | Retour à l’écran d’accès après contrôle, données préservées et sauvegardables |
| Manuscrit au doigt et au stylet réel | Plusieurs tracés, mention/signature indépendantes, zoom et défilement |
| Régressions | Documents multipages, décès naissance/sevrage, couleurs, adoption, PDF, notifications et sauvegarde/restauration |

Ces vérifications matérielles et le déploiement réel Cloudflare restent à réaliser. Les tests automatiques et leur résultat exact sont dans `VALIDATION_47/RAPPORT.md`.
