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
# Sources    : <champs PMSI : MCO / SMR / HAD / PSY / RPU — et chaînage si plusieurs>
#
# Séjour MCO (1 ligne)        : fixe.ident (identifiant ANNUEL : joindre sur ident + annee)
# Séjour SMR (1 ligne)        : fixe_sej.ident_sej
# Clé de chaînage patient     : fixe.anonyme (qualité : ano_retour == '000000000')
# Racine GHM (5 car)          : substr(fixe.ghm2, 1, 5)
# FINESS géo. (DP) MCO        : finessgeo_umdudp.finessgeodp (jointure ident)
# Référentiel établisst.      : prd_vue_nomgen.finessgeo (rs, millésimé par annee)
# ==========================================
# NB : lister ci-dessus UNIQUEMENT les éléments réellement utilisés par le dossier,
#      vérifiés par pdh-schema (`## Données` de protocole.md), années comprises.
# Dictionnaire : <ligne Dictionnaire de `## Données`>

# ==============================================================================
# 00_setup.R — packages, paramètres, connexion, fonctions partagées
# Table attendue : aucune
# Table produite : aucune (initialise les objets `attrition` et `sorties_ecrites`)
# ==============================================================================

library(dplyr)
library(dbplyr)
library(purrr)
library(ggplot2)     # figure de 06_sorties.R : retirer avec elle si aucune n'est demandée

# ==== PARAMÈTRES ====
annees     <- 2020:2023                               # années PMSI (année de sortie)
codes_cim3 <- c("E10", "E11", "E12", "E13", "E14")    # codes CIM-10 (3 caractères)

# Secret statistique. Règle : ce qui s'affiche à l'écran peut être brut, ce
# qui s'écrit est sous seuil. Tout fichier passe par exporter() (ci-dessous),
# qui masque toujours ; secret_statistique ne régit que l'affichage de
# 05_flowchart.R et 06_sorties.R (TRUE : écran identique aux fichiers écrits).
secret_statistique <- FALSE
seuil              <- 11

# Sorties : dossier sorties/ à côté du dossier de scripts et de protocole.md
# (main.R est lancé depuis le dossier de scripts) ; valeurs reprises dans
# sorties/manifeste.md.
dossier_sorties  <- "../sorties"
question         <- "<question en langage naturel de l'utilisateur>"
sources          <- "<champs PMSI : MCO / SMR / HAD / PSY / RPU>"
dictionnaire     <- "<ligne Dictionnaire de ## Données, recopiée telle quelle>"
protocole_valide <- "<AAAA-MM-JJ, date de validation du protocole>"

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
# nb_sejours : nom fixé par le contrat de sorties/flowchart.csv, gardé quelle
# que soit l'unité du protocole ; ne pas le renommer.
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

# ==== SORTIES : exporter(), seule voie d'écriture de fichier ====
# Appelée par 05_flowchart.R et 06_sorties.R, une fois par fichier de sorties/ :
#   x         : agrégat collecté, ou figure ggplot construite depuis un agrégat
#               déjà renvoyé par exporter() (rien à masquer) ;
#   fichier   : nom fixe du contrat (flowchart.csv, resultat_annuel.csv…) ;
#   comptages : colonnes d'effectifs, masquées (NA) de 1 à seuil - 1, 0 gardé ;
#   derivees  : colonnes calculées sur ces effectifs (pourcentage, taux), mises
#               à NA sur toute ligne dont un comptage est masqué.
# Écrit un CSV UTF-8 séparé par des virgules (NA = cellule masquée), réécrit
# sorties/manifeste.md et renvoie, invisible, la table telle qu'écrite.
# Masque primaire seulement : une cellule masquée peut encore se déduire par
# différence entre cellules voisines ou d'un total ; le regroupement sous
# "Autre" (06_sorties.R) le limite, et la procédure d'export de la plateforme
# reste seule juge de ce qui sort.
sorties_ecrites <- tibble::tibble(fichier = character(), cellules_masquees = integer())

exporter <- function(x, fichier, comptages = character(), derivees = character()) {
  dir.create(dossier_sorties, showWarnings = FALSE, recursive = TRUE)
  chemin <- file.path(dossier_sorties, fichier)
  if (inherits(x, "ggplot")) {
    ggplot2::ggsave(chemin, plot = x, width = 8, height = 5, dpi = 150)
    masquees <- NA_integer_
  } else {
    effectifs  <- as.matrix(x[comptages])
    sous_seuil <- !is.na(effectifs) & effectifs > 0 & effectifs < seuil
    for (col in comptages) x[[col]][sous_seuil[, col]] <- NA
    for (col in derivees)  x[[col]][rowSums(sous_seuil) > 0] <- NA
    masquees <- as.integer(sum(sous_seuil))
    utils::write.csv(x, chemin, row.names = FALSE, fileEncoding = "UTF-8")
  }

  sorties_ecrites <<- sorties_ecrites %>%
    filter(fichier != !!fichier) %>%
    bind_rows(tibble::tibble(fichier = fichier, cellules_masquees = masquees))
  writeLines(enc2utf8(c(
    "# Manifeste de sorties/",
    "",
    paste0("- Question : ", question),
    paste0("- Répertoire : ", basename(normalizePath(file.path(dossier_sorties, "..")))),
    paste0("- Date d'exécution : ", format(Sys.time(), "%Y-%m-%d %H:%M")),
    paste0("- Années : ", paste(annees, collapse = ", ")),
    paste0("- Sources : ", sources),
    paste0("- Seuil : ", seuil),
    paste0("- Secret appliqué : comptages de 1 à ", seuil - 1, " masqués (NA), ",
           "colonnes dérivées de leur ligne aussi"),
    paste0("- Dictionnaire : ", dictionnaire),
    paste0("- Protocole validé le : ", protocole_valide),
    "",
    "| Fichier | Cellules masquées |",
    "| --- | --- |",
    paste0("| ", sorties_ecrites$fichier, " | ",
           ifelse(is.na(sorties_ecrites$cellules_masquees), "sans objet (figure)",
                  sorties_ecrites$cellules_masquees), " |")
  )), file.path(dossier_sorties, "manifeste.md"), useBytes = TRUE)

  invisible(x)
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
