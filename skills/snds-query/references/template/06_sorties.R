# ==============================================================================
# 06_sorties.R — résultat, visualisation, export
# Table attendue : tmp_04_covariables (objet R : pop_04_covariables),
#                  ou tmp_03_critere_jugement si le protocole n'a pas de covariable
# Produit        : objets R `resultat_annuel`, `nb_patients_periode`
#                  (+ figure, export CSV d'agrégats)
# ==============================================================================
# Le calcul reste côté Oracle ; collect() uniquement sur les agrégats.

pop_analyse <- pop_04_covariables      # pop_03_critere_jugement si 04 omis

# ==== RÉSULTAT ====
# -- Pattern A — agrégats par année (et par strate) ----------------------------
resultat_annuel <- pop_analyse |>
  group_by(annee) |>                   # + sexe_lib, classe_age… selon la stratification
  summarise(
    nb_sejours  = n(),                 # 1 ligne = 1 séjour (ou n_distinct(sejour_id))
    nb_patients = n_distinct(NIR_ANO_17)   # patients uniques PAR ANNÉE — pseudonymes
                                           # PMSI ; individus stricts : BEN_IDT_ANO (03)
  ) |>
  collect() |>
  arrange(annee)

# -- Pattern B — patients uniques SUR TOUTE LA PÉRIODE : n_distinct sur
#    l'empilement des années (fait en 01), jamais la somme des distincts annuels
nb_patients_periode <- pop_analyse |>
  summarise(nb_patients = n_distinct(NIR_ANO_17)) |>
  collect()

# -- Secret statistique (seuil = 11) : diffusion externe seulement (00_setup.R)
# verifier_seuil() signale toute cellule de 1 à seuil - 1 (0 diffusable) ; la
# corriger en regroupant les modalités < seuil sous "Autre" puis en
# ré-agrégeant (group_by + summarise une seconde fois), plutôt que masquer :
# les totaux restent justes.
verifier_seuil <- function(df, col_effectif) {
  n_masque <- sum(df[[col_effectif]] > 0 & df[[col_effectif]] < seuil, na.rm = TRUE)
  if (n_masque > 0) {
    warning(sprintf(
      "%d cellule(s) < %d (%s) - à regrouper sous 'Autre' avant toute diffusion externe.",
      n_masque, seuil, col_effectif
    ))
  }
  df
}
if (secret_statistique) {
  resultat_annuel     <- resultat_annuel |> verifier_seuil("nb_patients") |> verifier_seuil("nb_sejours")
  nb_patients_periode <- nb_patients_periode |> verifier_seuil("nb_patients")
  # resultat_annuel <- resultat_annuel |>
  #   mutate(classe_age = if_else(nb_patients < seuil, "Autre", classe_age)) |>
  #   group_by(annee, classe_age) |>
  #   summarise(across(c(nb_sejours, nb_patients), sum), .groups = "drop")
}

# -- Libellés (référentiels) : joints en R sur l'agrégat collecté --------------
# aa_ref   <- sprintf("%02d", max(annees) %% 100)                 # dernier millésime
# ref_etab <- tbl(conn, I(paste0("T_MCO", aa_ref, "E"))) |>
#   select(ETA_NUM, SOC_RAI) |>                                   # raison sociale
#   distinct() |>
#   collect()
# resultat_annuel |> left_join(ref_etab, by = "ETA_NUM")

# -- Indicateur méthodologique (Gini, entropie, taux standardisé…) -------------
# Oracle sort la DISTRIBUTION agrégée (ex. annee x etab x profil x effectif),
# le calcul final se fait en R sur ce petit tableau. Prévoir des seuils de
# stabilité (effectif minimum par cellule/profil) en paramètres de 00_setup.R.

resultat_annuel |> print()
print(nb_patients_periode)

# ==== VISUALISATION (si demandée) ====
# ggplot(resultat_annuel, aes(x = annee, y = nb_patients)) +
#   geom_point() + geom_smooth(se = FALSE, method = "loess") +
#   scale_x_continuous(breaks = annees) +
#   theme_minimal()

# ==== EXPORT (décommenter si besoin) ====
# Règle SNDS (00_setup.R) : ne jamais persister en local un fichier contenant
# un identifiant (pseudonyme patient, clé de séjour), une date de soin ou une
# localisation fine — seuls des AGRÉGATS vérifiés par verifier_seuil() sortent.
# readr::write_csv(resultat_annuel, "resultat_annuel.csv")
# readr::write_csv(flowchart, "flowchart.csv")
