# ==============================================================================
# Indicateur : <titre court de l'indicateur / de la question>
# Question   : <question en langage naturel de l'utilisateur>
# Protocole  : <résumé 1 ligne : sources SNDS, population, exclusions, critère de jugement>
# Source     : <si indicateur documenté : référence biblio, DOI>          [optionnel]
# Catégorie  : <ex. 02_casemix_patientele, 04_efficience_capacitaire>     [optionnel]
# Fiche      : <chemin de la fiche indicateur si elle existe>             [optionnel]
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé — profils/hdh_oracle.md) =====
# Base       : SNDS via le Health Data Hub — Oracle, interrogé en dbplyr
# Connexion  : bloc « Connexion » du profil actif (profils/hdh_oracle.md)
# Sources    : <PMSI MCO / DCIR / CAUSE_DECES — et méthode de chaînage si plusieurs>
# Tables     : PMSI = tables suffixées par l'année de sortie (2 chiffres),
#              pas de schéma millésimé (ex. T_MCO24C, T_MCO24B, T_MCO24A, T_MCO24D)
#              DCIR = tables continues (ER_PRS_F, ER_CAM_F, ER_PHA_F...), filtrées
#              par date de soins (EXE_SOI_DTD) ou par flux (FLX_DIS_DTD)
#
# Séjour MCO (RSA, 1 ligne)    : T_MCO{aa}B, clé (ETA_NUM, RSA_NUM)
# Chaînage / qualité MCO       : T_MCO{aa}C (mêmes clés ETA_NUM, RSA_NUM)
# Pseudonyme patient PMSI      : NIR_ANO_17 (tous champs PMSI) = BEN_NIR_PSA du DCIR
# Jointure DCIR -> référentiel : BEN_NIR_PSA + BEN_RNG_GEM (clé de IR_BEN_R, PAS un
#   identifiant d'individu : un individu peut porter plusieurs BEN_NIR_PSA)
# Individu (tous SNDS)         : IR_BEN_R.BEN_IDT_ANO ; causes de décès reliées par
#   KI_CCI_R.BEN_IDT_ANO = IR_BEN_R.BEN_IDT_ANO — voir modele-donnees.md,
#   section « Chaînage patient », avant tout rapprochement inter-sources.
# GHM (6 car) / CMD (2 car)    : GRG_GHM / substr(GRG_GHM, 1, 2)
# Géo. résidence patient       : BDI_DEP (T_MCO{aa}B) ; BEN_RES_COM / BEN_RES_DPT (ER_PRS_F)
# Géo. professionnel de santé  : ER_GEO_LOC_R (PAS ER_GEO_LOC_F), clé NUM_PS =
#   ER_PRS_F.PFS_EXE_NUM (exécutant) ou PFS_PRE_NUM (prescripteur) —
#   c'est la localisation du PS, PAS celle du patient
# ==========================================
# NB : lister ci-dessus UNIQUEMENT les éléments réellement utilisés par le dossier,
#      vérifiés dans le dictionnaire (variables.tsv), millésimes compris.
# Dictionnaire : schema-snds (Health Data Hub, MPL-2.0), commit <SOURCE.txt>

# ==============================================================================
# 00_setup.R — packages, paramètres, connexion, fonctions partagées
# Table attendue : aucune
# Table produite : aucune (initialise l'objet `attrition`)
# ==============================================================================

library(ROracle)
library(dplyr)
library(dbplyr)
library(purrr)
# library(ggplot2)   # si graphique demandé (06_sorties.R)

# ==== PARAMÈTRES ====
annees     <- 2021:2024                                # années PMSI (année de sortie)
codes_cim3 <- c("E10", "E11", "E12", "E13", "E14")      # codes CIM-10 (3 caractères)

# Secret statistique : selon la finalité validée (bloc 0 des clarifications).
# FALSE pour un dénombrement interne ; TRUE dès que les sorties sont diffusées
# à l'extérieur (aucune cellule < seuil). Appliqué en 05_flowchart.R (effectifs
# et nombres d'exclus) et 06_sorties.R (résultats).
secret_statistique <- FALSE
seuil              <- 11

# NIR_ANO_17 fictifs (documentation officielle HDH) : à exclure avant tout
# comptage de patients, sinon chaque valeur fictive compte comme un patient.
NIR_FICTIFS <- c("xxxxxxxxxxxxxxxxx", "XXXXXXXXXXXXXXXXD", "BXXXXXXXXXXXXXXXX",
                 "XXXXXXXXXXXXXXXXS", "XXXXXXXXXXXXXXXXE")

# Clé de jointure composite DCIR (ER_PRS_F <-> ER_CAM_F/ER_PHA_F/ER_BIO_F/ER_ETE_F...) —
# les 9 colonnes techniques identifiant une ligne de prestation.
# Exception : ER_DCT_F (niveau décompte) n'a pas PRS_ORD_NUM et REM_TYP_AFF n'y
# est documenté qu'en 2006 — voir modele-donnees.md.
DCIR_JOIN_KEY <- c(
  "FLX_DIS_DTD", "FLX_TRT_DTD", "FLX_EMT_TYP", "FLX_EMT_NUM", "FLX_EMT_ORD",
  "ORG_CLE_NUM", "DCT_ORD_NUM", "PRS_ORD_NUM", "REM_TYP_AFF"
)

# Littéral DATE Oracle : dbplyr traduit une date R en simple chaîne '2020-01-01',
# que Oracle convertit selon NLS_DATE_FORMAT (erreur ORA-01861 ou filtre faux).
# Toujours écrire les bornes de date avec !!ora_date(d) dans filter().
ora_date <- function(d) dbplyr::sql(sprintf("DATE '%s'", format(as.Date(d), "%Y-%m-%d")))

# ==== CONNEXION (profil Health Data Hub — cf. profils/hdh_oracle.md) ====
# Fuseau posé AVANT l'ouverture de session : ORA_SDTZ est lu par le client
# Oracle à la connexion ; posé après dbConnect(), il est sans effet et une date
# de soin ou de décès remontée par ROracle peut changer de jour (conversion UTC).
Sys.setenv(TZ = "Europe/Paris")
Sys.setenv(ORA_SDTZ = "Europe/Paris")
.drv <- dbDriver("Oracle")
options(connectionObserver = NULL)
conn <- dbConnect(.drv, dbname = "IPIAMPR2.WORLD")

# ==== MATÉRIALISATION PAR ÉTAPE : table temporaire de session Oracle ====
# Contrat entre étapes : chaque fichier 01 à 04 termine par la matérialisation
# de sa sortie dans tmp_NN_<etape> (objet R lazy pop_NN_<etape>) ; l'étape
# suivante repart de cette table. Table de session : ses lignes disparaissent
# à la déconnexion, rien à nettoyer (seule la définition, vide, reste dans le
# schéma du projet et est recréée à chaque exécution).
#
# Forme retenue : CREATE GLOBAL TEMPORARY TABLE <nom> ON COMMIT PRESERVE ROWS
# AS <requête>, émise par DBI::dbExecute(), puis statistiques Oracle par
# DBMS_STATS.GATHER_TABLE_STATS (statistiques de session sur une table
# temporaire globale depuis Oracle 12c ; sans elles, les jointures suivantes
# sont très lentes — profils/hdh_oracle.md).
# Pourquoi pas compute(temporary = TRUE) : selon la version de dbplyr, le
# backend Oracle (R/backend-oracle.R, vérifié en 2026-10) émet
#   - jusqu'à dbplyr 2.5.0 : « CREATE GLOBAL TEMPORARY TABLE <nom> AS <requête> »
#     sans ON COMMIT PRESERVE ROWS — la table est vidée au commit implicite du
#     DDL et l'étape suivante lit une table vide ;
#   - depuis dbplyr 2.6.0 (CRAN, juin 2026) : « CREATE PRIVATE TEMPORARY TABLE
#     ORA$PTT_<nom> ON COMMIT PRESERVE DEFINITION AS <requête> » — table privée
#     de session (Oracle 18c et plus), absente du dictionnaire, sur laquelle
#     aucune statistique ne peut être calculée (analyze = TRUE y est sans effet).
# Si l'environnement est en Oracle 18c+ avec dbplyr 2.6.0+ et que l'absence
# de statistiques est acceptable, remplacer le corps de cette fonction par
# compute(requete, name = nom, temporary = TRUE, overwrite = TRUE) : les
# fichiers d'étape ne changent pas.
# TRUNCATE puis DROP préalables, silencieux : une table temporaire globale
# dont la session détient des lignes refuse le DROP (ORA-14452) ; les deux
# permettent de relancer une étape seule dans la même session.
compute_session <- function(requete, nom) {
  try(DBI::dbExecute(conn, paste0("TRUNCATE TABLE ", nom)), silent = TRUE)
  try(DBI::dbExecute(conn, paste0("DROP TABLE ", nom)), silent = TRUE)
  DBI::dbExecute(conn, paste0(
    "CREATE GLOBAL TEMPORARY TABLE ", nom, " ON COMMIT PRESERVE ROWS AS ",
    dbplyr::remote_query(requete)
  ))
  DBI::dbExecute(conn, paste0(
    "BEGIN DBMS_STATS.GATHER_TABLE_STATS(USER, '", toupper(nom), "'); END;"
  ))
  tbl(conn, I(nom))
}

# ==== FLOWCHART D'ATTRITION : un objet partagé, rempli par les étapes ====
# Chaque étape appelle noter_attrition() juste après sa matérialisation (et à
# chaque exclusion successive en 02) : les étapes sont définies une seule fois,
# là où elles sont écrites. 05_flowchart.R assemble, sans rien redéfinir.
# Libellé : préfixe du fichier + lettre si plusieurs étapes dans un fichier
# ("02a", "02b"…) ; le tri alphabétique restitue l'ordre du protocole.
# Relancer une étape remplace ses lignes au lieu de les dupliquer.
# nb_sejours : 1 ligne = 1 séjour en PMSI ; renommer (nb_prestations,
# nb_deces) si l'unité du protocole est la prestation DCIR ou le décès.
attrition <- tibble::tibble(etape = character(), annee = integer(), nb_sejours = numeric())

noter_attrition <- function(attrition, requete, etape) {
  effectifs <- requete |>
    count(annee, name = "nb_sejours") |>       # COUNT par année, côté Oracle
    collect() |>
    mutate(etape = !!etape, annee = as.integer(annee), nb_sejours = as.numeric(nb_sejours))
  attrition |>
    filter(etape != !!etape) |>
    bind_rows(effectifs)
}

# ==== RÈGLE SNDS : NON-PERSISTANCE LOCALE ====
# Aucun fichier local ne contient un identifiant (NIR_ANO_17, BEN_NIR_PSA,
# BEN_IDT_ANO…), une date ou une localisation individuelle : les tables de
# session restent dans Oracle, et seuls des AGRÉGATS vérifiés vis-à-vis du
# seuil (06_sorties.R) sortent de l'environnement HDH. Le dossier livré ne
# contient que du code et la note méthodologique.

# ==============================================================================
# Patterns dbplyr/Oracle — rappels (valables pour tout le dossier)
# - Tables : tbl(conn, I("NOM_TABLE")) — PMSI suffixé par année (2 chiffres),
#   DCIR/référentiels non millésimés. Nom réel reconstruit depuis le nom
#   générique du dictionnaire : paste0("T_MCO", aa, "B").
# - Vérifier chaque colonne dans le dictionnaire POUR CHAQUE MILLÉSIME demandé,
#   et sur la table où elle est filtrée (ex. SEJ_TYP est dans B, pas dans C).
# - Une table par champ et par année : une requête lazy par millésime, mêmes
#   colonnes + colonne annee, empilées par purrr::reduce(union_all) — l'UNION
#   est exécuté par Oracle (01_inclusion.R).
# - substr(x, 1, 3) -> SUBSTR pour les listes simples ; motifs complexes :
#   filter(sql("REGEXP_LIKE(col, '<regex>')")) — fonction Oracle. Pas de RIGHT()
#   en Oracle : SUBSTR(x, -n).
# - %in% -> IN (...) limité à 1000 valeurs en Oracle (ORA-01795) ; au-delà,
#   semi_join sur une requête lazy ou une table de session.
# - Dates : une date R dans filter() devient une chaîne ; utiliser !!ora_date(d)
#   (littéral DATE 'AAAA-MM-JJ'). Vérifier avec show_query().
# - Tables temporaires : compute_session() ci-dessus (statistiques comprises) ;
#   copy_to() d'un petit data frame : analyze = TRUE et indexes = list("col").
# - n_distinct(x) -> COUNT(DISTINCT x). Pas d'identifiant séjour unique en
#   PMSI/SNDS : clé composite paste0(ETA_NUM, "-", RSA_NUM) plutôt que
#   n_distinct(x, y) (traduction SQL multi-colonnes fragile).
# - collect() : jamais sur une table de séjours/prestations entière, toujours
#   après agrégation (06_sorties.R) ; entre étapes, compute_session() seulement
#   — sauf Pattern C (01_inclusion.R : collect() PAR BATCH de flux DCIR).
# - DCIR volumineux et non millésimé : filtrer par date (EXE_SOI_DTD) ou par
#   flux mensuel (FLX_DIS_DTD) ; au-delà de quelques mois sur ER_PRS_F, itérer
#   par flux avec furrr::future_map_dfr (une connexion Oracle PAR WORKER) —
#   Pattern C et modele-donnees.md piège n°11 ; marge de flux après la période
#   clinique (points-de-vigilance.md).
# - Chaînage inter-sources : NIR_ANO_17 (PMSI) = BEN_NIR_PSA (DCIR) ; individu
#   et causes de décès via IR_BEN_R.BEN_IDT_ANO — modele-donnees.md.
# - Contrôle du SQL généré : requete |> show_query().
# ==============================================================================
