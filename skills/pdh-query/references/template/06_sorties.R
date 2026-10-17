# ==============================================================================
# 06_sorties.R — résultats, figure, écriture de sorties/
# Table attendue : tmp_04_covariables (objet R : pop_04_covariables),
#                  ou tmp_03_critere_jugement si le protocole n'a pas de covariable
# Produit        : objets R `resultat_annuel`, `nb_patients_periode`,
#                  `strate_<variable>` (une table par stratification) ;
#                  fichiers sorties/resultat_annuel.csv, nb_patients_periode.csv,
#                  strate_<variable>.csv, figure_resultat_annuel.png
# ==============================================================================
# Le calcul reste côté Teradata ; collect() uniquement sur les agrégats. Seuls
# des agrégats sont écrits, par exporter(), sous seuil.

pop_analyse <- pop_04_covariables      # pop_03_critere_jugement si 04 omis

# ==== RÉSULTAT ====
# -- Agrégats par année ---------------------------------------------------------
resultat_annuel <- pop_analyse %>%
  group_by(annee) %>%
  summarise(
    nb_sejours  = n(),                 # 1 ligne = 1 séjour (ident est annuel :
                                       # n_distinct(ident) n'a de sens que par année)
    nb_patients = n_distinct(anonyme)  # patients uniques PAR ANNÉE
  ) %>%
  collect() %>%
  mutate(annee = as.integer(annee)) %>%     # annee : caractère dans fixe (dictionnaire)
  arrange(annee)

# -- Patients uniques SUR TOUTE LA PÉRIODE : n_distinct sur l'empilement des
#    années (fait en 01), jamais la somme des distincts annuels ----------------
nb_patients_periode <- pop_analyse %>%
  summarise(nb_patients = n_distinct(anonyme)) %>%
  collect()

# -- Tables stratifiées : une par variable de stratification du protocole -------
# (strate_sexe_lib, strate_classe_age…), par année, aucune sans stratification ;
# le pourcentage est une colonne dérivée, masquée avec les effectifs de sa ligne.
# Masque primaire : une modalité masquée seule se déduit du total de l'année
# (nb_sejours de resultat_annuel.csv), et le pourcentage d'une ligne visible
# redonne lui aussi le total des nb_patients ; le regroupement sous "Autre"
# ci-dessous en est la parade.
strate_classe_age <- pop_analyse %>%
  group_by(annee, classe_age) %>%
  summarise(nb_sejours = n(), nb_patients = n_distinct(anonyme), .groups = "drop") %>%
  collect() %>%
  mutate(annee = as.integer(annee)) %>%
  # Regroupement sous "Autre", à proposer si la table compte des cellules
  # masquées : modalités < seuil regroupées puis ré-agrégées avant exporter(),
  # moins de cellules masquées et des totaux justes.
  # mutate(classe_age = if_else(nb_patients < seuil, "Autre", classe_age)) %>%
  # group_by(annee, classe_age) %>%
  # summarise(across(c(nb_sejours, nb_patients), sum), .groups = "drop") %>%
  group_by(annee) %>%
  mutate(pct_patients = round(100 * nb_patients / sum(nb_patients), 1)) %>%
  ungroup() %>%
  arrange(annee, classe_age)

# -- Libellés (référentiels) : joints en R sur l'agrégat collecté --------------
# ref_finessgeo <- tbl(conn, I("prd_vue_nomgen.finessgeo")) %>%
#   filter(annee %in% annees) %>%
#   select(annee, finessgeo, rs) %>%
#   distinct() %>%
#   collect()
# resultat_annuel %>% left_join(ref_finessgeo, by = c("annee", "finessgeodp" = "finessgeo"))

# -- Indicateur méthodologique (Gini, entropie, taux standardisé…) -------------
# Teradata sort la DISTRIBUTION agrégée (ex. annee x etab x profil x effectif),
# le calcul final se fait en R sur ce petit tableau. Prévoir des seuils de
# stabilité (effectif minimum par cellule/profil) en paramètres de 00_setup.R.
# Un taux est une colonne dérivée : derivees = "taux" dans exporter().

# ==== ÉCRITURE DE sorties/ ====
annuel_ecrit     <- exporter(resultat_annuel, "resultat_annuel.csv",
                             comptages = c("nb_sejours", "nb_patients"))
periode_ecrit    <- exporter(nb_patients_periode, "nb_patients_periode.csv",
                             comptages = "nb_patients")
classe_age_ecrit <- exporter(strate_classe_age, "strate_classe_age.csv",
                             comptages = c("nb_sejours", "nb_patients"),
                             derivees = "pct_patients")

# ==== ÉCRAN : brut, ou tel qu'écrit si secret_statistique (00_setup.R) ====
if (secret_statistique) {
  print(annuel_ecrit); print(periode_ecrit); print(classe_age_ecrit)
} else {
  print(resultat_annuel); print(nb_patients_periode); print(strate_classe_age)
}

# ==== FIGURE : resultat_annuel, toujours (critère de jugement en y) ====
# Construite uniquement depuis un agrégat écrit (objet renvoyé par exporter()) :
# une barre masquée n'apparaît pas.
figure_annuelle <- ggplot(annuel_ecrit, aes(x = annee, y = nb_patients)) +
  geom_col() +
  scale_x_continuous(breaks = annees) +
  theme_minimal()
exporter(figure_annuelle, "figure_resultat_annuel.png")
