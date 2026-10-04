# Validation V3.1.44

Correction limitée aux surfaces manuscrites : zoom plein écran, mode déplacement distinct du dessin, annulation du dernier trait, priorité stylet sur contact tactile en cours et cache de courbes terminées. Pas de filtrage destructif des coordonnées ni de seuil supprimant les petits mouvements. Zoom inverse correctement appliqué grâce à globalToLocal ; à 2×, un déplacement de 100×60 pixels correspond à 50×30 dans l’encre originale. Largeur des cadres et hauteurs 450/130 préservées ; export PNG existant conservé.

37 tests Flutter réussis : tracés successifs, 600 positions subpixel, points finaux, mention/signature indépendantes, défilement, export PNG, zoom tactile/stylet, déplacement sans encre, validation et annulation de l’éditeur, paume avant stylet, conservation de l’encre terminée et annulation locale. Contrôles précédents documents, reproduction et interface réussis. Captures de vrais widgets Flutter simulés, inspectées visuellement. Analyse : aucune erreur, 25 diagnostics préexistants.

Limite : événements tactiles et stylet simulés ; aucun matériel physique connecté. L’amélioration du ressenti sur l’appareil de l’utilisateur ne peut pas être certifiée ici. Le zoom permet des gestes plus amples sans changer les dimensions finales. Il ne modifie pas la fréquence ni la qualité du capteur matériel.

Dorures premium_ui.dart inchangées, aucun changement de logique reproduction, documents ou autres fonctionnalités. Archive simple ZIP_STORED DOS, extraite et comparée octet par octet.
