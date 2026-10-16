# pdh-query — statisticien DIM virtuel pour Claude

Skill pour [Claude Code](https://claude.com/claude-code), [claude.ai](https://claude.ai)
et les autres agents compatibles [Agent Skills](https://agentskills.io), destinée
aux statisticiens de DIM (et d'agences : ATIH, ARS…)
travaillant sur la **base nationale PMSI du portail ATIH** (Teradata). Elle
traduit une question en langage naturel — « combien de patients hospitalisés
pour diabète entre 2020 et 2023 ? » — en un dossier de scripts R dplyr/dbplyr prêt à
exécuter sur le portail, **en passant par les mêmes étapes qu'un
statisticien** : clarification, protocole validé, puis scripts.

## Comment ça se passe concrètement

1. **Vous posez la question** en langage naturel, comme un clinicien la poserait.
2. **La skill fait préciser** ce qu'un DIM ferait préciser, en commençant par la
   **finalité** (dénombrement interne, rapport, diffusion externe, publication —
   qui conditionne rigueur et format ; les fichiers écrits sont toujours sous
   secret statistique), puis : codes CIM-10
   exacts (proposés d'après les définitions publiées trouvées par recherche web —
   Santé publique France, cartographie CNAM… — sources citées, liste amendable),
   position du diagnostic (DP seul / DP-DR / avec DAS), champ(s) PMSI, période,
   patients vs séjours vs journées, exclusions (séances, GHM en erreur, chaînage),
   stratification.
3. **Elle soumet un protocole** synthétique, accompagné de ses **points de
   vigilance** (années Covid dans une tendance, petits effectifs, biais de
   définition…) :
   > **Population** : séjours MCO 2020–2023, DP en E10–E14, France entière.
   > **Exclusions** : séances (CMD 28), GHM en erreur (90Z), chaînage en erreur.
   > **Critère de jugement** : patients uniques (clé `anonyme`), par année.
   > **Stratification** : année, sexe, classe d'âge.
4. **Après votre validation seulement**, elle génère un **dossier de
   scripts** `.R`, un script par étape du protocole (`00_setup.R`,
   `01_inclusion.R`, `02_exclusion.R`, `03_critere_jugement.R`,
   `04_covariables.R`, `05_flowchart.R`, `06_sorties.R`) enchaînés par un
   `main.R` : paramétrés dans `00_setup.R`, commentés, avec en-tête normalisé
   (question, protocole, « PROFIL DE BASE » listant schémas et variables
   utilisés), chaque étape matérialisée dans une table de session Teradata
   que la suivante reprend, un **flowchart d'attrition** (effectifs et
   exclus à chaque étape), l'écriture des agrégats dans **`sorties/`** et une
   note méthodologique (limites, pistes de sensibilité) livrée dans le
   dossier. Un fichier `.R` unique est fourni sur demande, mêmes sections dans
   le même ordre ; un rapport `.Rmd` suit les mêmes étapes, un chunk par
   étape, avec la note méthodologique intégrée, et écrit le même `sorties/`.

Vous exécutez les scripts vous-même sur le portail. **Claude ne voit jamais de
données individuelles** : il reçoit des agrégats sous seuil, sortis par la
procédure d'export de la plateforme, seule juge de ce qui sort. Un
téléversement sur claude.ai est un transfert à un tiers, acceptable pour ces
agrégats seulement. Pour générer les scripts, il ne voit que la question, le
protocole et le code généré. Le dictionnaire des variables embarqué est le
document de description de la base (métadonnées), sans aucune donnée patient.

## Ce que les scripts écrivent : `sorties/`

À l'exécution, les scripts écrivent un dossier `sorties/` à côté du dossier
de scripts (ou du `.Rmd`), aux noms fixes :

| Fichier | Contenu |
| --- | --- |
| `flowchart.csv` | effectifs et exclus à chaque étape, par année (`annee`, `etape`, `nb_sejours`, `nb_exclus`) |
| `resultat_annuel.csv` | résultat par année |
| `nb_patients_periode.csv` | patients uniques sur toute la période |
| `strate_<variable>.csv` | une table par stratification (sexe, classe d'âge…), par année |
| `figure_<nom>.png` | figure, si demandée |
| `manifeste.md` | question, répertoire, date d'exécution, années, champs PMSI, seuil, secret appliqué, cellules masquées par fichier, fichiers écrits, version du dictionnaire, date de validation du protocole |

Tout fichier est sous secret statistique, quelle que soit la finalité : un
effectif de 1 à 10 est masqué (`NA`), avec les pourcentages et taux de sa
ligne. L'écran reste brut, pour contrôler le travail ;
`secret_statistique <- TRUE` dans `00_setup.R` l'aligne sur les fichiers. Ce
masque est une aide : la procédure d'export de la plateforme reste seule juge
de ce qui sort.

## Ce que la skill sait (et vérifie)

- Les conventions du portail : `pRatihque::connection_database()`, schémas
  `prd_vue_<champ>bl_AAAA`, tables référencées par `tbl(conn, I("schema.table"))`,
  calcul côté Teradata et `collect()` uniquement sur les agrégats.
- Le modèle de données des champs MCO, SMR, HAD, PSY (RPU partiellement) :
  grain des tables, clés de jointure, chaînage patient.
- Les pièges classiques du PMSI, signalés ou traités d'office : année PMSI =
  année de **sortie**, séances (CMD 28), GHM en erreur (90), qualité du chaînage
  (`ano_retour`), patients uniques pluriannuels par union avant `n_distinct`,
  FINESS juridique vs géographique, codes CIM-10 stockés sans point…
- L'existence et la disponibilité de **chaque variable utilisée**, vérifiées
  dans le dictionnaire (plage `andeb`/`anfin` couvrant les années demandées).

Les scripts générés restent **à relire avant exécution**, comme ceux d'un interne :
la skill fiabilise la traduction question → code, elle ne remplace pas la
validation métier ni le respect du secret statistique sur les sorties.

## Prérequis

- [Claude Code](https://claude.com/claude-code) (CLI ou application), **ou** un
  compte [claude.ai](https://claude.ai) avec la capacité Skills et l'exécution de
  code activée, **ou** un autre agent compatible Agent Skills. Installation :
  voir le [README du dépôt](https://github.com/basilefuchs/skills).
- Un accès à la base nationale sur le portail ATIH (pour exécuter les scripts ;
  la génération elle-même n'en a pas besoin).
- Aucune compétence particulière en dbplyr : les scripts sont autoportants.

## Utilisation

Poser une question PMSI en langage naturel — la skill se déclenche d'elle-même —
ou l'invoquer explicitement :

- copiée comme **skill** dans Claude Code (`~/.claude/skills/` ou
  `.claude/skills/`) : `/pdh-query <question>` ;
- sur **claude.ai** : pas de commande d'invocation, poser directement la
  question ; la skill se déclenche sur sa description. Faute d'outil de choix
  multiple, elle pose ses questions de clarification à l'écrit : répondre en
  langage naturel.

Exemples de questions :

- « Combien de patients ont été hospitalisés pour AVC en 2023, par région ? »
- « Évolution des séjours de chirurgie bariatrique 2019–2024 dans mon département »
- « Taux de recours à l'HAD pour soins palliatifs, pour 100 000 habitants »

## Adapter à un autre environnement que le portail ATIH

Toute la connaissance spécifique à l'environnement (connexion, schémas, mapping
colonne, défauts) vit dans `references/profils/`. Pour un
autre environnement (base locale de DIM, export parquet/DuckDB…), dupliquer un
profil, adapter les valeurs, et la skill l'utilisera — le reste ne change pas.
Les profils **font foi** : c'est aussi là que capitaliser vos mappings validés
et pièges découverts, pour que les scripts suivants en profitent.

## Références communes

Une skill est distribuée seule : les références utiles à plusieurs skills
sont copiées, jamais partagées, et les copies restent identiques octet à
octet (règle de copie du
[CONTRIBUTING](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md#références-communes-à-une-famille)).
Modifier la source, puis recopier.

- Copies ici, source dans
  [`pdh-schema`](https://github.com/basilefuchs/skills/tree/main/skills/pdh-schema),
  qui décrit la mise à jour du dictionnaire : le dictionnaire
  (`references/dictionnaire/`), `references/modele-donnees.md` et
  `references/points-de-vigilance.md`.
- Sources ici, copies dans `pdh-schema` : `references/profils/`.

Un fichier `variables-*.csv` placé à la racine d'un projet prime sur celui
embarqué dans la skill ; il peut rester dans l'encodage de l'export
(Windows-1252).
