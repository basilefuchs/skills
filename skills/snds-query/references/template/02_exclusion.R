# ==============================================================================
# 02_exclusion.R — exclusions successives
# Table attendue : tmp_01_inclusion (objet R : pop_01_inclusion)
# Table produite : tmp_02_exclusion (objet R : pop_02_exclusion)
# ==============================================================================
# Exclusions validées, dans l'ordre : <ex. qualité de chaînage, prestations
# inter-établissements, GHM en erreur (CMD 90)>. Chaque exclusion est notée
# dans `attrition` : le flowchart montre la perte de chacune.

# 02a. qualité de chaînage (source : documentation officielle HDH) : codes
#      retour à '0' et NIR fictifs exclus — obligatoire pour compter des
#      patients. COH_NAI_RET/COH_SEX_RET disponibles depuis 2013 uniquement,
#      DAT_RET depuis 2006 : retirer ces conditions (et les colonnes du select()
#      de 01) si le protocole remonte avant.
etape_02a <- pop_01_inclusion |>
  filter(
    NIR_RET == "0", NAI_RET == "0", SEX_RET == "0", SEJ_RET == "0",
    FHO_RET == "0", PMS_RET == "0", DAT_RET == "0",
    COH_NAI_RET == "0", COH_SEX_RET == "0",
    !NIR_ANO_17 %in% NIR_FICTIFS
  )
attrition <- noter_attrition(attrition, etape_02a, "02a chainage exploitable")

# 02b. hors prestations inter-établissements (PIE, séjours de type B) —
#      SEJ_TYP vient de T_MCO{aa}B (présent dans la table de session depuis 01).
etape_02b <- etape_02a |>
  filter(SEJ_TYP != "B" | is.na(SEJ_TYP))
attrition <- noter_attrition(attrition, etape_02b, "02b hors prestations inter-etab.")

# 02c. hors GHM en erreur (CMD 90)
etape_02c <- etape_02b |>
  filter(substr(GRG_GHM, 1, 2) != "90")
attrition <- noter_attrition(attrition, etape_02c, "02c hors GHM en erreur (90)")

# -- Doublons de transmission APHP/APHM/HCL : séjours 2005-2017 SEULEMENT -----
# (remontées corrigées depuis). Si le protocole couvre cette période, récupérer
# la liste à jour des FINESS sur la fiche officielle (profils/hdh_oracle.md,
# « Documentation officielle en ligne ») plutôt que la coder en dur :
# etape_02d <- etape_02c |>
#   filter(!ETA_NUM %in% c(<liste FINESS 2023-12-11_synthese_filtres_snds_v1>))
# attrition <- noter_attrition(attrition, etape_02d, "02d hors doublons APHP/APHM/HCL")

# -- Autres exclusions selon le protocole -------------------------------------
# filter(substr(GRG_GHM, 1, 2) != "28")   # séances (si exclues)
# filter(SEJ_NBJ > 0)                     # séjours de la même journée
# filter(SOR_MOD != "9")                  # décès (ex. avant une ré-hospitalisation)
# filter(AGE_ANN >= 18)                   # restriction d'âge (ou en 01 si c'est un
#                                         # critère d'inclusion)

pop_02_exclusion <- compute_session(etape_02c, "tmp_02_exclusion")
