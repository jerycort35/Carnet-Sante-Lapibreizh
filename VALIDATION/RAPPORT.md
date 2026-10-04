# V3.1.42 — Dorures des champs hauts

Cause : les ornements issus du cadre de bouton étaient dessinés sur une hauteur plafonnée à 48 pixels, depuis le haut du champ. Le bas du décor se retrouvait au milieu d’un champ de plusieurs lignes.

Correction : pour les champs dépassant 48 pixels, des ornements complets de cadre sont positionnés aux vrais coins supérieur droit et inférieur gauche, sans couper ou étirer les feuilles. La bordure verticale existante assure la continuité. Le dessin des boutons et des champs plus petits conserve son comportement précédent.

Code fonctionnel main.dart identique à V3.1.41, vérifié par comparaison binaire au ZIP livré. Modification uniquement du peintre décoratif partagé, du numéro de version et d’un test d’interface.

Validation : 15 tests d’interface Flutter réussis, dont un nouveau parcours des notes d’adoption. Champ vide de trois lignes puis sept lignes : hauteur augmente, largeur identique, contenu enregistré inchangé, aucune exception. Les tests préexistants contrôlent la saisie, navigation et absence de débordements sur plusieurs largeurs et tailles de texte. Deux captures réelles jointes.

Analyse statique sans erreur ; diagnostics préexistants indiqués dans analyze_v42.txt. Aucun test physique sur téléphone et aucun APK construit.
