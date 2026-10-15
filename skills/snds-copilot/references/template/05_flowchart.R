# ==============================================================================
# 05_flowchart.R — flowchart d'attrition
# Table attendue : aucune — objet R `attrition`, rempli par les étapes 01 à 04
# Produit        : objet R `flowchart` (annee, etape, nb_sejours, nb_exclus, pct_perdu)
# ==============================================================================
# Assemble les effectifs notés par chaque étape juste après sa matérialisation ;
# ne redéfinit aucune étape. À reporter dans note_methodologique.md : c'est ce
# qui rend l'analyse auditable.

flowchart <- attrition |>
  arrange(annee, etape) |>                  # le préfixe "01", "02a"… donne l'ordre
  group_by(annee) |>
  mutate(
    nb_exclus = lag(nb_sejours) - nb_sejours,
    pct_perdu = round(100 * nb_exclus / lag(nb_sejours), 1)
  ) |>
  ungroup() |>
  select(annee, etape, nb_sejours, nb_exclus, pct_perdu)

# Secret statistique : diffusion externe seulement (paramètre de 00_setup.R).
# Effectifs ET nombres d'exclus entre étapes (un exclus < seuil se déduit
# sinon de deux effectifs diffusés) ; 0 reste diffusable.
if (secret_statistique) {
  flowchart <- flowchart |>
    mutate(
      nb_sejours = if_else(nb_sejours > 0 & nb_sejours < seuil, NA_real_, nb_sejours),
      nb_exclus  = if_else(nb_exclus > 0 & nb_exclus < seuil, NA_real_, nb_exclus)
    )
}

flowchart |> print(n = Inf)
