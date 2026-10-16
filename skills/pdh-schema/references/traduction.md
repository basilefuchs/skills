# Blocs de traduction en données

Questions de l'étape 3 de `SKILL.md`, par bloc. La finalité, l'unité de compte, le type d'indicateur, la base géographique et les sous-groupes viennent de `protocole.md` (`## Question`, `## Finalité`, `## Sous-groupes`) : ils se traduisent en colonnes sans question. Un bloc ne donne lieu à une question que si le protocole le laisse ouvert ; sinon sa valeur entre telle quelle dans la proposition par défaut.

## Dépendances entre blocs (ordre des lots)

- **A ↔ C** : le nom des variables de position change selon le champ (`dp`/`dr` en MCO ; `finalp` [jusqu'en 2022]/`morbidp`/`etiolp` en SMR ; `dp` en HAD et PSY ; `dp` ou `motif` en RPU) ; champ multiple = une position par champ.
- **A (plusieurs champs) → H** : le chaînage inter-champs se vérifie à part du chaînage intra-champ ; le RPU n'a pas de clé patient.
- **B (pathologie et acte)** : une question qui mêle diagnostic et acte (« AVC traité par thrombectomie ») demande l'opérateur, intersection (DP AVC **et** acte) ou union (DP AVC **ou** acte, périmètre bien plus large).
- **B (troncature, motif) → vigilance** : troncature CIM-10 à 3 caractères ou motif CCAM partiel (sur-inclusion), codes complets (sous-inclusion) : la sensibilité du critère de jugement change.
- **Unité de compte patients uniques → G** : impose le chaînage fiable (`ano_retour == "000000000"`) en exclusion, pas en option ; en RPU, comptage en passages seulement.
- **D → E** : pour une évolution, le nombre d'années va avec la lecture choisie (par année ou cohorte dédupliquée).
- **D (dates réelles avant 2019)** : `date_entree`/`date_sortie` absentes avant 2019 (MCO, HAD) ; une incidence par date d'entrée ou un délai restreint la période.
- **D (série traversant 2023) si SMR** : `finalp` n'existe plus après 2022.

## A. Champs PMSI

1. **Champ(s)** : MCO seul (Recommandé pour « hospitalisation »), ou MCO avec SMR, HAD, PSY ; RPU (urgences) séparément, en passages, profil partiel dont le schéma est à confirmer. Plusieurs champs : **intersection** ou **union**, deux effectifs très différents. Défaut : le champ que le phénomène de `## Question` désigne.

## B. Codes CIM-10, CCAM, CSARR

2a. **Codes CIM-10** (pathologie) : liste précise proposée avec sa source (voir `SKILL.md`, étape 3), amendable. Exemples : diabète = E10–E14 (diabète gestationnel O24 inclus ?) ; Parkinson = G20 (maladie de Parkinson) ou G20–G22 (syndromes parkinsoniens). Libellés dans `prd_vue_nompmsi.all_cim10` ; codes stockés sans point. **Troncature** à 3 caractères ou codes complets ?
2b. **Codes CCAM** (acte, 7 caractères : 4 lettres et 3 chiffres) : même exigence, nomenclature `prd_vue_nompmsi.all_ccam`. Certains périmètres se définissent par un **motif** plutôt qu'une liste (médecine nucléaire = 4ᵉ lettre « L »). Codes complets ou motif partiel ? Acte principal ou associé ? Séjours MCO seulement, ou aussi actes et consultations externes (RSF, voir le profil du champ) ?
2c. **Codes CSARR** (rééducation en SMR, table `acte_csarr`) : même exigence.

## C. Position du diagnostic (si pathologie)

3. DP seul (« hospitalisé POUR », Recommandé pour un motif d'hospitalisation) ; DP ou DR ; DP, DR ou DAS (table `diag`, « hospitalisé AVEC », effectifs bien plus larges) ; en MCO, DP d'UM (`um.dpdurum`) en plus du DP de séjour ? En SMR : `finalp`, `morbidp`, `etiolp` — lequel ou lesquels. En HAD et PSY : `dp`. En RPU : `dp` ou `motif`.

## D. Période et années

4. Années de `## Question` (T), bornes incluses, année PMSI = année de sortie (PSY : année de fin de séquence), dans la plage du profil. Vérifier dans le dictionnaire que chaque table et variable retenue couvre chaque année (`andeb` ≤ année ≤ `anfin`) ; une rupture devient une question (variable alternative, restriction de période) ou un point de vigilance.

## E. Lecture par année ou cohorte (si évolution ou patients uniques pluriannuels)

5. Patients uniques **par année** (un patient peut apparaître plusieurs années) ou **cohorte** dédupliquée sur toute la période (`anonyme` distincts sur l'union des années) ? Les deux lectures sont valides — faire choisir ; Recommandé : par année pour une évolution.

## F. Dénominateur (si taux)

6. Population INSEE de `prd_vue_nomgen.pop_com_sex_ag` (commune, âge, sexe, `annee_pop`), ramenée au `codegeo` PMSI par `corresp_code_com_geo_ts_pop` : année de population et maille (France, région, département). Un taux standardisé demande en plus une population de référence et la méthode (directe, bornes des classes d'âge), fournies par la personne ; noter dans `## Données` ce qui reste **À préciser**.

## G. Exclusions qualité

Défauts du profil du champ (« Pièges », « Défauts recommandés ») ; une question seulement sur ce qui dépend du phénomène :

7. **Séances** (MCO, GHM `28*`, `nbseance`) : exclues (Recommandé quand on compte des hospitalisations) ou incluses ?
8. **Groupage en erreur** : GHM `90*` (MCO), GME `90*` (SMR) — exclus par défaut.
9. **Chaînage en erreur** (`ano_retour != "000000000"`) : exclu dès que l'on compte des patients, perte à quantifier.
10. Selon le contexte : séjours de la même journée (`duree == 0`), nouveau-nés, IVG, prestations inter-établissements (`typ_sej`), décès en cours de séjour (`modesortie == "9"`), formes d'activité ambulatoires en PSY (FA 16-17)…

## H. Chaînage inter-champs (si plusieurs champs)

11. `anonyme`, commun à MCO, SMR, HAD et PSY, porté par `fixe` (MCO) ou `fixe_sej` (SMR, HAD, PSY), avec son `ano_retour` dans chaque champ ; le RPU reste hors chaînage. En MCO, l'IPP chaîné (`id_hospit_ipp.ipp_c`) est une alternative. Noter que la perte de chaînage sera quantifiée (voir `modele-donnees.md`, « Chaînage patient »).
