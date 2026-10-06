# Validation V3.1.47 — état livré

Base vérifiée en lecture seule sur GitHub : commit 943fbd59419c30884b9e523831b0bc8860a80a4a, V3.1.46. Le lib/main.dart récupéré localement correspondait octet pour octet à cette base avant les nouvelles modifications. Aucun push ni déclenchement du workflow effectué.

## Tests exécutés

- Service Cloudflare : 20 tests, SQLite en mémoire avec le vrai schéma, preuves d’installation et JWT Access signés avec de vraies clés RSA éphémères. Les requêtes JWKS sont simulées ; aucun déploiement D1 distant. Profils 1, 2, 3, 4 et propriétaire ; signatures ; faux JWT ; origine/CSRF ; clés uniques et hachées ; invalidité ; partage ; nonce rejoué ; révocation ; changement de niveau ; réinstallation ; séparation propriétaire ; sauvegarde ; limite de tentatives ; deux audiences Access.
- Suite Flutter complète : 67 tests passés. Inclut les tests des licences et les régressions des fonctions existantes : documents multipages, sauvegarde/restauration, saisie et zoom manuscrits par événements tactiles/stylet simulés, reproduction, décès au sevrage, répartition des couleurs, restrictions de croisements, adoption et interface à plusieurs largeurs/tailles de texte.
- Deux tests supplémentaires de l’écran d’accès : accueil propriétaire, retour Android simulé dans le navigateur interne, fermeture des routes après perte des droits et préservation des données/sauvegarde.
- Vérificateur Android : compilation des trois fichiers Kotlin contre les API Android 36 et les classes Flutter. 14 tests JVM du vrai vérificateur RSA : cinq profils, signature falsifiée, appareil/application étrangers, expiration, durée hors ligne excessive, niveau inconnu, propriétaire permanent, retour d’horloge et propriétaire après 100 ans. Le stub Base64 est réservé au test JVM ; Android Keystore matériel n’a pas été exécuté.
- Console : 8 parcours dans Chrome headless, API de console simulée. Création, propriétaire, révocation, niveau, récupération, recherche, largeur mobile sans débordement, génération RSA et téléchargement de configuration publique sans secret. Capture mobile inspectée. Aucune licence ni donnée fictive de production créée ; les noms visibles sur les captures sont uniquement des données de test.
- Analyse Dart : aucune erreur ; 19 diagnostics préexistants concernant casts, éléments inutilisés et API dépréciées. Pas de changement hors périmètre pour les supprimer.

## Préservation

premium_ui.dart est inchangé octet pour octet. Les algorithmes de tracé manuscrit, les cadres, la gestion multipage et les calculs des décès existants sont conservés. Les changements dans main.dart ajoutent des contrôles d’accès, le statut de reproducteur actif, le routage d’activation et l’accès à une sauvegarde en cas de blocage de licence.

Le Gradle de signature, le manifeste Android et le workflow GitHub sont identiques à la base actuelle. Même applicationId fr.leslapibreizh.carnetsante, même alias lapibreizh, mêmes secrets existants, versionCode augmenté à 47. Le ZIP n’inclut aucune clé privée ou licence de production.

## Ce qui reste à vérifier réellement

Aucune APK finale n’a été assemblée/signée dans cet environnement : clé privée maintenue dans le workflow de l’utilisateur. Aucun appareil Android connecté ; installation neuve, mise à jour par-dessus la V46, conservation réelle des données et signature binaire de la nouvelle APK ne sont donc pas certifiées ici. Déploiement Cloudflare, configuration Access réelle, connexion console en production et activation en ligne sur téléphone restent à faire avec les instructions jointes. Les tests au doigt/stylet sont des événements simulés, pas un essai sur le matériel de Jérémy.

Le service doit être déployé et le fichier PUBLIC licence_config.dart renseigné avant construction de l’APK. Il n’y a aucun mode de contournement des licences dans l’APK pour pallier une configuration manquante.

## Archive

Archive unique ZIP_STORED, noms simples et chemins relatifs, contrôle CRC puis extraction et comparaison octet pour octet de chaque fichier. MANIFEST_SHA256.txt fournit les empreintes des fichiers. Les outils locaux, caches, binaires de test, secrets, APK de référence et dépôt .git sont exclus.
