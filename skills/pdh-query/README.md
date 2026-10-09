# pdh-query — statisticien DIM virtuel pour Claude

Skill pour [Claude Code](https://claude.com/claude-code), [claude.ai](https://claude.ai)
et les autres agents compatibles [Agent Skills](https://agentskills.io), destinée
aux statisticiens de DIM (et d'agences : ATIH, ARS…)
travaillant sur la **base nationale PMSI du portail ATIH** (Teradata). Elle
traduit une question en langage naturel — « combien de patients hospitalisés
pour diabète entre 2020 et 2023 ? » — en un script R dplyr/dbplyr prêt à
exécuter sur le portail, **en passant par les mêmes étapes qu'un
statisticien** : clarification, protocole validé, puis script.

## Comment ça se passe concrètement

1. **Vous posez la question** en langage naturel, comme un clinicien la poserait.
2. **La skill fait préciser** ce qu'un DIM ferait préciser, en commençant par la
   **finalité** (dénombrement interne, rapport, diffusion externe, publication —
   qui conditionne rigueur, seuils et secret statistique), puis : codes CIM-10
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
4. **Après votre validation seulement**, elle génère le script `.R` : paramétré
   en tête, commenté, avec en-tête normalisé (question, protocole, « PROFIL DE
   BASE » listant schémas et variables utilisés), un **flowchart d'attrition**
   (effectifs et % perdus à chaque étape d'exclusion) et une note méthodologique
   (limites, pistes de sensibilité).

Vous exécutez le script vous-même sur le portail : **Claude n'accède jamais aux
données** — il ne voit que la question, le protocole et le code généré. Le
dictionnaire des variables embarqué est le document de description de la base
(métadonnées), sans aucune donnée patient.

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

Le script généré reste **à relire avant exécution**, comme celui d'un interne :
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

## Mise à jour du dictionnaire

Remplacer `references/dictionnaire/variables-*.csv` par la
dernière version issue du portail ATIH (format : `librairie;table;var;libelle;
andeb;anfin;jointure;commentaire;type;longueur;droits`). L'export natif du
portail est en **Windows-1252** ; le fichier embarqué dans la skill doit rester
en **UTF-8** (fichier unique, utilisé quel que soit le mode d'installation) —
convertir avant de remplacer, par exemple depuis le dossier de la skill :

```
iconv -f WINDOWS-1252 -t UTF-8 nouvel-export.csv > references/dictionnaire/variables-AAAA-MM-JJ.csv
```

Un fichier `variables-*.csv` placé à la racine d'un projet prime sur celui
embarqué dans la skill (celui-là peut rester dans l'encodage de l'export).
