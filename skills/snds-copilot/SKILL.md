---
name: snds-copilot
description: >
  Copilote d'une requête SNDS que l'utilisateur écrit lui-même (SQL Oracle,
  R dbplyr) sur le Health Data Hub : relecture d'une requête collée, table ou
  variable à trouver, fragment à écrire.
license: MIT
---

# Copilote de requête SNDS

L'utilisateur tient le clavier : il écrit sa requête SNDS (SQL Oracle ou R
dbplyr) sur le Health Data Hub et vient avec une requête à relire, une
question sur le dictionnaire ou une étape à écrire. Répondre directement,
sans protocole ni question de cadrage préalable ; une ambiguïté se signale en
une ligne dans la réponse, avec le choix retenu.

Hors du parcours question → protocole → scripts, la skill y intervient en un
point : après une erreur d'exécution d'un dossier de scripts généré par
`snds-query`, la relecture du fichier en cause est le chemin de correction
(mode relecture).

## Deux arrêts

Avant tout mode, deux cas se règlent en un seul message, puis arrêt :

- **Question de recherche en langage naturel** (« combien de patients
  diabétiques hospitalisés en 2023 ? ») : « Cadrez d'abord la question :
  `/question-recherche-pico <question>`. » Rien d'autre.
- **Données individuelles collées** : extrait de table, résultat ou message
  d'erreur à une ligne par personne, séjour, prestation ou décès (valeurs
  d'un identifiant comme `NIR_ANO_17`, `BEN_NIR_PSA`, `BEN_IDT_ANO`,
  `RSA_NUM`, dates au jour). Arrêt net : le message nomme le signe sans
  citer une valeur ni une ligne, demande de retirer ces données de la
  conversation et rappelle que seule la procédure d'export de la plateforme
  fait sortir des données, sous forme d'agrégats. Rien d'autre : la requête
  ou la question collée avec elles se reprend une fois les données retirées.

## Ressources

Ordre d'autorité : **filtres et méthodologie** — documentation officielle du
Health Data Hub > profil > autres références ; **environnement** (connexion,
schéma, nommage des tables) — profil seul. Les chemins sont relatifs au
répertoire de base de la skill.

1. **`references/profils/hdh_oracle.md`** — environnement réel : connexion,
   mapping concept → colonne validé, pièges, filtres qualité par défaut.
   Fait foi sur l'environnement. Autre environnement (export local, autre
   entrepôt) : demander une fois les équivalents à l'utilisateur et lui
   proposer d'écrire un nouveau profil dans ce répertoire.
2. **Documentation officielle du Health Data Hub**
   (https://documentation-snds.health-data-hub.fr/) — fait foi sur les
   filtres recommandés et la méthodologie, y compris contre le profil. La
   consulter via WebFetch, quand l'outil existe, en cas de doute sur un
   filtre ou pour un sujet absent des références locales (fiches
   `snds/fiches/`, schéma `snds/tables/`, liste des FINESS APHP/APHM/HCL de
   la fiche `2023-12-11_synthese_filtres_snds_v1`). Ses requêtes sont en
   MySQL : traduire pour Oracle (voir le profil). Sans accès web, le dire
   dans la réponse.
3. **Dictionnaire** `references/dictionnaire/` (TSV générés depuis le dépôt
   schema-snds du Health Data Hub, licence MPL-2.0) — tables, variables et
   millésimes, jointures déclarées, nomenclatures et leurs valeurs. Colonnes
   décrites dans son `README.md`. Version fraîche à chaque usage si le
   réseau le permet (voir « Dictionnaire »), sinon copie embarquée.
4. `references/modele-donnees.md` — modèle de données : produits, tables
   clés, chaînage patient, raccourcis de classification, pièges classiques.
5. `references/template/` — squelette du dossier de scripts de `snds-query`,
   un fichier par étape, et patterns dbplyr/Oracle validés (étapes par
   millésime, patients uniques pluriannuels, jointure DCIR à 9 colonnes,
   batch sur `FLX_DIS_DTD`), chacun dans le fichier de l'étape qui l'utilise.

Les fichiers 1, 3, 4 et 5 sont des copies, identiques à leur source : le
dictionnaire (3), `scripts/build-dictionary.py` et le modèle de données (4)
viennent de `snds-schema` ; le profil (1) et le squelette de scripts (5)
viennent de `snds-query`. Leurs renvois à `protocole.md` ou à
`points-de-vigilance.md` visent le parcours et ces autres skills : sans objet
ici.

## Dictionnaire

Au premier besoin du dictionnaire dans la conversation, tenter un clone
partiel de schema-snds (environ 7 Mo) et régénérer les TSV dans un
répertoire temporaire, depuis le répertoire de base de la skill :

```bash
TMP=$(mktemp -d)
git clone -q --depth 1 --filter=blob:none --sparse \
  https://gitlab.com/healthdatahub/applications-du-hdh/schema-snds.git "$TMP/schema-snds" &&
git -C "$TMP/schema-snds" sparse-checkout set --no-cone '/schemas/' '/nomenclatures/*/*.json' '/LICENSE' &&
python3 scripts/build-dictionary.py "$TMP/schema-snds" --out "$TMP/dico" &&
D="$TMP/dico" || D=references/dictionnaire
echo "Dictionnaire utilisé : $D"; cat "$D/SOURCE.txt"
```

- Succès : `$D` pour `tables.tsv`, `variables.tsv`, `jointures.tsv`,
  `nomenclatures.tsv`. Les valeurs des nomenclatures restent dans
  `references/dictionnaire/valeurs.tsv` (le clone partiel ne les récupère
  pas).
- Échec : copie embarquée, et le dire dans la réponse avec la date de
  `references/dictionnaire/SOURCE.txt`.

Les TSV font jusqu'à 2 Mo : filtrer par `grep` ou `awk -F'\t'`, jamais de
lecture intégrale.

```bash
grep -i "ccam" $D/tables.tsv                                 # une table par notion ou par nom
awk -F'\t' '$1=="DCIR"' $D/tables.tsv                        # toutes les tables d'un produit
awk -F'\t' '$1=="T_MCOaaB" && $2=="DGN_PAL"' $D/variables.tsv   # une variable : type, nomenclature, millésimes
awk -F'\t' '$1=="ER_CAM_F"' $D/variables.tsv | cut -f2-10    # toutes les variables d'une table
awk -F'\t' '$2=="BEN_NIR_ANO"{print $1}' $D/variables.tsv    # toutes les tables portant une colonne
awk -F'\t' '$1=="ER_PRS_F" || $3=="ER_PRS_F"' $D/jointures.tsv   # jointures déclarées d'une table
awk -F'\t' '$1=="IR_SPE_V"' references/dictionnaire/valeurs.tsv  # codes et libellés d'une nomenclature
```

Lecture des millésimes : une variable existe de `debut` à `fin` (vide =
toujours présente) sauf les années de `absente`. Les tables PMSI portent un
nom générique en `aa` (`T_MCOaaB`) ; en base, l'année sur deux chiffres
(`T_MCO23B`). Nomenclature non embarquée (`valeurs_embarquees = non`, ex.
`IR_PHA_R`, CCAM, CIM-10) : interroger la table en base, ou le CSV source
`https://gitlab.com/healthdatahub/applications-du-hdh/schema-snds/-/raw/master/nomenclatures/<ORAVAL|ORAREF>/<NOM>.csv`.
Table absente de schema-snds (`ER_GEO_LOC_R`, archives `*_ARC`, `T_SUP*`) :
le profil quand il la décrit, sinon la documentation officielle, en
signalant « non vérifié dans le dictionnaire ».

## Mode consultation

L'utilisateur cherche une table, une variable, un millésime, une
nomenclature, une jointure ou un filtre. Répondre avec le fait demandé et sa
source (dictionnaire, profil ou documentation officielle), puis ce que
l'utilisateur en fera : la colonne à filtrer, la jointure à écrire, le piège
attaché. Exemples :

- « Quelle table pour les actes CCAM en ville ? » → `ER_CAM_F`, code CCAM
  dans `CAM_PRS_IDE` (`CAM_ACT_COD` est le code activité), jointure à
  `ER_PRS_F` sur la clé technique à 9 colonnes, un acte = triplet
  `CAM_PRS_IDE` + `CAM_ACT_COD` + `CAM_TRT_PHA`.
- « `FP_PEC` existe-t-il en 2023 ? » → millésimes de `variables.tsv`, et la
  rupture SMR du profil : plus codé après le 01/03/2023.
- « Que vaut `DPN_QLF = 71` ? » → libellé dans `valeurs.tsv` si la
  nomenclature est embarquée, sinon la requête Oracle sur la table de
  valeurs.

Réponse courte : le fait, la source, la conséquence pour la requête. La
réponse est complète quand chaque table, colonne et millésime cités ont été
lus dans le dictionnaire ou le profil, pas de mémoire.

## Mode relecture

L'utilisateur colle une requête (SQL Oracle, R dbplyr lazy ou style
historique `glue()` + SQL brut, ou SAS). Lire d'abord les années, tables et
colonnes qu'elle touche, vérifier chacune dans le dictionnaire et le profil,
puis passer les sept points de la grille, dans l'ordre. Rendre :

1. **Les constats**, groupés par gravité (bloquant, à vérifier, suggestion),
   chacun en trois éléments : la ligne visée (citée), une phrase de raison,
   le correctif.
2. **La requête corrigée entière**, dans le langage de l'entrée, les
   corrections appliquées.

Une requête sans constat se dit en une ligne, avec ce qui a été vérifié
(tables, colonnes, millésimes). La relecture est complète quand les sept
points ont été passés sur chaque table et chaque année de la requête.

**Après une erreur d'exécution** d'un dossier généré par `snds-query` :
l'utilisateur colle le fichier en cause (un fichier de `scripts/` ou un chunk
de `analyse.Rmd`) et le message d'erreur. Rattacher l'erreur à sa ligne et au
point de la grille qui l'explique (`ORA-00904` : points 1 et 2 ; `ORA-01795` :
point 5 ; `ORA-00942` : schéma du profil), puis rendre ce fichier corrigé
entier. Le protocole reste intact, comme les autres fichiers du dossier. Si
l'erreur vient d'un critère du protocole, le dire en une ligne :
`/snds-schema` amende le protocole, puis `/snds-query` régénère le dossier.
Une correction n'est pas mémorisée : une régénération l'écrase.

### Grille

Gravité par défaut : points 1 à 3 **bloquant** (la requête échoue ou compte
faux), 4 à 6 **à vérifier** (résultat plausible mais biaisé ou lent), 7
**bloquant** quelle que soit la finalité (l'année PMSI : **à vérifier**).
Chaque point renvoie à sa source de détail.

1. **Existence et noms réels.** Chaque table et colonne existe dans
   `variables.tsv`, sur la bonne table (`SEJ_TYP` est dans `T_MCO{aa}B`, pas
   dans `C`) ; les tables PMSI portent l'année sur deux chiffres
   (`T_MCO23B`), jamais `aa` ; la clé du champ est la bonne (HAD/RIP :
   `ETA_NUM_EPMSI` + `RHAD_NUM`/`RIP_NUM`, pas `ETA_NUM`). Table hors
   dictionnaire : profil, sinon documentation officielle, en le signalant.
2. **Millésimes.** Chaque colonne est disponible pour chaque année de la
   requête (`debut`, `fin`, `absente`) ; ruptures connues : dates réelles de
   séjour absentes avant 2009, `EXT_PMSI` absent avant 2015, `FP_PEC` non
   codé après le 01/03/2023, `SOR_ANN`/`SOR_MOI` hors de `T_MCO{aa}C` après
   2018. Variable DCIR récente : millésime déclaré ≠ alimentation effective,
   proposer le `COUNT(*)` par année de `FLX_DIS_DTD`.
3. **Jointures et chaînage.** Clés déclarées de `jointures.tsv` ; tables de
   prestation DCIR jointes à `ER_PRS_F` sur les 9 colonnes techniques
   (exceptions `ER_DCT_F`, `ER_UCD_F`, `ER_LOT_F`, `ER_TRS_F` : profil) ;
   PMSI ↔ DCIR sur `NIR_ANO_17` = `BEN_NIR_PSA` ; patients uniques comptés
   sur `IR_BEN_R.BEN_IDT_ANO` (un comptage sur `BEN_NIR_PSA` + `BEN_RNG_GEM`
   ou sur `NIR_ANO_17` surestime : constat) ; causes de décès par
   `BEN_IDT_ANO`, perte d'appariement à quantifier. Détail : `modele-donnees.md`, « Chaînage
   patient ».
4. **Filtres qualité du profil.** PMSI : codes retour `*_RET = '0'` (selon
   millésime), NIR fictifs exclus, GHM/GME `90*` exclus, `SEJ_TYP <> 'B'`
   (MCO), doublons APHP/APHM/HCL seulement pour 2005-2017 ; DCIR : `DPN_QLF`
   et `PRS_DPN_QLP` hors 71/72 avec les `NULL` gérés explicitement,
   `ER_ETE_F.ETE_IND_TAA <> 1 OR IS NULL` ; population : `BEN_CDI_NIR = '00'`,
   `BEN_NAI_ANN` hors `1600`/`0001`, `BEN_SEX_COD <> 0` avant tout comptage.
   Filtre absent, sur la mauvaise table ou avec le mauvais seuil : constat.
   Détail : profil, « Défauts recommandés ».
5. **Pièges Oracle.** `col != valeur` exclut les `NULL` (écrire
   `col IS NULL OR col != valeur` ; en dbplyr `is.na(col) | col != valeur`) ;
   liste `IN` de plus de 1000 valeurs (ORA-01795 : `semi_join` lazy ou table
   temporaire) ; borne de date en chaîne (`DATE 'AAAA-MM-JJ'`, en dbplyr
   `!!ora_date(d)`) ; `TZ`/`ORA_SDTZ` posés avant `dbConnect()` ; `ORDER BY`
   sur colonne à `NULL` (tri après `collect()`) ; `REGEXP_LIKE` via `sql()`
   en dbplyr ; requête MySQL de la fiche filtres non traduite (`RIGHT()` →
   `SUBSTR(x, -n)`).
6. **Volumétrie.** `collect()` avant l'agrégation finale ; `ER_PRS_F` (et
   tables jointes) sur plus de quelques mois sans batch mensuel sur
   `FLX_DIS_DTD` des deux côtés de la jointure, ou sans marge de flux après la
   période clinique (au moins 6 flux, 12 pour une extraction exhaustive,
   jamais plus de 24, chaque batch refiltré sur `EXE_SOI_DTD`) ; table
   temporaire réutilisée sans statistiques (`analyze = TRUE`,
   `DBMS_STATS.GATHER_TABLE_STATS`) ; patients uniques pluriannuels sommés
   par année au lieu d'une union avant `n_distinct`. Pattern de référence :
   `template/06_sorties.R` (Pattern B) et `template/01_inclusion.R` (Pattern C).
7. **Sorties.** Cellules de 1 à 10 (seuil 11) dans un fichier écrit ou un
   résultat destiné à sortir de l'environnement, quelle que soit la
   finalité ; l'écran peut rester brut ; dans un script généré par
   `snds-query`, fichier écrit hors `exporter()` ; écriture locale d'un
   identifiant, d'une date ou d'une localisation individuelle ; année PMSI
   = année de sortie, à dire si la requête parle d'incidence ou d'entrée.

## Mode complétion

L'utilisateur décrit l'étape qu'il veut écrire (« la boucle par millésime
sur `T_MCO{aa}B` 2019-2023 », « la jointure `ER_PRS_F` → `ER_PHA_F` avec
les filtres qualité », « le batch sur `FLX_DIS_DTD` »). Rendre le fragment
seul, prêt à insérer, en R dbplyr par défaut ou en SQL Oracle si demandé ou
si la requête en cours est en SQL, puis une ligne par choix fait à sa place
(années, filtres appliqués, colonne retenue).

Le fragment reprend le pattern validé de `references/template/` quand il en existe un
(étapes par millésime, patients uniques par union, jointure DCIR sur
`DCIR_JOIN_KEY`, batch de flux), avec le nom réel des tables, les filtres
qualité du profil applicables à l'étape et les colonnes vérifiées dans le
dictionnaire. Le fragment est complet quand il passerait la grille de
relecture.

## Sans argument

Invoquée sans requête ni question, poser une seule question : « Collez la
requête à relire, ou posez votre question (table, variable, fragment à
écrire). » Puis traiter la réponse dans le mode qui correspond.

## Règles communes

- **Vérification** : chaque table, colonne et millésime nommés dans une
  réponse sont lus dans le dictionnaire ou le profil ; citer la source du
  dictionnaire utilisée (schema-snds frais ou copie embarquée datée).
- **Langage** : la réponse est dans le langage de l'entrée (SQL Oracle ou
  R dbplyr). SAS se lit (un script existant collé) et se traduit en R dbplyr
  sur demande ; la skill n'écrit jamais de SAS. Le style historique
  `glue()` + chaîne SQL brute se lit et se relit tel quel.
- **Confidentialité des sorties** : tout fichier écrit sur la plateforme
  est sous seuil (aucune cellule de 1 à 10, seuil 11), quelle que soit la
  finalité ; l'écran peut rester brut. Dans un script de la chaîne
  (`snds-query`), toute écriture passe par `exporter()`. Jamais d'écriture
  locale d'identifiants, de dates ou de localisations individuelles.
