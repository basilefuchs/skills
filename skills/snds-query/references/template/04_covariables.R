# ==============================================================================
# 04_covariables.R — variables de stratification et de caractérisation
# Table attendue : tmp_03_critere_jugement (objet R : pop_03_critere_jugement)
# Table produite : tmp_04_covariables (objet R : pop_04_covariables)
# ==============================================================================
# Stratification validée : <ex. année, sexe, classe d'âge>
# Fichier omis du dossier si le protocole n'a aucune covariable (06_sorties.R
# repart alors de tmp_03_critere_jugement).
# La clé du séjour (ETA_NUM, RSA_NUM) n'est unique que dans un millésime :
# toute jointure sur une table annexe PMSI se fait sur (ETA_NUM, RSA_NUM, annee),
# avec la table annexe empilée par millésime comme en 01.

pop_04_covariables <- pop_03_critere_jugement |>
  mutate(
    classe_age = case_when(
      AGE_ANN < 18 ~ "0-17",
      AGE_ANN < 65 ~ "18-64",
      AGE_ANN < 80 ~ "65-79",
      TRUE         ~ "80+"
    ),
    sexe_lib = case_when(COD_SEX == "1" ~ "Homme", COD_SEX == "2" ~ "Femme", TRUE ~ "Inconnu")
  ) |>
  compute_session("tmp_04_covariables")

attrition <- noter_attrition(attrition, pop_04_covariables, "04 Covariables")

# -- Dérivation classique : type de séjour (Séance / HDJ / HC) -----------------
# mutate(type_sejour = case_when(
#   substr(GRG_GHM, 1, 2) == "28" ~ "Séance",
#   substr(GRG_GHM, 1, 2) != "28" & SEJ_NBJ == 0 ~ "HDJ",
#   .default = "HC"
# ))

# -- Variante : analyse par site géographique ---------------------------------
# Résidence du PATIENT : BDI_DEP (T_MCO{aa}B, déjà dans la table de session) ;
# côté DCIR, BEN_RES_COM / BEN_RES_DPT sur ER_PRS_F.
# Localisation de l'ÉTABLISSEMENT : ETA_NUM (FINESS) — autre résultat.
# Localisation du PROFESSIONNEL DE SANTÉ (DCIR) : ER_GEO_LOC_R, clé NUM_PS =
# ER_PRS_F.PFS_EXE_NUM (exécutant) ou PFS_PRE_NUM (prescripteur) -- le
# professionnel, PAS le patient. Plusieurs lignes possibles par NUM_PS (colonne
# CABINET) : vérifier l'unicité avant la jointure, sous peine de dupliquer les
# prestations.
# geo_ps <- tbl(conn, I("ER_GEO_LOC_R")) |> distinct(NUM_PS, CODE_COM, CODE_DEPT, CODEREG)
# prestations |> inner_join(geo_ps, by = c("PFS_EXE_NUM" = "NUM_PS"))   # prestations issues de ER_PRS_F

# -- Pattern "flags" : caractériser les séjours par des critères annexes -------
# (ex. démence en DAS) puis construire un profil case_when.
# das_tbl <- annees |>
#   purrr::map(function(annee) {
#     aa <- sprintf("%02d", annee %% 100)
#     tbl(conn, I(paste0("T_MCO", aa, "D"))) |>
#       select(ETA_NUM, RSA_NUM, ASS_DGN) |> mutate(annee = !!annee)
#   }) |>
#   purrr::reduce(union_all)
# flag_dem <- pop_03_critere_jugement |>
#   inner_join(das_tbl, by = c("ETA_NUM", "RSA_NUM", "annee")) |>
#   filter(sql("REGEXP_LIKE(ASS_DGN, '^(F0[0-3]|G30)')")) |>
#   distinct(ETA_NUM, RSA_NUM, annee) |> mutate(demence = 1)
# pop_03_critere_jugement |>
#   left_join(flag_dem, by = c("ETA_NUM", "RSA_NUM", "annee")) |>
#   mutate(demence = case_when(demence == 1 ~ "demence", TRUE ~ "absence demence"))

# -- Variante : ALD (IR_IMB_R) comme comorbidité -------------------------------
# Filtres de validité (IMB_ETM_NAT, bornes IMB_ALD_DTD/DTF avec sentinelle 1600)
# et jointure par individu : profils/hdh_oracle.md, « IR_IMB_R ».
