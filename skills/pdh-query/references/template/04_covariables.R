# ==============================================================================
# 04_covariables.R — variables de stratification et de caractérisation
# Table attendue : tmp_03_critere_jugement (objet R : pop_03_critere_jugement)
# Table produite : tmp_04_covariables (objet R : pop_04_covariables)
# ==============================================================================
# Stratification validée : <ex. année, sexe, classe d'âge>
# Fichier omis du dossier si le protocole n'a aucune covariable (06_sorties.R
# repart alors de tmp_03_critere_jugement).
# ident est un identifiant ANNUEL : toute jointure sur une table annexe se fait
# sur (ident, annee), avec la table annexe empilée par millésime comme en 01.

pop_04_covariables <- pop_03_critere_jugement %>%
  mutate(
    classe_age = case_when(
      age < 18 ~ "0-17",
      age < 65 ~ "18-64",
      age < 80 ~ "65-79",
      TRUE     ~ "80+"
    ),
    sexe_lib = case_when(sexe == "1" ~ "Homme", sexe == "2" ~ "Femme", TRUE ~ "Inconnu")
  ) %>%
  compute_volatile("tmp_04_covariables")

attrition <- noter_attrition(attrition, pop_04_covariables, "04 Covariables")

# -- Variante : analyse par site géographique (MCO) ----------------------------
# Le finess de fixe est l'entité juridique : pour un site, joindre
# finessgeo_umdudp (FINESS géographique du RUM portant le DP).
# geo_tbl <- annees %>%
#   purrr::map(function(an) {
#     tbl(conn, I(paste0("prd_vue_mcobl_", an, ".finessgeo_umdudp"))) %>%
#       select(ident, finessgeodp) %>% mutate(annee = !!an)
#   }) %>%
#   purrr::reduce(union_all)
# pop_03_critere_jugement %>% left_join(geo_tbl, by = c("ident", "annee"))

# -- Pattern "flags" : caractériser les séjours par des critères annexes -------
# (ex. démence en DAS, codes de précarité) puis construire un profil case_when.
# diag_tbl <- annees %>%
#   purrr::map(function(an) {
#     tbl(conn, I(paste0("prd_vue_mcobl_", an, ".diag"))) %>%
#       select(ident, diag) %>% mutate(annee = !!an)
#   }) %>%
#   purrr::reduce(union_all)
# flag_dem <- pop_03_critere_jugement %>%
#   inner_join(diag_tbl, by = c("ident", "annee")) %>%
#   filter(sql("REGEXP_SIMILAR(diag, '^(F0[0-3]|G30).*', 'c') = 1")) %>%
#   distinct(ident, annee) %>% mutate(demence = 1)
# pop_03_critere_jugement %>%
#   left_join(flag_dem, by = c("ident", "annee")) %>%
#   mutate(demence = case_when(demence == 1 ~ "demence", TRUE ~ "absence demence"))

# -- Variante : région / département de résidence -----------------------------
# corresp <- tbl(conn, I("prd_vue_nomgen.all_corresp_geo"))   # codegeo -> dep, région
# pop_03_critere_jugement %>% left_join(corresp, by = "codegeo")
# (résidence du patient ; localisation de l'établissement = finess, autre résultat)
