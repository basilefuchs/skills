# ==============================================================================
# 01_inclusion.R — population incluse
# Table attendue : aucune (lecture des vues prd_vue_mcobl_AAAA.fixe)
# Table produite : tmp_01_inclusion (objet R : pop_01_inclusion)
#                  1 ligne par séjour inclus, toutes années empilées
# ==============================================================================
# Critère d'inclusion validé : <ex. DP en codes_cim3, MCO, annees>

# Une requête lazy par millésime, mêmes colonnes, puis empilement par union_all.
# Empiler AVANT toute déduplication inter-années : on ne peut pas sommer des
# comptes distincts annuels (patients uniques sur la période en 06_sorties.R).
requete_inclusion <- function(an) {
  fixe_tbl <- tbl(conn, I(paste0("prd_vue_mcobl_", an, ".fixe")))

  fixe_tbl %>%
    # -- Inclusion : position du diagnostic selon le protocole -----------------
    filter(substr(dp, 1, 3) %in% codes_cim3) %>%
    #   variante DP ou DR : filter(substr(dp, 1, 3) %in% codes_cim3 |
    #                              substr(dr, 1, 3) %in% codes_cim3)
    # -- Colonnes utiles aux étapes suivantes seulement (table volatile légère),
    #    ident en premier (index primaire par défaut) --------------------------
    select(ident, annee, anonyme, ano_retour, ghm2, sexe, age, duree,
           codegeo, finess, modesortie)
}

pop_01_inclusion <- annees %>%
  purrr::map(requete_inclusion) %>%
  purrr::reduce(union_all) %>%
  compute_volatile("tmp_01_inclusion")

attrition <- noter_attrition(attrition, pop_01_inclusion, "01 Sejours DP cible")

# -- Variante : critère incluant les DAS (table diag) --------------------------
# Dans requete_inclusion(), remplacer le filter() sur dp par :
# ident_das <- tbl(conn, I(paste0("prd_vue_mcobl_", an, ".diag"))) %>%
#   filter(substr(diag, 1, 3) %in% codes_cim3) %>% distinct(ident)
# fixe_tbl %>% semi_join(ident_das, by = "ident")
# (DP, DR ou DAS = « hospitalisé AVEC » : réunir les deux critères par un
#  filter(... | ...) après left_join, ou un union_all de deux requêtes + distinct)

# -- Variante : motif CIM-10 complexe (regex Teradata) -------------------------
# filter(sql("REGEXP_SIMILAR(diag, '^(F0[0-3]|G30|A810|B220).*', 'c') = 1"))

# -- Variante : critère sur actes CCAM (table acte) ----------------------------
# ident_acte <- tbl(conn, I(paste0("prd_vue_mcobl_", an, ".acte"))) %>%
#   filter(substr(acte, 1, 2) == "NF", acte_activ == "1") %>% distinct(ident)
# fixe_tbl %>% semi_join(ident_acte, by = "ident")
# Pathologie ET acte (intersection) : enchaîner le filter() sur dp et le
# semi_join ; pathologie OU acte (union) : union_all des deux requêtes puis
# distinct(ident) — effectifs très différents (clarification Q1a ↔ Q1b).

# -- Variante SMR : diagnostics au niveau RHA (fixe), séjour = fixe_sej --------
# sej_cible <- tbl(conn, I(paste0("prd_vue_smrbl_", an, ".fixe"))) %>%
#   filter(substr(morbidp, 1, 3) %in% codes_cim3) %>%   # ou finalp / etiolp
#   distinct(ident_sej)
# tbl(conn, I(paste0("prd_vue_smrbl_", an, ".fixe_sej"))) %>%
#   semi_join(sej_cible, by = "ident_sej")
# Adapter alors les colonnes du select() et la clé (ident_sej) dans les étapes
# suivantes.
