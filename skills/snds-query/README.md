# snds-query — statisticien DIM virtuel pour Claude

Skill pour [Claude Code](https://claude.com/claude-code), [claude.ai](https://claude.ai)
et les autres agents compatibles [Agent Skills](https://agentskills.io), destinée
aux statisticiens de DIM travaillant sur le **SNDS via le
Health Data Hub** (Oracle). Elle traduit une question en langage naturel —
« combien de patients diabétiques hospitalisés entre 2020 et 2023 ? » — en un
script R dplyr/dbplyr prêt à exécuter sur l'environnement du Health Data Hub,
**en passant par les mêmes étapes qu'un statisticien** : clarification,
protocole validé, puis script.

## Comment ça se passe concrètement

1. **Vous posez la question** en langage naturel, comme un clinicien la poserait.
2. **La skill fait préciser** ce qu'un DIM ferait préciser, en commençant par la
   **finalité** (dénombrement interne, rapport, diffusion externe, publication —
   qui conditionne rigueur, seuils et secret statistique), puis : codes CIM-10
   exacts (proposés d'après les définitions publiées trouvées par recherche web —
   sources citées, liste amendable), source(s) mobilisée(s) (PMSI hospitalier,
   DCIR ambulatoire, causes de décès), position du diagnostic, période, patients
   vs séjours vs délivrances, exclusions (GHM en erreur, doublons, qualité de
   chaînage), stratification.
3. **Elle soumet un protocole** synthétique, accompagné de ses **points de
   vigilance** (chaînage inter-sources NIR_ANO_17/BEN_NIR_PSA/BEN_IDT_ANO,
   années Covid dans une tendance, petits effectifs...) :
   > **Population** : séjours MCO 2020–2023, DP en E10–E14, France entière.
   > **Exclusions** : GHM en erreur (CMD 90), doublons établissement, chaînage défaillant.
   > **Critère de jugement** : patients uniques (`NIR_ANO_17`), par année.
   > **Stratification** : année, sexe, classe d'âge.
4. **Après votre validation seulement**, elle génère le script `.R` : paramétré
   en tête, commenté, avec en-tête normalisé (question, protocole, « PROFIL DE
   BASE » listant tables et variables utilisées), un **flowchart d'attrition**
   (effectifs et % perdus à chaque étape d'exclusion), une vérification
   **secret statistique** (seuil de diffusion) et une note méthodologique
   (limites, pistes de sensibilité).

Vous exécutez le script vous-même sur l'environnement du Health Data Hub :
**Claude n'accède jamais aux données** — il ne voit que la question, le
protocole et le code généré. Le dictionnaire embarqué (généré depuis le
dépôt open source [schema-snds](https://gitlab.com/healthdatahub/applications-du-hdh/schema-snds)
du Health Data Hub, licence MPL-2.0 — voir [NOTICE](NOTICE)) décrit la base
(métadonnées), sans aucune donnée patient.

## Ce que la skill sait (et vérifie)

- Les conventions de l'environnement : `ROracle`/`dbConnect(dbDriver("Oracle"),
  dbname = "IPIAMPR2.WORLD")`, fuseau `Europe/Paris` (R et `ORA_SDTZ`), tables
  référencées par `tbl(conn, I("NOM_TABLE"))`, calcul côté Oracle et `collect()`
  uniquement sur les agrégats.
- Le modèle de données PMSI (tables suffixées par année de sortie) et DCIR
  (tables continues, filtrées par date/flux) : grain des tables, clés de
  jointure, chaînage patient.
- Les pièges classiques du SNDS, signalés ou traités d'office : **chaînage
  inter-sources** (PMSI `NIR_ANO_17` = DCIR `BEN_NIR_PSA`, individu et causes
  de décès via `IR_BEN_R.BEN_IDT_ANO`), qualité de chaînage PMSI
  (`NIR_RET`/`NAI_RET`/`SEX_RET`/`SEJ_RET`/`FHO_RET`/`PMS_RET`/`COH_SEX_RET`,
  NIR fictifs), doublons APHP/APHM/HCL (2005-2017 uniquement), GHM en erreur
  (CMD 90), filtres qualité DCIR (`DPN_QLF`+`PRS_DPN_QLP`, `ER_ETE_F`,
  `CPL_MAJ_TOP`), clé composite à 9 colonnes des tables DCIR, marge de flux
  DCIR, `ER_GEO_LOC_R` géolocalise le professionnel de santé
  (`NUM_PS` = `PFS_EXE_NUM`) et non le patient, ruptures de disponibilité
  (dates PMSI avant 2009, réforme SMR 2023), littéraux de date et limite des
  1000 valeurs d'une liste `IN` sous Oracle, patients uniques pluriannuels
  par union avant `n_distinct`.
- L'existence et la disponibilité de **chaque table et variable utilisées**,
  via le dictionnaire plat (`references/dictionnaire/*.tsv` : tables, variables et
  millésimes, jointures, nomenclatures et leurs valeurs), les tables
  de référence `IR_BEN_R` (filtres population) et `IR_IMB_R` (ALD), et les
  filtres PMSI HAD/RIP, validés au même titre que MCO/SSR.
- La documentation officielle en ligne du Health Data Hub, consultée en
  complément (via WebFetch) quand elle est disponible : elle **fait foi** sur
  les filtres recommandés et la méthodologie, y compris en cas de
  contradiction avec le reste de la skill. Le forum d'entraide et la
  cartographie de l'écosystème SNDS complètent ponctuellement (dépannage,
  définitions de cohortes déjà validées).

Le script généré reste **à relire avant exécution**, comme celui d'un interne :
la skill fiabilise la traduction question → code, elle ne remplace pas la
validation métier ni le respect du secret statistique sur les sorties.

## Prérequis

- [Claude Code](https://claude.com/claude-code) (CLI ou application), **ou** un
  compte [claude.ai](https://claude.ai) avec la capacité Skills et l'exécution de
  code activée (la skill pèse environ 3 Mo décompressés, dictionnaire compris),
  **ou** un autre agent compatible Agent Skills. Installation : voir le
  [README du dépôt](https://github.com/basilefuchs/skills).
- Un accès à l'environnement du Health Data Hub (pour exécuter les scripts ;
  la génération elle-même n'en a pas besoin).
- Aucune compétence particulière en dbplyr : les scripts sont autoportants.

## Utilisation

Poser une question SNDS en langage naturel — la skill se déclenche d'elle-même —
ou l'invoquer explicitement :

- installée en **plugin** Claude Code : `/snds-query:snds-query <question>` ;
- copiée comme **skill** dans Claude Code (`~/.claude/skills/` ou
  `.claude/skills/`) : `/snds-query <question>` ;
- sur **claude.ai** : pas de commande d'invocation, poser directement la
  question ; la skill se déclenche sur sa description. Faute d'outil de choix
  multiple, elle pose ses questions de clarification à l'écrit : répondre en
  langage naturel.

Exemples de questions :

- « Combien de patients diabétiques ont été hospitalisés en 2023, par région ? »
- « Évolution des délivrances d'antidépresseurs (DCIR) 2019–2024 dans mon département »
- « Taux de recours à l'HAD pour soins palliatifs, pour 100 000 habitants »

## Adapter à un autre environnement que le Health Data Hub

Toute la connaissance spécifique à l'environnement (connexion, tables,
mapping colonne, défauts) vit dans `references/profils/`.
Pour un autre environnement (base locale, export parquet/DuckDB…), dupliquer
`hdh_oracle.md`, adapter les valeurs, et la skill l'utilisera. Les templates
(`template.R`/`.Rmd`) contiennent aussi des éléments propres à Oracle
(`REGEXP_LIKE` via `sql()`, `ora_date()`, limite des listes `IN`) à adapter
pour un autre SGBD. Les profils **font foi** : c'est aussi là que capitaliser vos
mappings validés et pièges découverts, pour que les scripts suivants en
profitent.

## Mise à jour du dictionnaire

Le dictionnaire est généré depuis le dépôt open source
[schema-snds](https://gitlab.com/healthdatahub/applications-du-hdh/schema-snds)
du Health Data Hub (Table Schema JSON par table + nomenclatures), qui fait
foi pour la skill : à chaque génération, elle en tire une version fraîche par
clone partiel si le réseau le permet, la copie embarquée servant de secours
hors ligne. Cette source
alimente aussi la [documentation officielle](https://documentation-snds.health-data-hub.fr/)
et le [dictionnaire interactif](http://dico-snds.health-data-hub.fr/).

1. Cloner (ou mettre à jour) la source :
   ```
   git clone --depth 1 https://gitlab.com/healthdatahub/applications-du-hdh/schema-snds.git
   ```
2. Régénérer les fichiers de la skill (Python 3, bibliothèque standard), en
   passant le chemin du clone :
   ```
   python3 scripts/build-dictionary.py /chemin/vers/schema-snds   # depuis le dossier de la skill
   ```
   Produit `tables.tsv`, `variables.tsv`, `jointures.tsv`,
   `nomenclatures.tsv`, `valeurs.tsv` et `SOURCE.txt` (commit utilisé) dans
   `references/dictionnaire/`. Idempotent.
3. Committer et pousser : chaque commit sur `main` est une nouvelle version pour
   les installations en plugin Claude Code (marketplace), sans numéro de version
   à incrémenter.
