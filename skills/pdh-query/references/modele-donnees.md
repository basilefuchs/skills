# Modèle de données — base nationale ATIH (Teradata)

> **Priorité des sources** : les profils `references/profils/portail_atih_<champ>.md`
> décrivent l'environnement réel (mapping validé, pièges, défauts recommandés) et
> **font foi** en cas de contradiction avec ce document. Ce document reste utile pour
> la vue d'ensemble et ce que les profils ne couvrent pas.

## Organisation générale

Une **base (schéma Teradata) par champ et par millésime**. Dans le dictionnaire, le nom
de librairie contient `xx` = millésime sur 2 chiffres (année de la base = année de
**sortie** du séjour). Sur le portail ATIH (environnement de l'utilisateur), les
schémas réels suivent le motif `prd_vue_<champ>_<AAAA>` :

| Librairie dictionnaire | Schéma réel (ex. 2022) | Champ |
|---|---|---|
| `mcoxxbd` | `prd_vue_mco_2022` | MCO (médecine-chirurgie-obstétrique) |
| `ssrxxbd` | `prd_vue_smr_2022` | SSR / SMR (soins médicaux et de réadaptation) |
| `hadxxbd` | `prd_vue_had_2022` | HAD (hospitalisation à domicile) |
| `psyxxbd` | `prd_vue_psy_2022` | Psychiatrie (RIM-P) |
| `rpuxx`   | `prd_vue_rpu_2022` (à vérifier) | Urgences (RPU) |
| `nom_pmsi` | `prd_vue_nompmsi` (non millésimé) | Nomenclatures PMSI |
| `nom_gen` | `prd_vue_nomgen` (non millésimé) | Référentiels généraux |
| `agg_pmsi` | `prd_vue_aggpmsi` (à vérifier) | Agrégats |

En dbplyr, référencer les tables avec `I()` (convention maison) :
`tbl(conn, I("prd_vue_mco_2022.fixe"))` ou
`tbl(conn, I(paste0("prd_vue_mco_", an, ".fixe")))`.

Les colonnes `andeb`/`anfin` du dictionnaire donnent la plage de millésimes (16 → 26,
c.-à-d. 2016 → 2026) où la variable existe. **Toujours vérifier cette plage** pour les
requêtes pluriannuelles ; une variable peut apparaître ou disparaître en cours de période.

## MCO — tables clés

- **`fixe`** : 1 ligne par **séjour (RSA)**. Variables : `dp`, `dr` (diagnostic principal
  et relié), `annee` (année de sortie = année de la base), `mois`, `age`, `agejour`,
  `sexe`, `duree` (nuitées), `codegeo` (code géographique de résidence), `finess`,
  `ghm2` (GHM), `nbseance`, `modeentree`/`modesortie` (9 = décès en sortie),
  `date_entree`/`date_sortie`, `anonyme` (clé de chaînage), `ano_retour`,
  `ident` (clé de jointure, 6 caractères).
- **`diag`** : diagnostics **associés** (DAS), 1 ligne par diagnostic ; jointure `ident`.
- **`um`** : 1 ligne par RUM (passage en unité médicale) ; `dpdurum`, `drdurum` — utile
  pour une définition « DP de séjour OU DP d'UM ».
- **`acte`** : actes CCAM ; jointure `ident`.
- **`finessgeo_umdudp`** : FINESS **géographique** du RUM ayant fourni le DP
  (`finessgeodp`), jointure `ident` — c'est la table à utiliser pour une analyse
  par site (le `finess` de `fixe` est l'entité juridique pour les publics).
- **`med`, `dmip`…** : molécules onéreuses, DMI.
- Tables `_lamda_*` = données corrigées LAMDA, `_tae_*` = traitement des données
  d'activité externe : ne pas les utiliser sauf demande explicite.

## SSR/SMR, HAD, PSY — attention au grain (voir le profil du champ, qui fait foi)

Ces champs ont **deux tables `fixe`/`fixe_sej`** dont la répartition des colonnes
varie ; toujours vérifier sur quelle vue chaque colonne est portée (profil, puis
dictionnaire) :

- **SMR** : `fixe` = 1 ligne par **séjour** (clé `ident_sej` ; `finessgeo`, `gme`,
  diagnostics `finalp`/`morbidp`/`etiolp`) ; `fixe_sej` porte `anonyme`, les dates.
- **HAD** : `fixe_sej` = 1 ligne par **séjour** (clé `ident_sej` ; `anonyme`,
  `ano_retour`, `finessgeo`, `duree` en journées, dates) ; `fixe` porte le `dp`,
  `codegeo`. Un séjour HAD couvre N journées : sommer `duree` pour des journées.
- **PSY** : `fixe` = 1 ligne par **séquence RPSA** (clé `ident`, séjour `ident_sej` ;
  `dp`, `fa` forme d'activité, `nbjseq` journées, `nbdemijseq` demi-journées,
  `finess`, `finessgeo`, `annee` = année de FIN de séquence). Temps plein =
  FA 01-07 (définition ATIH) ; ambulatoire (FA 16-17) hors périmètre journées ;
  demi-journées comptées × 0,5. `anonyme` est sur `fixe_sej`.

Diagnostics « principaux » selon le champ :

| Champ | Variables diagnostiques (table `fixe`) | DAS |
|---|---|---|
| MCO | `dp`, `dr` | table `diag` |
| SSR | `finalp` (finalité), `morbidp` (manifestation morbide principale), `etiolp` (étiologie) | table `diag` |
| HAD | `dp` (+ `nbdcmpp`/`nbdcmpa` : diags liés aux modes de prise en charge) | table `diag` |
| PSY | `dp` | table `diag` |
| RPU | `dp` et `motif` (table `passage`) | table `diag` |

Un même séjour SSR/HAD/PSY a plusieurs lignes `fixe` : pour compter des séjours,
sélectionner les `ident_sej` **distincts** répondant au critère diagnostique, puis
joindre `fixe_sej`.

## RPU (urgences)

Table **`passage`** : 1 ligne par passage aux urgences (`dp`, `motif`, `age`, `sexe`,
`gravite`, `orientation`, dates/heures). Pas de clé de chaînage patient → comptage en
passages uniquement. Couverture non exhaustive selon les années : le signaler.

## Chaînage patient (compter des patients uniques)

- Clé : **`anonyme`** (pseudonyme national, commun à tous les champs → permet aussi le
  suivi inter-champs). Dans `fixe` (MCO) ou `fixe_sej` (SSR/HAD/PSY).
- **Qualité obligatoire** : ne garder que les séjours où `ano_retour` (concaténation de
  9 codes retour) vaut `'000000000'` — sinon la clé n'est pas fiable (patient compté
  plusieurs fois). Mentionner dans la note méthodologique la part de séjours exclus.
- Patients uniques sur plusieurs années : `n_distinct(anonyme)` **sur l'union des
  années**, pas la somme des distincts annuels.

## Nomenclatures et référentiels utiles (schémas `prd_vue_nompmsi` / `prd_vue_nomgen`)

- `prd_vue_nompmsi.all_cim10` : libellés CIM-10 (aussi `all_cim10_hiera` pour la hiérarchie).
- `prd_vue_nompmsi.all_ccam` : libellés CCAM.
- `prd_vue_nompmsi.all_classif_pmsi` : ensemble des codes des classifications par
  année (`champ`, `type_code` — ex. `racine`, `gn` —, `code`, `date_deb`) ; sert de
  dénombrement des codes possibles.
- `prd_vue_nomgen.all_corresp_geo` : correspondance `codegeo` → commune/département/région
  (attention codes `ZE20_CODE = NR` pour l'outre-mer non couvert).
- `prd_vue_nomgen.pop_com_sex_ag` : population INSEE par commune, sexe, âge →
  dénominateurs pour des taux.
- `prd_vue_nomgen.finess`, `finessgeo` : référentiel établissements — `finessgeo` est
  millésimé (colonne `annee`) et porte la raison sociale `rs` ; joindre sur
  `(finessgeo, annee)` pour libeller les établissements.

## Raccourcis de classification usuels

- Racine de GHM (5 caractères) : `substr(ghm2, 1, 5)` ; CMD : `substr(ghm2, 1, 2)`.
- Niveau de sévérité du GHM : `substr(ghm2, 5, 5)` (`3`/`4` = sévérité élevée ;
  `J`/`T` = ambulatoire/très courte durée).
- Groupe nosologique du GME (SMR, 4 caractères) : `substr(gme, 1, 4)`.
- Exclusion des groupes erreur : `substr(ghm2, 1, 2) != "90"` (MCO),
  `substr(gme, 1, 2) != "90"` (SMR).
- Modes de sortie (`modesortie`) : `6` = mutation, `7` = transfert, `8` = domicile,
  `9` = décès — `6`/`7` servent de proxy « sortie vers l'aval ».
- `nbexh` (journées au-delà de la borne extrême haute) : proxy usuel des journées
  de « bed-blocking » ; `nbexb`/`exb` pour la borne basse.
- Listes de caractéristiques patient : `prd_vue_nompmsi.all_cim10_caract_patient`
  (`code` CIM-10, `caract`, `type_liste` — ex. `Socio_eco` pour la précarité).

## Filtres CIM-10 : substr ou regex Teradata

- Listes simples de codes : `substr(dp, 1, 3) %in% c("E10", ...)`.
- Motifs complexes : regex **disponible** via `REGEXP_SIMILAR` en SQL brut :
  `filter(sql("REGEXP_SIMILAR(diag, '^(F0[0-3]|G30|A810).*', 'c') = 1"))`
  (`'c'` = sensible à la casse). C'est le pattern maison pour les définitions
  multi-racines (ex. démences = F00-F03 + G30).

## Pièges classiques (à vérifier / signaler systématiquement)

1. **Année PMSI = année de sortie** : un séjour 12/2021 → 01/2022 compte en 2022.
   L'incidence par date d'entrée nécessite `annee_entree`.
2. **Séances (MCO)** : dialyse, chimio, radiothérapie = GHM commençant par `28`
   (`substr(ghm2,1,2) == '28'`) ou `nbseance > 0`. Un diabétique dialysé peut générer
   150 « séjours »/an → toujours demander si on les inclut.
3. **GHM en erreur** : `substr(ghm2,1,2) == '90'` → exclure par défaut.
4. **Doublons de transmission** : la base nationale est déjà dédoublonnée, mais les
  séjours `fictif`/prestations inter-établissements (`typ_sej` PIE) peuvent compter
  double un même malade entre deux FINESS.
5. **France entière vs résidents** : filtrer sur l'implantation (`finess`) ou sur la
   résidence (`codegeo`) ne donne pas le même résultat — à faire préciser.
6. **Évolutions de codage** : changements de consignes CIM-10/GHM entre années ;
   prudence sur l'interprétation des tendances.
7. **Droits d'accès** : la colonne `droits` du dictionnaire liste qui voit la variable
   (ATIH, ARS, FD, INSTI…). Si le profil de l'utilisateur est restreint, certaines
   variables (montants notamment) peuvent être absentes de sa vue.
8. **Codes CIM-10 stockés sans point** (`E101` et non `E10.1`) : matcher par
   `substr()`/`%in%` sur les codes compactés.
9. **Jointures `diag`/`acte`** : N lignes par séjour → `distinct(ident)` avant tout
   comptage de séjours.
10. **IPP chaîné** : `id_hospit_ipp.ipp_c` (MCO) offre un chaînage inter-séjours
    alternatif au couple `anonyme`/`ano_retour`.

Les pièges propres à l'environnement (disponibilité des dates réelles, tarifs,
codes destination…) sont listés dans le profil du champ concerné, qui fait foi.
