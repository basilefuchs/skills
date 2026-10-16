# ==============================================================================
# 01_inclusion.R — population incluse
# Table attendue : aucune (lecture de T_MCO{aa}C et T_MCO{aa}B par millésime)
# Table produite : tmp_01_inclusion (objet R : pop_01_inclusion)
#                  1 ligne par séjour inclus, toutes années empilées
# ==============================================================================
# Critère d'inclusion validé : <ex. DP en codes_cim3, MCO, annees>
# Source(s) SNDS : <PMSI MCO seul / + DCIR / + CAUSE_DECES ; intersection ou union>

# Une requête lazy par millésime, mêmes colonnes + colonne annee, puis
# empilement par union_all. Empiler AVANT toute déduplication inter-années :
# on ne peut pas sommer des comptes distincts annuels (patients uniques sur la
# période en 06_sorties.R).
requete_inclusion <- function(annee) {
  aa    <- sprintf("%02d", annee %% 100)              # suffixe réel : T_MCO24B
  mco_c <- tbl(conn, I(paste0("T_MCO", aa, "C")))     # chaînage / codes retour
  mco_b <- tbl(conn, I(paste0("T_MCO", aa, "B")))     # séjour (GHM, DP, DR, SEJ_TYP...)

  mco_c |>
    inner_join(mco_b, by = c("ETA_NUM", "RSA_NUM")) |>
    # -- Inclusion : position du diagnostic selon le protocole -----------------
    filter(substr(DGN_PAL, 1, 3) %in% codes_cim3) |>
    #   variante DP ou DR : filter(substr(DGN_PAL, 1, 3) %in% codes_cim3 |
    #                              substr(DGN_REL, 1, 3) %in% codes_cim3)
    mutate(annee = !!annee) |>
    # -- Colonnes utiles aux étapes suivantes seulement (table de session
    #    légère) : clé du séjour, pseudonyme, codes retour filtrés en 02 -------
    select(ETA_NUM, RSA_NUM, annee, NIR_ANO_17,
           NIR_RET, NAI_RET, SEX_RET, SEJ_RET, FHO_RET, PMS_RET, DAT_RET,
           COH_NAI_RET, COH_SEX_RET,                   # 2013+ : retirer avant
           SEJ_TYP, GRG_GHM, DGN_PAL, COD_SEX, AGE_ANN, SEJ_NBJ, SOR_MOD, BDI_DEP)
}

pop_01_inclusion <- annees |>
  purrr::map(requete_inclusion) |>
  purrr::reduce(union_all) |>
  compute_session("tmp_01_inclusion")

attrition <- noter_attrition(attrition, pop_01_inclusion, "01 Sejours DP cible")

# Les variantes ci-dessous s'insèrent DANS requete_inclusion() : `aa` est le
# suffixe 2 chiffres du millésime courant.

# -- Variante : inclusion sur DAS (diagnostics associés significatifs) ---------
# ident_das <- tbl(conn, I(paste0("T_MCO", aa, "D"))) |>
#   filter(substr(ASS_DGN, 1, 3) %in% codes_cim3) |>
#   distinct(ETA_NUM, RSA_NUM)
# ... |> semi_join(ident_das, by = c("ETA_NUM", "RSA_NUM"))
# (DP, DR ou DAS = « hospitalisé AVEC » : union_all des deux requêtes puis
#  distinct sur la clé du séjour)

# -- Variante : motif CIM-10 complexe (Oracle REGEXP_LIKE, pas REGEXP_SIMILAR) --
# filter(sql("REGEXP_LIKE(DGN_PAL, '^(F0[0-3]|G30|A810|B220)')"))

# -- Variante : critère CCAM côté PMSI (table des actes) -----------------------
# actes_cible <- tbl(conn, I(paste0("T_MCO", aa, "A"))) |>
#   filter(sql("REGEXP_LIKE(CDC_ACT, '^[A-Z]{3}L')")) |>   # ex. motif de code CCAM
#   distinct(ETA_NUM, RSA_NUM)
# ... |> semi_join(actes_cible, by = c("ETA_NUM", "RSA_NUM"))
# EXT_PMSI (extension documentaire) n'existe qu'à partir de 2015.
# Pathologie ET acte (intersection) : enchaîner le filter() sur DGN_PAL et le
# semi_join ; pathologie OU acte (union) : union_all des deux requêtes puis
# distinct — effectifs très différents (ligne Sources de `## Données`).

# -- Variante SSR : clé (ETA_NUM, RHA_NUM), tables T_SSR{aa}C / T_SSR{aa}B,
#    diagnostic = FP_PEC (jusqu'en 2022) / MOR_PRP / ETL_AFF selon le protocole
#    (profils/hdh_oracle.md) ; adapter la clé dans les étapes suivantes.

# -- Variante : même critère CCAM côté DCIR (ER_CAM_F, clé composite 9 col.) ---
# Code CCAM = CAM_PRS_IDE (CAM_ACT_COD est le code ACTIVITÉ sur 1 caractère).
# Un acte = triplet (CAM_PRS_IDE, CAM_ACT_COD, CAM_TRT_PHA) : dédupliquer sur ce
# triplet (+ prestation) pour ne pas compter deux fois activité 1 et anesthésie 4.
# actes_dcir <- tbl(conn, I("ER_PRS_F")) |>
#   filter((is.na(DPN_QLF) | !DPN_QLF %in% c(71, 72)),
#          (is.na(PRS_DPN_QLP) | !PRS_DPN_QLP %in% c(71, 72))) |>  # filtres qualité DCIR (NULL = OK)
#   left_join(tbl(conn, I("ER_ETE_F")) |> select(all_of(DCIR_JOIN_KEY), ETE_IND_TAA),
#             by = DCIR_JOIN_KEY) |>
#   filter(is.na(ETE_IND_TAA) | ETE_IND_TAA != 1) |>              # hors ES ex-DG en facturation directe
#   inner_join(tbl(conn, I("ER_CAM_F")), by = DCIR_JOIN_KEY) |>
#   filter(sql("REGEXP_LIKE(CAM_PRS_IDE, '^[A-Z]{3}L')"))
# ATTENTION : non batchée, cette forme n'est exécutable que sur quelques mois
# (filtrer FLX_DIS_DTD) — au-delà, Pattern C ci-dessous.

# -- Variante : critère médicamenteux DCIR (classe ATC, ER_PHA_F + IR_PHA_R) ---
# IR_PHA_R est un référentiel PRODUIT non millésimé (pas de suffixe année).
# Garder la liste de CIP13 cible LAZY (semi_join) : une classe ATC large peut
# dépasser 1000 codes, limite Oracle d'une liste IN (...) (ORA-01795).
# cip_cible <- tbl(conn, I("IR_PHA_R")) |>
#   filter(sql("REGEXP_LIKE(PHA_ATC_CLA, '^N06AB')")) |>   # ex. ISRS
#   filter(!is.na(PHA_CIP_C13)) |>
#   distinct(PHA_CIP_C13)
# delivrances <- tbl(conn, I("ER_PRS_F")) |>
#   filter((is.na(DPN_QLF) | !DPN_QLF %in% c(71, 72)),
#          (is.na(PRS_DPN_QLP) | !PRS_DPN_QLP %in% c(71, 72))) |>
#   inner_join(tbl(conn, I("ER_PHA_F")), by = DCIR_JOIN_KEY) |>
#   semi_join(cip_cible, by = c("PHA_PRS_C13" = "PHA_CIP_C13")) |>
#   transmute(anonyme = BEN_NIR_PSA, rang = BEN_RNG_GEM, dte_exe = EXE_SOI_DTD)
# ATTENTION : la forme ci-dessus ne doit PAS être exécutée telle quelle au-delà
# de quelques mois — ER_PRS_F est trop volumineuse. Batcher sur FLX_DIS_DTD :
# voir Pattern C ci-dessous.

# -- Variante : croisement de sources (PMSI x DCIR, PMSI x CAUSE_DECES) -------
# Le croisement reste DANS ce fichier : une requête lazy par source, ramenée à
# la clé patient commune, puis
#   intersection (« hospitalisés ET traités ») : semi_join sur la clé ;
#   union (« hospitalisés OU traités »)        : union_all puis distinct.
# Clé commune : NIR_ANO_17 (PMSI) = BEN_NIR_PSA (DCIR) ; individu et décès via
# IR_BEN_R.BEN_IDT_ANO (plusieurs BEN_NIR_PSA par individu, appariement des
# décès incomplet : DCD_IDT_TOP) — lire « Chaînage » de `## Données` avant
# d'écrire la jointure ; noter la perte dans attrition.
# deces_cible <- tbl(conn, I("KI_CCI_R")) |>
#   filter(substr(DCD_CIM_COD, 1, 3) %in% codes_cim3) |>   # cause initiale
#   distinct(BEN_IDT_ANO)

# -- Pattern C — extraction DCIR volumineuse (ER_PRS_F) : itération par flux --
# mensuel (FLX_DIS_DTD). Reprend la variante médicamenteuse ci-dessus, batchée.
#
# FLX_DIS_DTD (date de flux technique) != EXE_SOI_DTD (date de soin réelle) :
# une prestation de fin de période peut être remontée dans un flux ultérieur.
# La boucle de flux court donc jusqu'à la fin de la période clinique PLUS UNE
# MARGE (documentation officielle HDH, fiche filtres : au minimum 5 mois de
# données après la période, 12 mois pour une extraction exhaustive, jamais plus
# de 24), chaque batch filtrant ensuite
# précisément sur EXE_SOI_DTD.
#
# date_debut  <- as.Date("2020-01-01")   # début période clinique demandée
# date_fin    <- as.Date("2023-12-31")   # fin période clinique demandée
# marge_flux  <- 6                       # mois de flux après date_fin : 6 = minimum
#                                        # officiel (5 mois de données) ; 12 = exhaustif ; <= 24
#
# # Bornes calculées sur le 1er du mois (seq.Date depuis un 31 décalerait les mois)
# mois_fin      <- as.Date(format(date_fin, "%Y-%m-01"))
# flux_max      <- seq.Date(mois_fin, by = "month", length.out = marge_flux + 1)[marge_flux + 1]
# flux_mensuels <- seq.Date(as.Date(format(date_debut, "%Y-%m-01")), flux_max, by = "month")
#
# extraction_batch <- function(flx) {
#   # Connexion PROPRE à ce batch : indispensable avec furrr (workers = process R
#   # séparés) ; fuseau posé avant dbConnect(), comme en 00_setup.R.
#   Sys.setenv(TZ = "Europe/Paris"); Sys.setenv(ORA_SDTZ = "Europe/Paris")
#   .drv <- dbDriver("Oracle")
#   options(connectionObserver = NULL)
#   conn_batch <- dbConnect(.drv, dbname = "IPIAMPR2.WORLD")
#   on.exit(dbDisconnect(conn_batch))
#
#   cip_cible <- tbl(conn_batch, I("IR_PHA_R")) |>          # référentiel produit, lazy
#     filter(sql("REGEXP_LIKE(PHA_ATC_CLA, '^N06AB')")) |>
#     filter(!is.na(PHA_CIP_C13)) |>
#     distinct(PHA_CIP_C13)
#
#   prs <- tbl(conn_batch, I("ER_PRS_F")) |>
#     filter(
#       FLX_DIS_DTD == !!ora_date(flx),                     # même filtre de flux des 2 côtés de la jointure
#       (is.na(DPN_QLF) | !DPN_QLF %in% c(71, 72)),
#       (is.na(PRS_DPN_QLP) | !PRS_DPN_QLP %in% c(71, 72)),  # filtres qualité DCIR (NULL = OK)
#       EXE_SOI_DTD >= !!ora_date(date_debut),
#       EXE_SOI_DTD <= !!ora_date(date_fin)                  # période CLINIQUE, appliquée DANS le batch de flux
#     )
#   ete <- tbl(conn_batch, I("ER_ETE_F")) |>
#     filter(FLX_DIS_DTD == !!ora_date(flx)) |>
#     select(all_of(DCIR_JOIN_KEY), ETE_IND_TAA)
#   pha <- tbl(conn_batch, I("ER_PHA_F")) |>
#     filter(FLX_DIS_DTD == !!ora_date(flx))
#
#   prs |>
#     left_join(ete, by = DCIR_JOIN_KEY) |>
#     filter(is.na(ETE_IND_TAA) | ETE_IND_TAA != 1) |>      # hors ES ex-DG en facturation directe
#     inner_join(pha, by = DCIR_JOIN_KEY) |>
#     semi_join(cip_cible, by = c("PHA_PRS_C13" = "PHA_CIP_C13")) |>
#     transmute(anonyme = BEN_NIR_PSA, rang = BEN_RNG_GEM, dte_exe = EXE_SOI_DTD, cip = PHA_PRS_C13,
#               annee = sql("EXTRACT(YEAR FROM EXE_SOI_DTD)")) |>   # annee du flowchart : année de soin en DCIR
#     collect()                                              # collect PAR BATCH : seule exception documentée à la
#                                                             # règle "jamais de collect() avant agrégation
#                                                             # finale" (rappels de 00_setup.R) -- itération sur
#                                                             # plusieurs connexions, impossible à garder lazy
# }
#
# future::plan(future::multisession(workers = 4))            # cf. profils/hdh_oracle.md, "Défauts recommandés"
# delivrances <- furrr::future_map_dfr(
#   flux_mensuels, extraction_batch, .progress = TRUE
# )   # data frame EN MÉMOIRE (identifiants : jamais écrit sur disque) -- agréger/
#     # dédupliquer ensuite selon le protocole ; patients uniques : joindre IR_BEN_R
#     # (BEN_NIR_PSA, BEN_RNG_GEM) et compter BEN_IDT_ANO.
#     # Pour rendre la suite du dossier identique au cas PMSI, réinjecter le
#     # résultat dans la table de session de l'étape : créer la table vide depuis
#     # la forme du premier batch, puis y ajouter les lignes collectées.
# pop_01_inclusion <- compute_session(
#   <corps de extraction_batch() sur conn, sans collect()> |> filter(sql("1 = 0")),  # table vide, mêmes colonnes
#   "tmp_01_inclusion"
# )
# dbWriteTable(conn, "TMP_01_INCLUSION", delivrances, append = TRUE)   # ROracle : ajout dans la table de session
# attrition <- noter_attrition(attrition, pop_01_inclusion, "01 Delivrances cible")
