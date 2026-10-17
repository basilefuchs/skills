# ==============================================================================
# 05_flowchart.R — flowchart d'attrition
# Table attendue : aucune — objet R `attrition`, rempli par les étapes 01 à 04
# Produit        : objet R `flowchart` (annee, etape, nb_sejours, nb_exclus),
#                  fichier sorties/flowchart.csv
# ==============================================================================
# Assemble les effectifs notés par chaque étape juste après sa matérialisation ;
# ne redéfinit aucune étape. C'est ce qui rend l'analyse auditable.

flowchart <- attrition %>%
  arrange(annee, etape) %>%                  # le préfixe "01", "02a"… donne l'ordre
  group_by(annee) %>%
  mutate(nb_exclus = coalesce(lag(nb_sejours) - nb_sejours, 0)) %>%  # 0 à l'inclusion
  ungroup() %>%
  select(annee, etape, nb_sejours, nb_exclus)

# Fichier : effectifs et nombres d'exclus masqués sous le seuil par exporter().
# nb_exclus est requis par le contrat ; masque primaire seulement : une
# cellule masquée se déduit par différence des nb_sejours voisins (voir
# exporter(), 00_setup.R), et la procédure d'export de la plateforme reste
# seule juge de ce qui sort.
flowchart_ecrit <- exporter(flowchart, "flowchart.csv", comptages = c("nb_sejours", "nb_exclus"))

# Écran : brut, ou tel qu'écrit si secret_statistique (00_setup.R).
print(if (secret_statistique) flowchart_ecrit else flowchart, n = Inf)
