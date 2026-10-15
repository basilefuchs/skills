# ==============================================================================
# main.R — enchaîne les étapes du protocole dans l'ordre
# Dossier : <nom du dossier, ex. patients_diabete_mco_2021_2024/>
# ==============================================================================
# Exécution complète : depuis ce dossier, source("main.R") recrée tout,
# tables de session comprises.
#
# Relancer une seule étape : tant que la session R (donc la connexion
# Oracle) est ouverte, les tables de session des étapes précédentes existent
# encore ; après modification de 03_critere_jugement.R, par exemple,
# source("03_critere_jugement.R", encoding = "UTF-8") suffit, puis les étapes
# suivantes. Session fermée : les tables ont disparu, relancer main.R.
#
# Rien à nettoyer en fin d'exécution : les lignes des tables de session
# disparaissent à la déconnexion (dbDisconnect(conn) quand le travail est
# fini). Règle SNDS : aucun fichier local avec identifiant, date ou
# localisation individuelle (00_setup.R).
#
# Une étape absente du protocole validé (ex. aucune covariable) est omise du
# dossier et de cette liste ; la numérotation des autres ne change pas.

source("00_setup.R",            encoding = "UTF-8")  # en-tête, packages, paramètres, connexion
source("01_inclusion.R",        encoding = "UTF-8")  # tables SNDS         -> tmp_01_inclusion
source("02_exclusion.R",        encoding = "UTF-8")  # tmp_01_inclusion     -> tmp_02_exclusion
source("03_critere_jugement.R", encoding = "UTF-8")  # tmp_02_exclusion     -> tmp_03_critere_jugement
source("04_covariables.R",      encoding = "UTF-8")  # tmp_03_critere_jugement -> tmp_04_covariables
source("05_flowchart.R",        encoding = "UTF-8")  # objet attrition      -> flowchart
source("06_sorties.R",          encoding = "UTF-8")  # dernière table tmp_  -> résultat, figure, export
