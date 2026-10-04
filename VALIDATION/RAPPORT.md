# LapiGestion V3.1.39

- Nés = mâles nés + femelles nées, sans ajouter les morts.
- Vivants à la naissance = nés − morts à la naissance, par sexe.
- Vivants au sevrage = survivants à la naissance − décès supplémentaires jusqu’au sevrage, par sexe.
- Les décès sont saisis dans deux rubriques distinctes. Les champs de vivants au sevrage deviennent des résultats calculés automatiquement.
- Validation : aucun décès négatif, aucun décès supérieur aux effectifs du même sexe ; date de sevrage obligatoire pour enregistrer ses décès.
- Bilans, PDF, graphiques individuels/cumulés et profil par sexe utilisent les résultats corrigés. Les couleurs portent sur les survivants à la naissance.
- Sans date de sevrage, aucun décès avant sevrage n’est inventé. Les totaux cumulés calculent chaque portée séparément avant addition.
- Les données anciennes sont conservées ; voir INSTALLATION.txt pour leur interprétation et la vérification des anciennes saisies.

Validation : 24 tests Flutter réussis, dont 6 tests du calcul des portées et les 18 tests précédents (documents multipages, sauvegardes et interface). Analyse : aucune erreur, 26 diagnostics préexistants. Aucun APK Android construit ; vérification sur téléphone après génération par ton workflow.
