# Références techniques officielles

- Cloudflare Access : validation complète du jeton d’application, émetteur et audience : https://developers.cloudflare.com/cloudflare-one/access-controls/applications/http-apps/authorization-cookie/application-token/
- Cloudflare Workers : worker avant les fichiers statiques : https://developers.cloudflare.com/workers/static-assets/routing/worker-script/
- Wrangler : bindings D1, fichiers statiques et configuration : https://developers.cloudflare.com/workers/wrangler/configuration/
- Android Keystore : https://developer.android.com/privacy-and-security/keystore
- Android APK signing : https://developer.android.com/studio/publish/app-signing

La console est protégée par Access et le backend vérifie cryptographiquement le JWT ; il ne fait pas confiance à un simple en-tête e-mail. La configuration des fichiers statiques impose le passage par le worker. Les licences sont vérifiées dans le code Android ; la clé de fabrication reste côté Cloudflare.
