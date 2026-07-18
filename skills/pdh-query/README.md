# pmsi-query — statisticien DIM virtuel pour Claude Code

Skill [Claude Code](https://claude.com/claude-code) destinée aux statisticiens de
DIM (et d'agences : ATIH, ARS…) travaillant sur la **base nationale PMSI du
portail ATIH** (Teradata). Elle traduit une question en langage naturel —
« combien de patients hospitalisés pour diabète entre 2020 et 2023 ? » — en un
script R dplyr/dbplyr prêt à exécuter sur le portail, **en passant par les mêmes
étapes qu'un statisticien** : clarification, protocole validé, puis script.

## Comment ça se passe concrètement

1. **Vous posez la question** en langage naturel, comme un clinicien la poserait.
2. **La skill fait préciser** ce qu'un DIM ferait préciser : codes CIM-10 exacts
   (avec une proposition à valider), position du diagnostic (DP seul / DP-DR /
   avec DAS), champ(s) PMSI, période, patients vs séjours vs journées,
   exclusions (séances, GHM en erreur, chaînage), stratification.
3. **Elle soumet un protocole** synthétique :
   > **Population** : séjours MCO 2020–2023, DP en E10–E14, France entière.
   > **Exclusions** : séances (CMD 28), GHM en erreur (90Z), chaînage en erreur.
   > **Critère de jugement** : patients uniques (clé `anonyme`), par année.
   > **Stratification** : année, sexe, classe d'âge.
4. **Après votre validation seulement**, elle génère le script `.R` : paramétré
   en tête, commenté, avec en-tête normalisé (question, protocole, « PROFIL DE
   BASE » listant schémas et variables utilisés) et une note méthodologique
   (limites, pistes de sensibilité).

Vous exécutez le script vous-même sur le portail : **Claude n'accède jamais aux
données** — il ne voit que la question, le protocole et le code généré. Le
dictionnaire des variables embarqué est le document de description de la base
(métadonnées), sans aucune donnée patient.

## Ce que la skill sait (et vérifie)

- Les conventions du portail : `pRatihque::connection_database()`, schémas
  `prd_vue_<champ>_AAAA`, tables référencées par `tbl(conn, I("schema.table"))`,
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

- [Claude Code](https://claude.com/claude-code) (CLI ou application).
- Un accès à la base nationale sur le portail ATIH (pour exécuter les scripts ;
  la génération elle-même n'en a pas besoin).
- Aucune compétence particulière en dbplyr : les scripts sont autoportants.

## Installation

### Option A — plugin (recommandé pour une équipe de DIM)

Publier ce dossier comme dépôt Git (GitHub/GitLab), puis dans Claude Code :

```
/plugin marketplace add <organisation>/<repo>
/plugin install pmsi-query@pmsi-marketplace
```

Les mises à jour (dictionnaire, profils, nouveaux patterns validés) se diffusent
ensuite à toute l'équipe via le dépôt.

### Option B — skill personnelle

Copier `skills/pmsi-query/` dans `~/.claude/skills/` :

```
cp -r skills/pmsi-query ~/.claude/skills/
```

La skill est alors disponible dans tous vos projets.

### Option C — skill de projet

Copier `skills/pmsi-query/` dans `.claude/skills/` du projet et committer :
toute personne qui clone le projet a la skill.

## Utilisation

Poser une question PMSI en langage naturel — la skill se déclenche d'elle-même —
ou l'invoquer explicitement : `/pmsi-query:pmsi-query <question>` si installée
en plugin (option A), `/pmsi-query <question>` en skill (options B et C).

Exemples de questions :

- « Combien de patients ont été hospitalisés pour AVC en 2023, par région ? »
- « Évolution des séjours de chirurgie bariatrique 2019–2024 dans mon département »
- « Taux de recours à l'HAD pour soins palliatifs, pour 100 000 habitants »

## Structure du dépôt

```
skills/pmsi-query/
├── SKILL.md                        # workflow : clarifier → protocole → script
└── references/
    ├── profils/                    # environnement portail ATIH (font foi)
    │   └── portail_atih_<champ>.md # MCO, SMR, HAD, PSY, RPU
    ├── dictionnaire/variables-*.csv # dictionnaire des variables de la base
    ├── modele-donnees.md           # tables, jointures, chaînage, pièges
    ├── clarifications.md           # checklist du statisticien
    └── template.R                  # squelette et patterns dbplyr/Teradata validés
```

## Adapter à un autre environnement que le portail ATIH

Toute la connaissance spécifique à l'environnement (connexion, schémas, mapping
colonne, défauts) vit dans `skills/pmsi-query/references/profils/`. Pour un
autre environnement (base locale de DIM, export parquet/DuckDB…), dupliquer un
profil, adapter les valeurs, et la skill l'utilisera — le reste ne change pas.
Les profils **font foi** : c'est aussi là que capitaliser vos mappings validés
et pièges découverts, pour que les scripts suivants en profitent.

## Mise à jour du dictionnaire

Remplacer `skills/pmsi-query/references/dictionnaire/variables-*.csv` par la
dernière version issue du portail ATIH (format : `librairie;table;var;libelle;
andeb;anfin;jointure;commentaire;type;longueur;droits`, encodage Windows-1252).
Un fichier `variables-*.csv` placé à la racine d'un projet prime sur celui
embarqué dans la skill.

## Licence

MIT — voir [LICENSE](LICENSE).
