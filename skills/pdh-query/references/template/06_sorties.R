# ==============================================================================
# 06_sorties.R — résultat, visualisation, export
# Table attendue : tmp_04_covariables (objet R : pop_04_covariables),
#                  ou tmp_03_critere_jugement si le protocole n'a pas de covariable
# Produit        : objets R `resultat_annuel`, `nb_patients_periode`
#                  (+ figure, export CSV)
# ==============================================================================
# Le calcul reste côté Teradata ; collect() uniquement sur les agrégats.

pop_analyse <- pop_04_covariables      # pop_03_critere_jugement si 04 omis

# ==== RÉSULTAT ====
# -- Agrégats par année (et par strate) ----------------------------------------
resultat_annuel <- pop_analyse %>%
  group_by(annee) %>%                  # + sexe_lib, classe_age… selon la stratification
  summarise(
    nb_sejours  = n(),                 # 1 ligne = 1 séjour (ident est annuel :
                                       # n_distinct(ident) n'a de sens que par année)
    nb_patients = n_distinct(anonyme)  # patients uniques PAR ANNÉE
  ) %>%
  collect() %>%
  arrange(annee)

# -- Patients uniques SUR TOUTE LA PÉRIODE : n_distinct sur l'empilement des
#    années (fait en 01), jamais la somme des distincts annuels ----------------
nb_patients_periode <- pop_analyse %>%
  summarise(nb_patients = n_distinct(anonyme)) %>%
  collect()

# -- Secret statistique : diffusion externe seulement (00_setup.R) -------------
# Regrouper les modalités < seuil sous "Autre" puis ré-agréger (group_by +
# summarise une seconde fois), plutôt que masquer : les totaux restent justes.
# if (secret_statistique) {
#   resultat_annuel <- resultat_annuel %>%
#     mutate(classe_age = if_else(nb_patients < seuil, "Autre", classe_age)) %>%
#     group_by(annee, classe_age) %>%
#     summarise(across(c(nb_sejours, nb_patients), sum), .groups = "drop")
# }

# -- Libellés (référentiels) : joints en R sur l'agrégat collecté --------------
# ref_finessgeo <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
#   filter(annee %in% annees) %>%
#   select(annee, finessgeo, rs) %>%
#   distinct() %>%
#   collect()
# resultat_annuel %>% left_join(ref_finessgeo, by = c("annee", "finessgeodp" = "finessgeo"))

# -- Indicateur méthodologique (Gini, entropie, taux standardisé…) -------------
# Teradata sort la DISTRIBUTION agrégée (ex. annee x etab x profil x effectif),
# le calcul final se fait en R sur ce petit tableau. Prévoir des seuils de
# stabilité (effectif minimum par cellule/profil) en paramètres de 00_setup.R.

resultat_annuel %>% print()
print(nb_patients_periode)

# ==== VISUALISATION (si demandée) ====
# ggplot(resultat_annuel, aes(x = annee, y = nb_patients)) +
#   geom_point() + geom_smooth(se = FALSE, method = "loess") +
#   scale_x_continuous(breaks = annees) +
#   theme_minimal()

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat_annuel, "resultat_annuel.csv")
# readr::write_csv(flowchart, "flowchart.csv")
