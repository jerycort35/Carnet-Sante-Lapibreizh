# Fonctionnement des accès

| Donation vérifiée manuellement | Profil | Fiches | Mode Élevage | Reproducteurs actifs |
|---|---|---|---|---|
| 1 € à moins de 5 € | 1 · Adoptant / 1 lapin | 1 | Non | Aucun accès reproduction |
| 5 € à moins de 10 € | 2 · Adoptant illimité | Illimitées | Non | Aucun accès reproduction |
| 10 € à moins de 20 € | 3 · Complète | Illimitées | Oui | 2 simultanément, mâles et femelles réunis |
| 20 € et plus | 4 · Complète illimitée | Illimitées | Oui | Illimités |
| Réservé au propriétaire | PROPRIÉTAIRE / ADMIN | Illimitées | Oui | Illimités |

Ces niveaux ne sont ni un paiement intégré, ni un abonnement. Le niveau n’a pas de date d’expiration commerciale. La cagnotte n’a aucun lien technique avec l’application. Tu vérifies personnellement la donation, choisis le niveau et le nom dans la console, génères la clé puis envoies toi-même l’APK et la clé.

## Activation et sécurité

La clé utilisateur contient 256 bits aléatoires. Seul son hash est conservé dans D1 ; la clé complète est affichée une fois lors de la génération ou du remplacement. Chaque installation crée sa propre clé RSA non exportable dans Android Keystore. Une preuve signée lie l’activation à cette installation. Copier une clé déjà activée ou le fichier d’autorisation sur un autre appareil ne donne pas les mêmes droits.

Le serveur signe les autorisations ; l’APK contient uniquement la clé **publique** permettant leur vérification. Aucun secret de fabrication, aucune clé maître et aucun mot de passe administrateur n’entre dans l’APK. La console nécessite une session Cloudflare Access cryptographiquement vérifiée et l’adresse administrateur autorisée. Posséder l’APK ou une licence propriétaire n’ouvre pas la console.

Un utilisateur normal ne peut pas sélectionner le profil propriétaire. Ce profil est créé par une commande administrateur séparée ; un seul profil propriétaire est autorisé. Il ne peut pas être révoqué ou rétrogradé par les commandes utilisateurs. Une installation déjà propriétaire refuse le remplacement de cet accès par une clé utilisateur.

## Hors ligne, révocation et mises à jour

Une autorisation utilisateur signée reste utilisable hors ligne **7 jours** après son dernier contrôle réussi. La licence commerciale reste valable sans abonnement : le contrôle renouvelle simplement la preuve technique. L’application vérifie au lancement, au retour au premier plan et quotidiennement lorsqu’elle reste ouverte. Une interruption d’Internet conserve les droits encore valides ; après 7 jours, un contrôle en ligne est nécessaire. Une révocation est appliquée au prochain contrôle serveur, au plus tard à la fin de cette période hors ligne.

Le profil propriétaire comporte une autorisation permanente, sans expiration technique, liée à son installation. Une panne du serveur ne supprime pas cet accès déjà vérifié. L’installation doit être activée une première fois en ligne. Une mise à jour avec la même signature conserve l’activation et les données. Après désinstallation/réinstallation, la clé d’installation change : utilise la commande « Réinstallation / nouvel appareil » de la console, qui libère l’association et produit une nouvelle clé. Une connexion administrateur reste nécessaire pour cette récupération ; conserve aussi les sauvegardes de tes fiches.

Une ancienne installation propriétaire permanente conserve ses droits après récupération sur un nouveau téléphone. C’est la conséquence du fonctionnement permanent hors ligne demandé. Protège tes anciens appareils et ne distribue jamais la clé propriétaire. Il n’existe pas de garantie absolue contre un APK modifié ou un appareil compromis ; aucune licence locale ne peut assurer cette garantie.

## Limites réellement appliquées

Les créations et les restaurations sont contrôlées dans les fonctions de stockage, pas seulement dans l’interface. Le niveau 1 refuse une deuxième fiche. Après rétrogradation d’un accès illimité contenant plusieurs fiches, aucune fiche n’est effacée automatiquement : elles restent consultables et sauvegardables ; il faut choisir volontairement la fiche à conserver ou modifier le niveau. Les modifications restent bloquées tant que le nombre dépasse la limite. La suppression volontaire d’une fiche pour revenir à la limite reste possible.

Le statut « Reproducteur actif » se trouve dans **Identité & filiation**, pour les profils complets. Il faut déclarer le sexe ; le lapin doit être présent et non stérilisé. Les anciens lapins ne deviennent pas automatiquement reproducteurs. Avec le niveau 3, l’enregistrement d’un troisième actif est refusé et une nouvelle saillie exige deux reproducteurs actifs autorisés. L’historique des portées peut continuer à être complété après désactivation d’un reproducteur. Les soins courants ne sont pas interdits pour les anciens reproducteurs. Les niveaux 4 et propriétaire n’ont pas cette limite.

La recherche de couleurs conserve la race sélectionnée, tous les résultats historiques correspondants et les avertissements rouges pour traitement, repos et quota. Au niveau 3, elle signale aussi un couple qui n’est pas parmi les reproducteurs actifs autorisés ; son affichage ne l’autorise pas à reproduire.

Les modes Adoptant conservent les fonctions déjà présentes : identité/filiation, santé, poids, vaccins, vermifuges, traitements, rendez-vous, documents multipages, PDF, sauvegarde/restauration et recherche vétérinaire. Les fonctions Élevage existantes restent conditionnées à un profil complet : reproduction/portées, adoption/départ, certificat d’engagement, concours/expositions, recherche de croisements et statistiques associées. Les données historiques Élevage ne sont pas supprimées lors d’une rétrogradation ou d’une restauration en Adoptant.

Même après révocation ou expiration du contrôle, une commande de sauvegarde complète reste disponible sur l’écran « Mon accès ». Les licences ne sont pas incluses dans les sauvegardes des fiches et ne sont pas restaurées comme données utilisateur.
