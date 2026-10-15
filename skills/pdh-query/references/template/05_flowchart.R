# ==============================================================================
# 05_flowchart.R — flowchart d'attrition
# Table attendue : aucune — objet R `attrition`, rempli par les étapes 01 à 04
# Produit        : objet R `flowchart` (annee, etape, nb_sejours, pct_perdu)
# ==============================================================================
# Assemble les effectifs notés par chaque étape juste après sa matérialisation ;
# ne redéfinit aucune étape. À reporter dans note_methodologique.md : c'est ce
# qui rend l'analyse auditable.

flowchart <- attrition %>%
  arrange(annee, etape) %>%                  # le préfixe "01", "02a"… donne l'ordre
  group_by(annee) %>%
  mutate(pct_perdu = round(100 * (lag(nb_sejours) - nb_sejours) / lag(nb_sejours), 1)) %>%
  ungroup() %>%
  select(annee, etape, nb_sejours, pct_perdu)

# Secret statistique : diffusion externe seulement (paramètre de 00_setup.R).
if (secret_statistique) {
  flowchart <- flowchart %>%
    mutate(nb_sejours = if_else(nb_sejours < seuil, NA_real_, nb_sejours))
}

flowchart %>% print(n = Inf)
