# V3.1.38 - Documents multipages

## Fonctionnement

Carnet de santé et Passeport acceptent plusieurs images, ajoutées ensemble ou en plusieurs fois. Deux commandes : Ajouter des photos (galerie, sélection multiple) et Ajouter un fichier (sélecteur de fichiers, sélection multiple). Les PDF et autres fichiers restent acceptés.

Miniatures numérotées dans chaque rubrique. Appuyer sur une miniature ouvre le lecteur avec balayage entre pages, commandes précédente/suivante et zoom sur les photos. Chaque page peut être remplacée ou supprimée individuellement ; la suppression demande confirmation et conserve les autres pages et les fichiers originaux.

Les listes de pages sont conservées localement, intégrées à la sauvegarde/restauration et jointes au partage de fiche. Le dossier PDF indique leur nombre ; il ne fusionne pas les images ou fichiers en un nouveau PDF. Suppression de fiche : nettoyage de toutes ses pages internes.

## Compatibilité

Les anciens chemins uniques sont reconnus et migrés en liste sans supprimer le fichier original. Les anciennes sauvegardes restent restaurables dans V3.1.38. Les nouvelles sauvegardes multipages sont destinées à cette version ou une version ultérieure compatible.

## Validation

18 tests Flutter : compatibilité des chemins uniques ; migration ; sauvegarde/restauration de quatre pièces ; restauration de sauvegarde ancienne ; lecteur de pages, passage à la seconde page et suppression ciblée ; tests préexistants de navigation, formulaires, affichage et tailles d’écran.

Analyse statique : aucune erreur ; 26 diagnostics préexistants (7 avertissements, 19 informations). La capture est un rendu réel Flutter utilisant la bannière comme fichier de démonstration, pas de véritables pages personnelles.

Les sélecteurs galerie/fichiers, le partage système et la réception des notifications doivent encore être vérifiés sur le téléphone. Aucun APK construit ici.
