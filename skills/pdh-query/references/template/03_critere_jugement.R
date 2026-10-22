# ==============================================================================
# 03_critere_jugement.R — critère de jugement au niveau séjour
# Table attendue : tmp_02_exclusion (objet R : pop_02_exclusion)
# Table produite : tmp_03_critere_jugement (objet R : pop_03_critere_jugement)
#                  = population analysée + colonne(s) du critère de jugement
# ==============================================================================
# Critère validé : <ex. patients uniques (clé anonyme) par année>
# Ici : unité de compte et variables dérivées, 1 ligne par séjour. L'agrégation
# (par année, par strate, sur toute la période) est faite en 06_sorties.R.
# La clé anonyme est fiable : ano_retour filtré en 02_exclusion.R.

pop_03_critere_jugement <- pop_02_exclusion %>%
  mutate(
    # Variables dérivées selon le critère validé (supprimer celles sans objet) :
    journees = duree,                                  # journées : sum() en 06
    deces    = if_else(modesortie == "9", 1L, 0L)      # mortalité hospitalière
  ) %>%
  compute_volatile("tmp_03_critere_jugement")

# Effectif inchangé en général ; le noter trace l'étape dans le flowchart
# (un critère restrictif, ex. ré-hospitalisation à 30 jours, y ferait une perte).
attrition <- noter_attrition(attrition, pop_03_critere_jugement, "03 Critere de jugement")

# -- Lectures d'une « évolution » (période de `# Données`) --------------
# Patients uniques PAR ANNÉE (un patient peut compter plusieurs années) et
# cohorte dédupliquée SUR LA PÉRIODE se calculent toutes deux en 06_sorties.R
# à partir de cette table ; aucune colonne supplémentaire n'est nécessaire.

# -- Variante : taux pour 100 000 habitants ------------------------------------
# Le dénominateur (prd_vue_nomgen.pop_com_sex_ag, agrégé au niveau voulu) se
# joint en 06_sorties.R sur l'agrégat collecté, pas ici.
