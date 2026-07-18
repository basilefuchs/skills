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
# Schémas    : prd_vue_mco_AAAA / prd_vue_smr_AAAA / prd_vue_nomgen / prd_vue_nompmsi
#
# Séjour MCO (1 ligne)        : fixe.ident
# Séjour SMR (1 ligne)        : fixe_sej.ident_sej
# Clé de chaînage patient     : fixe.anonyme (qualité : ano_retour == '000000000')
# Racine GHM (5 car)          : substr(fixe.ghm2, 1, 5)
# FINESS géo. (DP) MCO        : finessgeo_umdudp.finessgeodp (jointure ident)
# Référentiel établisst.      : prd_vue_nomgen.finessgeo (rs, millésimé par annee)
# ==========================================
# NB : lister ci-dessus UNIQUEMENT les éléments réellement utilisés par le script,
#      vérifiés dans le dictionnaire (andeb/anfin couvrant toutes les années).

library(dplyr)
library(dbplyr)
# library(ggplot2)   # si graphique demandé

# ==== PARAMÈTRES ====
annees     <- 2020:2023                               # années PMSI (année de sortie)
codes_cim3 <- c("E10", "E11", "E12", "E13", "E14")    # codes CIM-10 (3 caractères)

# Connexion — selon le profil d'environnement (ici : portail ATIH)
conn <- pRatihque::connection_database()

# ==== RÉFÉRENTIELS (si besoin de libellés) ====
# ref_finessgeo <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
#   filter(annee %in% annees) %>%
#   select(annee, finessgeo, rs) %>%
#   distinct() %>%
#   collect()

# ==== EXTRACTION ====
# Pattern A (par défaut) — agrégats PAR ANNÉE : map_dfr + collect() par millésime.
# L'agrégation est faite par Teradata, seul le résultat agrégé est rapatrié.
resultat_annuel <- purrr::map_dfr(annees, function(an) {

  fixe_tbl <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))

  fixe_tbl %>%
    # -- Inclusion : position du diagnostic selon le protocole -----------------
    filter(substr(dp, 1, 3) %in% codes_cim3) %>%
    #   variante DP ou DR : | substr(dr, 1, 3) %in% codes_cim3
    # -- Exclusions (adapter au protocole) -------------------------------------
    filter(
      substr(ghm2, 1, 2) != "90",     # séjours en erreur
      substr(ghm2, 1, 2) != "28"      # séances (si exclues)
    ) %>%
    summarise(
      nb_sejours  = n_distinct(ident),
      nb_patients = n_distinct(ifelse(ano_retour == "000000000", anonyme, NA))
    ) %>%
    collect() %>%
    mutate(annee = an)
})

# Pattern B — patients uniques SUR TOUTE LA PÉRIODE : la déduplication
# inter-années impose d'empiler les requêtes lazy AVANT le n_distinct
# (on ne peut pas sommer des comptes distincts annuels).
requete_annee <- function(an) {
  tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe"))) %>%
    filter(
      substr(dp, 1, 3) %in% codes_cim3,
      substr(ghm2, 1, 2) != "90",
      ano_retour == "000000000"                # chaînage fiable obligatoire
    ) %>%
    select(anonyme)
}

nb_patients_periode <- annees %>%
  purrr::map(requete_annee) %>%
  purrr::reduce(union_all) %>%                 # UNION exécuté par Teradata
  summarise(nb_patients = n_distinct(anonyme)) %>%
  collect()

# -- Variante : critère incluant les DAS (table diag) --------------------------
# ident_das <- tbl(conn, I(paste0("prd_vue_mco_", an, ".diag"))) %>%
#   filter(substr(diag, 1, 3) %in% codes_cim3) %>% distinct(ident)
# fixe_tbl %>% semi_join(ident_das, by = "ident")

# -- Variante : motif CIM-10 complexe (regex Teradata) -------------------------
# filter(sql("REGEXP_SIMILAR(diag, '^(F0[0-3]|G30|A810|B220).*', 'c') = 1"))

# -- Pattern "flags" : caractériser les séjours par des critères annexes -------
# (ex. démence en DAS, codes de précarité) puis construire un profil case_when :
# flag_dem <- fixe_tbl %>%
#   inner_join(tbl_diag, by = "ident") %>%
#   filter(sql("REGEXP_SIMILAR(diag, '^(F0[0-3]|G30).*', 'c') = 1")) %>%
#   distinct(ident) %>% mutate(demence = 1)
# fixe_tbl %>%
#   left_join(flag_dem, by = "ident") %>%
#   mutate(demence = case_when(demence == 1 ~ "demence", TRUE ~ "absence demence"))

# -- Variante : critère sur actes CCAM (table acte) ----------------------------
# ident_acte <- tbl(conn, I(paste0("prd_vue_mco_", an, ".acte"))) %>%
#   filter(substr(acte, 1, 2) == "NF", acte_activ == "1") %>% distinct(ident)

# -- Variante : analyse par site géographique (MCO) ----------------------------
# geo_tbl <- tbl(conn, I(paste0("prd_vue_mco_", an, ".finessgeo_umdudp")))
# fixe_tbl %>% inner_join(geo_tbl %>% select(ident, finessgeodp), by = "ident")

# -- Variante SMR : diagnostics au niveau RHA (fixe), séjour = fixe_sej --------
# sej_cible <- tbl(conn, I(paste0("prd_vue_smr_", an, ".fixe"))) %>%
#   filter(substr(morbidp, 1, 3) %in% codes_cim3) %>%   # ou finalp / etiolp
#   distinct(ident_sej)
# tbl(conn, I(paste0("prd_vue_smr_", an, ".fixe_sej"))) %>%
#   semi_join(sej_cible, by = "ident_sej")

# ==== FLOWCHART D'ATTRITION (systématique) ====
# Décompte des séjours à chaque étape du protocole : rend l'analyse auditable.
# Adapter les étapes au protocole réel (mêmes filtres, même ordre que l'extraction).
# Une requête COUNT par étape et par année, exécutée côté Teradata : peu coûteux.
attrition <- purrr::map_dfr(annees, function(an) {

  fixe_tbl <- tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))

  e1 <- fixe_tbl %>% filter(substr(dp, 1, 3) %in% codes_cim3)
  e2 <- e1 %>% filter(substr(ghm2, 1, 2) != "28")
  e3 <- e2 %>% filter(substr(ghm2, 1, 2) != "90")
  e4 <- e3 %>% filter(ano_retour == "000000000")

  purrr::imap_dfr(
    list("1. Sejours DP cible"          = e1,
         "2. hors seances (CMD 28)"     = e2,
         "3. hors GHM en erreur (90)"   = e3,
         "4. chainage exploitable"      = e4),
    function(req, etape) {
      req %>% summarise(nb_sejours = n()) %>% collect() %>% mutate(etape = etape)
    }
  ) %>%
    mutate(annee = an)
})

attrition <- attrition %>%
  group_by(annee) %>%
  mutate(pct_perdu = round(100 * (lag(nb_sejours) - nb_sejours) / lag(nb_sejours), 1)) %>%
  ungroup() %>%
  select(annee, etape, nb_sejours, pct_perdu)

# ==== RÉSULTAT ====
attrition %>% arrange(annee, etape) %>% print(n = Inf)   # à reporter dans la note méthodologique
resultat_annuel %>% arrange(annee) %>% print()
print(nb_patients_periode)

# ==== VISUALISATION (si demandée) ====
# ggplot(resultat_annuel, aes(x = annee, y = nb_patients)) +
#   geom_point() + geom_smooth(se = FALSE, method = "loess") +
#   scale_x_continuous(breaks = annees) +
#   theme_minimal()

# ==== EXPORT (décommenter si besoin) ====
# readr::write_csv(resultat_annuel, "resultat_annuel.csv")

# ==============================================================================
# Patterns dbplyr/Teradata — rappels
# - Tables : tbl(conn, I("schema.table")) — convention maison, pas in_schema().
# - substr(x, 1, 3) -> SUBSTR pour les listes simples ; motifs complexes :
#   filter(sql("REGEXP_SIMILAR(col, '<regex>', 'c') = 1")).
# - %in% sur petit vecteur -> IN (...) ; longues listes de codes : copy_to() +
#   semi_join sur table temporaire.
# - n_distinct(x) -> COUNT(DISTINCT x). Comptage patients "propre" :
#   filtrer ano_retour == '000000000' AVANT n_distinct(anonyme).
# - collect() : jamais sur une table de séjours entière, toujours après agrégation.
# - Indicateur méthodologique (Gini, entropie, taux standardisé...) : Teradata
#   sort la DISTRIBUTION agrégée (ex. annee x etab x profil x effectif), le calcul
#   final se fait en R sur ce petit tableau. Prévoir des seuils de stabilité
#   (effectif minimum par cellule/profil) en paramètres.
# - Contrôle du SQL généré : requete %>% show_query()
# ==============================================================================
