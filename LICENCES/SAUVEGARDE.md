# Sauvegarder et restaurer les licences

## À conserver

1. Depuis la console : « Sauvegarder les licences » télécharge un JSON contenant les licences, leurs hashes de clés, niveaux, états, associations d’installation et historique administrateur. Aucun code d’activation complet n’y figure.
2. Conserve séparément la sauvegarde privée des clés du service, générée à sa préparation : SIGNING_PRIVATE_JWK, clé publique et RATE_PEPPER. La sauvegarde des licences ne suffit pas sans cette clé privée.
3. Note l’URL du Worker, la configuration Access et le binding D1. Sauvegarde les licences après des créations ou changements importants. Les secrets ne doivent pas être publiés avec les fichiers du projet.
4. Les sauvegardes de fiches/photos faites dans l’application sont indépendantes des sauvegardes de licences.

## Restauration après incident

Crée une **nouvelle base D1 vide**, exécute le schéma `0001_licences.sql`, puis convertis ta sauvegarde en SQL :

```sh
node lapigestion-admin/scripts/restore-backup.mjs LapiGestion.backup.json restauration.sql
```

Le script refuse d’écraser un fichier SQL existant et n’écrit aucun DELETE ou DROP. Exécute ce SQL uniquement sur la nouvelle base vide. Il conserve les IDs, hashes et associations : les utilisateurs déjà activés peuvent renouveler leurs preuves. Une clé perdue peut être remplacée via la console ; son texte ne peut pas être reconstitué depuis le hash.

Remets la **même clé privée de signature**, la même URL et la configuration Access, puis associe le Worker à la base restaurée. Compare le nombre de licences et vérifie niveau/état de plusieurs entrées avant de basculer. Ne change pas la clé privée pour « réparer » un problème de configuration : les APK possèdent sa clé publique et rejetteraient une nouvelle signature.

Alternative avec Wrangler : export SQL complet (`wrangler d1 export lapigestion-licences --remote --output sauvegarde.sql`), à conserver en privé. La procédure JSON ci-dessus fonctionne indépendamment des dumps SQL.

Pour le propriétaire : une installation déjà activée conserve son accès permanent hors ligne. Après réinstallation, il faut retrouver la console administrateur pour réassocier l’accès propriétaire. Conserve donc l’accès à la messagerie administrateur et aux sauvegardes Cloudflare.
