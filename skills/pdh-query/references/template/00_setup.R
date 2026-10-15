# ==============================================================================
# Indicateur : <titre court de l'indicateur / de la question>
# Question   : <question en langage naturel de l'utilisateur>
# Protocole  : <résumé 1 ligne : population, exclusions, critère de jugement>
# Source     : <si indicateur documenté : référence biblio, DOI>          [optionnel]
# Catégorie  : <ex. 02_casemix_patientele, 04_efficience_capacitaire>     [optionnel]
# Fiche      : <chemin de la fiche indicateur si elle existe>             [optionnel]
# ==============================================================================

# ==== PROFIL DE BASE (mapping utilisé — profils/portail_atih_<champ>.md) ====
# Base       : Portail ATIH (Teradata via dbplyr)
# Connexion  : pRatihque::connection_database()
# Schémas    : prd_vue_mcobl_AAAA / prd_vue_smrbl_AAAA / prd_vue_nomgen / prd_vue_nompmsi
#
# Séjour MCO (1 ligne)        : fixe.ident (identifiant ANNUEL : joindre sur ident + annee)
# Séjour SMR (1 ligne)        : fixe_sej.ident_sej
# Clé de chaînage patient     : fixe.anonyme (qualité : ano_retour == '000000000')
# Racine GHM (5 car)          : substr(fixe.ghm2, 1, 5)
# FINESS géo. (DP) MCO        : finessgeo_umdudp.finessgeodp (jointure ident)
# Référentiel établisst.      : prd_vue_nomgen.finessgeo (rs, millésimé par annee)
# ==========================================
# NB : lister ci-dessus UNIQUEMENT les éléments réellement utilisés par le dossier,
#      vérifiés dans le dictionnaire (andeb/anfin couvrant toutes les années).

# ==============================================================================
# 00_setup.R — packages, paramètres, connexion, fonctions partagées
# Table attendue : aucune
# Table produite : aucune (initialise l'objet `attrition`)
# ==============================================================================

library(dplyr)
library(dbplyr)
library(purrr)
# library(ggplot2)   # si graphique demandé (06_sorties.R)

# ==== PARAMÈTRES ====
annees     <- 2020:2023                               # années PMSI (année de sortie)
codes_cim3 <- c("E10", "E11", "E12", "E13", "E14")    # codes CIM-10 (3 caractères)

# Secret statistique : selon la finalité validée (bloc 0 des clarifications).
# FALSE pour un dénombrement interne ; TRUE dès que les sorties sont diffusées
# à l'extérieur (aucune cellule < seuil). Appliqué en 05_flowchart.R (effectifs)
# et 06_sorties.R (résultats).
secret_statistique <- FALSE
seuil              <- 11

# Connexion — selon le profil d'environnement (ici : portail ATIH)
conn <- pRatihque::connection_database()

# ==== MATÉRIALISATION PAR ÉTAPE : table volatile de session Teradata ====
# Contrat entre étapes : chaque fichier 01 à 04 termine par la matérialisation
# de sa sortie dans tmp_NN_<etape> (objet R lazy pop_NN_<etape>) ; l'étape
# suivante repart de cette table. Table de session : elle disparaît à la
# déconnexion, rien à nettoyer.
#
# Forme retenue : CREATE VOLATILE TABLE <nom> AS (<requête>) WITH DATA
# ON COMMIT PRESERVE ROWS, émise par DBI::dbExecute().
# Pourquoi pas compute(temporary = TRUE) : le backend Teradata de dbplyr
# (R/backend-teradata.R, dbplyr 2.6.0.9000, vérifié en 2026-10) ne redéfinit pas
# sql_query_save() ; compute() émet donc le SQL générique
# « CREATE TEMPORARY TABLE <nom> AS <requête> », que Teradata refuse
# (tidyverse/dbplyr#147 : « expected something like a 'METHOD' keyword between
# the 'CREATE' keyword and the 'TEMPORARY' keyword »). Si une version de dbplyr
# finit par générer le CREATE VOLATILE TABLE, remplacer le corps de cette
# fonction par compute(requete, name = nom, temporary = TRUE, overwrite = TRUE) :
# les fichiers d'étape ne changent pas.
# Le DROP préalable permet de relancer une étape seule dans la même session.
# Teradata prend la première colonne comme index primaire par défaut : mettre
# la clé de jointure (ident) en première position dans les select().
compute_volatile <- function(requete, nom) {
  try(DBI::dbExecute(conn, paste0("DROP TABLE ", nom)), silent = TRUE)
  DBI::dbExecute(conn, paste0(
    "CREATE VOLATILE TABLE ", nom, " AS (",
    dbplyr::remote_query(requete),
    ") WITH DATA ON COMMIT PRESERVE ROWS"
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
attrition <- tibble::tibble(etape = character(), annee = integer(), nb_sejours = numeric())

noter_attrition <- function(attrition, requete, etape) {
  effectifs <- requete %>%
    count(annee, name = "nb_sejours") %>%       # COUNT par année, côté Teradata
    collect() %>%
    mutate(etape = !!etape, annee = as.integer(annee), nb_sejours = as.numeric(nb_sejours))
  attrition %>%
    filter(etape != !!etape) %>%
    bind_rows(effectifs)
}

# ==============================================================================
# Patterns dbplyr/Teradata — rappels (valables pour tout le dossier)
# - Tables : tbl(conn, I("schema.table")) — convention maison, pas in_schema().
# - Une base par champ et par année (prd_vue_mcobl_AAAA) : une requête lazy par
#   millésime, mêmes colonnes, empilées par purrr::reduce(union_all) — l'UNION
#   est exécuté par Teradata (01_inclusion.R).
# - substr(x, 1, 3) -> SUBSTR pour les listes simples ; motifs complexes :
#   filter(sql("REGEXP_SIMILAR(col, '<regex>', 'c') = 1")).
# - %in% sur petit vecteur -> IN (...) ; longues listes de codes : copy_to() +
#   semi_join sur table temporaire.
# - n_distinct(x) -> COUNT(DISTINCT x). Comptage patients "propre" :
#   filtrer ano_retour == '000000000' AVANT n_distinct(anonyme).
# - collect() : jamais sur une table de séjours entière, toujours après
#   agrégation (06_sorties.R) ; entre étapes, compute_volatile() seulement.
# - Contrôle du SQL généré : requete %>% show_query()
# ==============================================================================
