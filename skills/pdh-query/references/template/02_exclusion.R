# ==============================================================================
# 02_exclusion.R — exclusions successives
# Table attendue : tmp_01_inclusion (objet R : pop_01_inclusion)
# Table produite : tmp_02_exclusion (objet R : pop_02_exclusion)
# ==============================================================================
# Exclusions validées, dans l'ordre : <ex. séances (CMD 28), GHM en erreur (90),
# chaînage en erreur>. Chaque exclusion est notée dans `attrition` : le
# flowchart montre la perte de chacune.

etape_02a <- pop_01_inclusion %>%
  filter(substr(ghm2, 1, 2) != "28")                   # séances (si exclues)
attrition <- noter_attrition(attrition, etape_02a, "02a hors seances (CMD 28)")

etape_02b <- etape_02a %>%
  filter(substr(ghm2, 1, 2) != "90")                   # séjours en erreur
attrition <- noter_attrition(attrition, etape_02b, "02b hors GHM en erreur (90)")

etape_02c <- etape_02b %>%
  filter(ano_retour == "000000000")                    # chaînage fiable : obligatoire
                                                       # pour compter des patients
attrition <- noter_attrition(attrition, etape_02c, "02c chainage exploitable")

# -- Autres exclusions selon le protocole (`# Protocole validé`) --------------
# filter(duree > 0)                 # séjours de la même journée
# filter(modesortie != "9")         # décès (ex. avant une ré-hospitalisation)
# filter(age >= 18)                 # restriction d'âge (ou en 01 si c'est un
#                                   # critère d'inclusion)
# filter(typ_sej != "<PIE>")        # prestations inter-établissements

pop_02_exclusion <- compute_volatile(etape_02c, "tmp_02_exclusion")
