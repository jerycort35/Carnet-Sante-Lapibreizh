# Correctif ciblé V3.1.40

## Périmètre vérifié

Import des événements gestuels ; taille verticale et consigne de la mention ; classe HandwritingPadState et son peintre. Aucune modification aux autres écrans, aux calculs des portées, aux documents, à la sauvegarde/restauration ou au générateur PDF. Le numéro de version passe de +39 à +40.

Chaque appui ouvre un nouveau tracé. Les mouvements complètent ce tracé ; lever ou annuler le pointeur le termine sans verrouiller la zone. La zone reçoit immédiatement les gestes d’écriture, dont les traits verticaux. Les marges et le reste de la page permettent toujours le défilement. Chaque cadre conserve son état quand il sort du champ visible. Les points isolés restent visibles. Effacer concerne uniquement le cadre choisi.

Mention : 150 → 450 pixels de hauteur (×3). Largeur et paddings inchangés. Signature : hauteur conservée à 130 pixels. Les éléments suivants descendent dans la liste verticale existante.

## Tests effectués

26 tests Flutter réussis : les 24 tests précédents et deux parcours complets du certificat, l’un avec événements touch, l’autre avec événements stylus. Les parcours manuscrits finaux ont également été rejoués après amélioration du texte de démonstration.

Dans chaque parcours : plusieurs mots simulés sur plusieurs lignes ; 28 tracés avec levées successives, puis un 29e après retour ; défilement dans la marge jusqu’à la signature ; 10 tracés dans la signature ; conservation exacte des tracés initiaux ; retour et complément de la mention ; indépendance des cadres ; effacement ciblé ; absence de déplacement de la page pendant l’écriture ; contrôle des dimensions et de la séparation verticale ; accès au bouton final ; export PNG avec encre visible, y compris pour le cadre hors écran ; aucune exception Flutter.

Captures issues du véritable écran Flutter, avec écriture de démonstration. Analyse statique : aucune erreur, 26 diagnostics préexistants. Le diff joint et les assertions de périmètre vérifient l’absence de modification hors correctif.

## Limite matérielle

Les événements doigt et stylet sont simulés par Flutter Test. Aucun appareil physique ni stylet matériel disponible ; le test matériel sur téléphone et la génération APK restent à réaliser après installation. Le générateur PDF existant est conservé ; la disponibilité des deux images à exporter a été testée.
