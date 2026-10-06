# Déploiement du nouveau service LapiGestion

Ne touche pas au Worker Les Lapibreizh. Utilise uniquement le projet **lapigestion-admin** séparé. Si le Worker Hello World `lapigestion-admin` existe déjà, il peut recevoir ce code ; il ne faut pas le remplacer par le Worker du site Les Lapibreizh.

## Méthode depuis le tableau de bord Cloudflare

1. Crée une base D1 **lapigestion-licences**. Dans sa console SQL, exécute `lapigestion-admin/migrations/0001_licences.sql` puis `0002_trial_7_days.sql` **dans cet ordre sur une base neuve**. Ce schéma ne contient aucune licence ni donnée de démonstration.
2. Dans les paramètres du Worker `lapigestion-admin`, ajoute un binding D1 nommé exactement **DB**, vers cette base. Note l’URL HTTPS exacte du Worker, sans slash final.
3. Dans Cloudflare Zero Trust / Access, protège le Worker pour l’administration et conserve deux exceptions publiques de chemin (`overrides`) : `/api/challenge` et `/api/authorize`. Ces deux routes doivent rester publiques pour l’APK ; `/admin/*` et `/api/admin/*` restent protégés.
4. La règle Allow doit autoriser **uniquement ton adresse e-mail**. Ne mets pas de règle Everyone ou Bypass. Privilégie un fournisseur d’identité avec authentification à deux facteurs. Tu peux aussi utiliser le code à usage unique envoyé par Access à l’adresse autorisée ; sécurise alors cette messagerie avec une authentification forte.
5. Dans les variables texte du Worker, renseigne :

| Nom | Valeur |
|---|---|
| PUBLIC_ORIGIN | URL HTTPS du Worker, sans slash final |
| ACCESS_TEAM | `https://TON-EQUIPE.cloudflareaccess.com`, sans slash final |
| ACCESS_AUD | Audience de l’application Access ; deux audiences séparées par une virgule si deux applications |
| ADMIN_EMAIL | Ton adresse e-mail exacte autorisée |

6. Dans l’éditeur du Worker LapiGestion, colle tout le contenu de **`lapigestion-admin/worker-dashboard.mjs`**, puis déploie. Ce fichier contient le backend et la console ; il fonctionne sans binding ASSETS. Ne colle pas uniquement `src/worker.mjs` depuis le téléphone : cette variante nécessite les fichiers statiques séparés.
7. Ouvre `https://TON-WORKER/admin/`. Access doit demander une connexion. Une fenêtre privée non connectée ne doit pas accéder aux licences. Le backend refuse aussi un faux simple en-tête d’identité : il vérifie la signature, l’audience et l’émetteur du JWT Access.
8. Ouvre « Préparation du service ». Génère les paramètres **une seule fois**. Télécharge la sauvegarde privée et mets-la à l’abri. Copie les valeurs dans deux **secrets** du Worker :

| Secret | Contenu |
|---|---|
| SIGNING_PRIVATE_JWK | JSON complet de la clé privée générée |
| RATE_PEPPER | Valeur aléatoire générée |

9. Enregistre/déploie les secrets. Ne mets aucun de ces secrets dans GitHub ni dans un fichier Dart. Ne régénère pas la clé serveur à chaque version de l’application.
10. Télécharge `licence_config.dart` dans la page de préparation et remplace `lib/licence_config.dart` avec ce fichier **public**. Il contient l’URL et la clé publique uniquement. Après fermeture de la page, les valeurs privées peuvent être récupérées dans ta sauvegarde privée ; ne clique pas à nouveau sur Générer pour remplacer la clé par inadvertance.
11. Dans la console, crée ton profil propriétaire et conserve sa clé. Vérifie également la création d’une licence utilisateur et le téléchargement d’une sauvegarde JSON. Les clés de test créées sur le service réel sont de vraies licences : révoque-les si elles ne servent plus.
12. Ajoute un déclencheur Cron `17 * * * *` au Worker pour purger les défis expirés et compteurs temporaires.
13. Intègre les fichiers de l’application au dépôt actuel et génère l’APK avec **le workflow existant**. Aucun nouveau workflow à ajouter. Fais les tests sur téléphone avant distribution.

## Mise à niveau d’une base déjà en service

Pour une installation LapiGestion déjà fonctionnelle avec des licences existantes, **n’exécute pas de nouveau `0001`**. Applique uniquement `lapigestion-admin/migrations/0002_trial_7_days.sql` une fois. Cette migration conserve les licences, ajoute le niveau `trial` et mémorise la date de première activation.

Le mode `trial` donne l’accès complet pendant 7 jours exactement à partir de la première activation. Une réinstallation ou une nouvelle clé de récupération ne remet pas le compteur à zéro. À expiration, l’utilisateur peut activer une licence définitive de niveau 1 à 4.

## Alternative depuis un ordinateur

Pré-requis : Node 22.13 ou supérieur, accès à ton compte Cloudflare, Wrangler 4.

```sh
cd lapigestion-admin
npm install
npx wrangler login
npx wrangler d1 create lapigestion-licences
```

Renseigne l’ID retourné dans `wrangler.jsonc` et les variables ci-dessus. Si la base a déjà été créée depuis le tableau de bord, utilise son ID existant ; ne crée pas une seconde base.

```sh
npx wrangler d1 migrations apply lapigestion-licences --remote
npx wrangler secret put SIGNING_PRIVATE_JWK
npx wrangler secret put RATE_PEPPER
npx wrangler deploy
```

Cette méthode déploie `src/worker.mjs` et les fichiers `public/` via le binding ASSETS, avec `run_worker_first:true` pour imposer l’authentification avant toute page de console. Configure Access comme ci-dessus. La méthode tableau de bord utilise le fichier tout-en-un et n’a pas besoin d’ASSETS.

Alternative locale à la page de préparation : `npm run keys` génère `private/signing-private.json` et `private/signing-public.txt`. Le script refuse de créer un dossier `private/` déjà existant. Génère aussi un RATE_PEPPER aléatoire d’au moins 32 octets. Puis :

```sh
node scripts/configure-app.mjs https://TON-WORKER.workers.dev private/signing-public.txt
```

Le dossier `private/` et les sauvegardes de licences sont exclus du dépôt. Conserve ces fichiers à l’abri. L’URL ne doit être remplacée que par une URL que tu contrôles ; changer l’URL publique impose de reconfigurer et de reconstruire les APK distribuées.

## Vérification avant mise en service

Teste connexion console, refus anonyme, génération de chaque niveau, activation sur téléphone, refus d’une autre installation, révocation et mise à niveau. Les tests locaux joints ne constituent pas un déploiement réel Cloudflare. En cas d’erreur, vérifier d’abord DB, AUD, TEAM, ADMIN_EMAIL, URL et les deux secrets. Ne jamais désactiver l’authentification pour faire fonctionner la console.
