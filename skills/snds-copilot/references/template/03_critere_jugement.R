# ==============================================================================
# 03_critere_jugement.R — critère de jugement au niveau séjour
# Table attendue : tmp_02_exclusion (objet R : pop_02_exclusion)
# Table produite : tmp_03_critere_jugement (objet R : pop_03_critere_jugement)
#                  = population analysée + colonne(s) du critère de jugement
# ==============================================================================
# Critère validé : <ex. patients uniques (NIR_ANO_17) par année>
# Ici : unité de compte et variables dérivées, 1 ligne par séjour. L'agrégation
# (par année, par strate, sur toute la période) est faite en 06_sorties.R.
# Le pseudonyme NIR_ANO_17 est fiable : codes retour filtrés en 02_exclusion.R.

pop_03_critere_jugement <- pop_02_exclusion |>
  mutate(
    # Variables dérivées selon le critère validé (supprimer celles sans objet) :
    sejour_id = paste0(ETA_NUM, "-", RSA_NUM),         # clé séjour composite (-> ||)
    journees  = SEJ_NBJ,                               # journées : sum() en 06
    deces     = if_else(SOR_MOD == "9", 1L, 0L)        # mortalité hospitalière
  ) |>
  compute_session("tmp_03_critere_jugement")

# Effectif inchangé en général ; le noter trace l'étape dans le flowchart
# (un critère restrictif, ex. ré-hospitalisation à 30 jours, y ferait une perte).
attrition <- noter_attrition(attrition, pop_03_critere_jugement, "03 Critere de jugement")

# -- Lectures d'une « évolution » (clarification Q15) --------------------------
# Patients uniques PAR ANNÉE (un patient peut compter plusieurs années) et
# cohorte dédupliquée SUR LA PÉRIODE se calculent toutes deux en 06_sorties.R
# à partir de cette table ; aucune colonne supplémentaire n'est nécessaire.

# -- Variante : individus au sens strict (DCIR ou décès mobilisés, Q13) --------
# NIR_ANO_17 est un pseudonyme d'ouvreur de droit (= BEN_NIR_PSA) ; l'individu
# est IR_BEN_R.BEN_IDT_ANO, à rattacher ici (une colonne de plus dans la table
# de session) selon modele-donnees.md, « Chaînage patient » — jointure sur
# (BEN_NIR_PSA, BEN_RNG_GEM) côté DCIR, filtres qualité population de IR_BEN_R
# (profils/hdh_oracle.md) appliqués avant.

# -- Variante : statut vital à N jours (létalité) -----------------------------
# Décès hospitalier : SOR_MOD == "9" (ci-dessus). Décès toutes causes : date
# IR_BEN_R.BEN_DCD_DTE (sentinelle 1600 = aucun décès connu ; exhaustivité
# limitée, points-de-vigilance.md « Statut vital ») et/ou KI_CCI_R via
# BEN_IDT_ANO ; fixer la règle de priorité entre dates dans le protocole.

# -- Variante : taux pour 100 000 habitants (Q14) ------------------------------
# Le dénominateur (population INSEE par département/âge/sexe, hors SNDS) se
# joint en 06_sorties.R sur l'agrégat collecté, pas ici.
