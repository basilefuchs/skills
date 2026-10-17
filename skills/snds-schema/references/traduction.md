# Blocs de traduction en données

Questions de l'étape 3 de `SKILL.md`, par bloc. La finalité, l'unité de compte, le type d'indicateur, la base géographique et les sous-groupes viennent de `protocole.md` (`## Question`, `## Finalité`, `## Sous-groupes`) : ils se traduisent en colonnes sans question. Un bloc ne donne lieu à une question que si le protocole le laisse ouvert ; sinon sa valeur entre telle quelle dans la proposition par défaut.

## Dépendances entre blocs (ordre des lots)

- **A → B** : la ou les sources retenues fixent quelles définitions de code s'appliquent — CIM-10 via le diagnostic PMSI et/ou la cause de décès CépiDc (`KI_CCI_R`/`KI_ECD_R`), CCAM via les actes PMSI et/ou `ER_CAM_F` (DCIR), ATC/CIP seulement si la pharmacie DCIR (`ER_PHA_F` + `IR_PHA_R`) est retenue.
- **A (sources combinées) → H** : plusieurs sources SNDS ensemble (PMSI + DCIR, PMSI + CAUSE_DECES) imposent le bloc Chaînage.
- **A (champ PMSI) ↔ C** : le nom des variables de position change selon le champ (`DGN_PAL`/`DGN_REL` en MCO ; `FP_PEC` [jusqu'en 2022]/`MOR_PRP`/`ETL_AFF` en SSR ; `DGN_PAL` de `T_HAD{aa}B` en HAD) ; champ multiple = une position par champ.
- **B (troncature) → vigilance** : troncature CIM-10 à 3 caractères (sur-inclusion) ou codes complets (sous-inclusion) modifie la sensibilité du critère de jugement.
- **Unité de compte patients uniques → G** : impose le chaînage fiable (codes retour PMSI à `'0'`, NIR fictifs exclus ; côté DCIR, comptage sur `IR_BEN_R.BEN_IDT_ANO`) en exclusion, pas en option.
- **D → B si source DCIR** : les millésimes déclarés d'une variable DCIR ne garantissent pas son alimentation chaque année — signaler l'incertitude pour une variable récente ou peu utilisée.
- **D (période avant 2009) si PMSI** : dates réelles de séjour absentes avant 2009, seulement le mois/année de sortie.
- **D (série traversant 2023) si SSR** : réforme SMR, `FP_PEC` non codé après le 01/03/2023.

## A. Sources SNDS

1. **Source(s)** : DCIR (soins de ville — consultations, pharmacie, actes en ville, biologie…), PMSI (séjours hospitaliers), CAUSE_DECES (cause médicale de décès), ou une combinaison. Si combinaison : **intersection** (« hospitalisés ET traités en ville pour… ») ou **union** (« suivis en ville OU hospitalisés pour… ») — les deux donnent des effectifs très différents. Défaut : la source que le phénomène de `## Question` désigne (hospitalisation → PMSI, délivrance → DCIR, décès → CAUSE_DECES).
2. **Champ(s) PMSI** (si PMSI) : MCO seul (Recommandé pour « hospitalisation ») ou MCO + SSR ; HAD et RIP sur demande explicite (filtres qualité validés via la documentation officielle, tables de diagnostics et d'actes détaillées à vérifier dans le dictionnaire, voir `modele-donnees.md`).

## B. Codes CIM-10, CCAM, ATC

3a. **Codes CIM-10** (pathologie) : liste précise proposée avec sa source (voir `SKILL.md`, étape 3), amendable. Exemples : diabète = E10–E14 (diabète gestationnel O24 inclus ?) ; AVC = I60–I64. **Troncature** à 3 caractères ou codes complets ? Et, selon A : recherchés via le diagnostic PMSI (DP/DR/DAS) et/ou via la cause de décès CépiDc (cause initiale `KI_CCI_R.DCD_CIM_COD` ou toutes causes mentionnées `KI_ECD_R.ECD_CIM_COD`) ?
3b. **Codes CCAM** (acte) : même exigence. En ville (`ER_CAM_F`), un acte = triplet code + activité + phase (`CAM_PRS_IDE` + `CAM_ACT_COD` + `CAM_TRT_PHA`) ; en hospitalisation, `T_MCO{aa}A.CDC_ACT` (en SSR `T_SSR{aa}CCAM`, 2009+). Codes complets ou motif partiel (`REGEXP_LIKE`) ?
3c. **Codes ATC/CIP** (traitement) : classe ATC (`^B01` anticoagulants, `^N06AB` ISRS) via `IR_PHA_R.PHA_ATC_CLA`, ou liste de CIP13 (`ER_PHA_F.PHA_PRS_C13`). Motif ou liste fermée ? Primo-délivrance, délivrance à une date, ou exposition cumulée sur une période ?

## C. Position du diagnostic (si PMSI et pathologie)

4. DP seul (« hospitalisé POUR », Recommandé pour un motif d'hospitalisation) ; DP ou DR ; DP, DR ou DAS (« hospitalisé AVEC », prévalence hospitalière, effectifs bien plus larges). En SSR : `FP_PEC` (2006-2022), `MOR_PRP`, `ETL_AFF` — lequel ou lesquels. En HAD : `DGN_PAL` de `T_HAD{aa}B`.

## D. Période et millésimes

5. Années de `## Question` (T), bornes incluses, année PMSI = année de sortie. Vérifier dans `$D` que chaque table et variable retenue couvre chaque année ; une rupture (variable DCIR récente, PMSI avant 2009, SSR après 2022, `EXT_PMSI` avant 2015) devient une question (variable alternative, restriction de période) ou un point de vigilance.

## E. Lecture par année ou cohorte (si évolution ou patients uniques pluriannuels)

6. Patients uniques **par année** (un patient peut apparaître plusieurs années) ou **cohorte** dédupliquée sur toute la période ? Les deux lectures sont valides — faire choisir ; Recommandé : par année pour une évolution.

## F. Dénominateur externe (si taux)

7. Le SNDS ne contient pas de population de référence : un taux pour 100 000 habitants demande une population INSEE (année, maille : France, région, département) fournie par la personne, un taux standardisé une population de référence et la méthode (directe, bornes des classes d'âge). Noter dans `## Données` ce qui est fourni et ce qui reste **À préciser**.

## G. Exclusions qualité

Défauts du profil (`profils/hdh_oracle.md`, « Défauts recommandés ») ; une question seulement sur ce qui dépend du phénomène :

8. **Séances** (MCO, GHM `28*`) : exclues (Recommandé quand on compte des hospitalisations) ou incluses ?
9. **GHM/GME en erreur** (`90*`) : exclus par défaut.
10. **Doublons de transmission** (MCO, 2005-2017 seulement) : établissements APHP/APHM/HCL — exclus par défaut, liste à jour à récupérer sur la documentation officielle, jamais codée en dur.
11. **Chaînage en erreur** : codes retour PMSI (`NIR_RET`, `NAI_RET`, `SEX_RET`, `SEJ_RET`, `FHO_RET`, `PMS_RET`, `DAT_RET` depuis 2006, `COH_NAI_RET`/`COH_SEX_RET` depuis 2013) différents de `'0'` et `NIR_ANO_17` fictifs — exclus dès que l'on compte des patients, perte à quantifier. Côté DCIR : `DPN_QLF` et `PRS_DPN_QLP` hors 71/72 (en gérant les `NULL`), établissements ex-DG en facturation directe (`ER_ETE_F.ETE_IND_TAA`).
12. Selon le contexte : prestations inter-établissements (`SEJ_TYP = 'B'`, exclues par défaut en MCO), séjours de la même journée, nouveau-nés, IVG, décès en cours de séjour…

## H. Chaînage inter-sources (si plusieurs sources)

13. `NIR_ANO_17` (PMSI) = `BEN_NIR_PSA` (DCIR) ; l'individu est `IR_BEN_R.BEN_IDT_ANO` (un individu peut porter plusieurs `BEN_NIR_PSA`) ; causes de décès par `BEN_IDT_ANO`, appariement incomplet (`DCD_IDT_TOP`). Faire choisir la méthode de déduplication et noter que la perte de chaînage sera quantifiée (voir `modele-donnees.md`, « Chaînage patient »).
