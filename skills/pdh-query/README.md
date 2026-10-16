# pdh-query — scripts R d'un protocole PMSI national

Skill pour [Claude Code](https://claude.com/claude-code), [claude.ai](https://claude.ai)
et les autres agents compatibles [Agent Skills](https://agentskills.io),
destinée aux statisticiens de DIM et chargés d'études qui travaillent sur la
**base nationale PMSI du portail ATIH** (Teradata). Troisième maillon du
parcours PMSI national du dépôt : elle lit le `protocole.md` validé par
`pdh-schema` et en génère les scripts R dbplyr/Teradata, un par étape du
protocole, à exécuter sur le portail. Elle ne clarifie rien et ne consulte
aucun dictionnaire : la question est cadrée par `question-recherche-pico`,
les champs, tables, variables et années sont vérifiés par `pdh-schema`.

```
/question-recherche-pico  →  /pdh-schema  →  /pdh-query  →  plateforme  →  /rapport-imrad
```

Parcours complet : voir le [README du dépôt](https://github.com/basilefuchs/skills#parcours).

## Contenu

- `SKILL.md` : la skill (démarche, contrat de `sorties/`, livrable, ligne de fin).
- `references/profils/portail_atih_<champ>.md` : profils MCO, SMR, HAD, PSY
  et RPU du portail ATIH (connexion, schéma annuel, colonnes, pièges,
  défauts recommandés), qui font foi sur l'environnement.
- `references/template/` : squelette du dossier de scripts, un fichier par
  étape, avec les patterns dbplyr/Teradata validés.
- `references/template.Rmd` : squelette du rapport R Markdown, mêmes étapes.

## Prérequis

- [Claude Code](https://claude.com/claude-code) (CLI ou application), **ou**
  un compte [claude.ai](https://claude.ai) avec la capacité Skills et
  l'exécution de code activée, **ou** un autre agent compatible Agent Skills.
  Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).
- Un `protocole.md` validé par
  [`pdh-schema`](https://github.com/basilefuchs/skills/tree/main/skills/pdh-schema).
- Un accès au portail ATIH pour exécuter les scripts ; la génération n'en a
  pas besoin.

## Usage

Se placer dans le répertoire de l'étude (un répertoire par étude :
`protocole.md`, les scripts et `sorties/` y vivent ensemble) :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou
  `.claude/skills/`) : `/pdh-query`, sans argument, ou suivi du chemin
  d'un `protocole.md` ;
- dans LibreChat : `$pdh-query` ;
- sur claude.ai : téléverser `protocole.md` et taper « générer les scripts
  du protocole ».

La skill retrouve le protocole seule : chemin passé en argument, sinon
`./protocole.md`, sinon fichier téléversé, sinon une question. Un protocole
non validé (`## Statut` en brouillon, ou sans `## Données`) est renvoyé vers
`/pdh-schema` ; une question en langage naturel sans protocole, vers
`/question-recherche-pico <question>`.

Elle ne pose qu'une question, le format : dossier `scripts/` de fichiers
`.R` (par défaut) ou rapport `analyse.Rmd`. Un fichier `analyse.R` unique
est fourni sur demande.

## Ce que la skill écrit

- Les scripts, à côté de `protocole.md` : `main.R`, `00_setup.R`,
  `01_inclusion.R`, `02_exclusion.R`, `03_critere_jugement.R`,
  `04_covariables.R`, `05_flowchart.R`, `06_sorties.R` dans `scripts/`, ou
  les mêmes étapes en chunks de `analyse.Rmd`. Champs, tables, variables,
  années, codes et version du dictionnaire sont recopiés du protocole. Une
  colonne que ni le protocole ni le squelette ne nomment porte le marqueur
  « À VÉRIFIER », signalé dans le message final.
- Dans `protocole.md` : `## Scripts` (format, fichiers, contrat de
  `sorties/`, date de génération) et `## Confidentialité`, rien d'autre.

## `sorties/`

À l'exécution, les scripts écrivent `sorties/` à côté de `protocole.md` :
`flowchart.csv`, `resultat_annuel.csv`, `nb_patients_periode.csv`, un
`strate_<variable>.csv` par stratification, les figures demandées et
`manifeste.md`. Tout fichier est sous secret statistique, quelle que soit la
finalité : un effectif de 1 à 10 est masqué (`NA`), avec les pourcentages et
taux de sa ligne. L'écran reste brut, pour contrôler le travail ;
`secret_statistique <- TRUE` dans `00_setup.R` l'aligne sur les fichiers.

Réserve : si la connexion Teradata renvoie les comptages en `integer64`, le
masquage d'`exporter()` est à vérifier sur le portail avant le premier
export.

## Après la génération

- **Exécuter** sur le portail ATIH, exporter `sorties/` par la procédure de
  la plateforme, le placer à côté de `protocole.md`, puis
  [`/rapport-imrad`](https://github.com/basilefuchs/skills/tree/main/skills/rapport-imrad).
- **Un critère à changer** : `/pdh-schema` amende le protocole, puis
  `/pdh-query` régénère les scripts en entier et liste les fichiers
  réécrits. Les corrections faites à la main dans les scripts ne sont pas
  mémorisées : la régénération les écrase.
- **Une erreur à l'exécution** : aucune skill ne corrige un script PMSI
  national ; le corriger à la main, sans toucher au protocole.

## Confidentialité

Claude ne voit jamais de données individuelles : il reçoit des agrégats sous
seuil, sortis par la procédure d'export de la plateforme, seule juge de ce
qui sort. Un téléversement sur claude.ai est un transfert à un tiers,
acceptable pour ces agrégats seulement. Pour générer les scripts, Claude ne
reçoit que `protocole.md`, qui ne contient aucun effectif.

## Autre environnement

Un autre environnement que le portail ATIH (base locale de DIM, export
parquet/DuckDB…) se traite avant de lancer la skill, en ajoutant un profil :
copier le profil du champ (`references/profils/portail_atih_<champ>.md`)
sous un autre nom dans `references/profils/`, adapter ses valeurs, puis
`/pdh-query <profil>`. Le squelette contient aussi des éléments propres à
Teradata (tables volatiles de session, `REGEXP_SIMILAR` via `sql()`) à
adapter pour un autre SGBD. Les profils font foi : y capitaliser les
mappings validés et les pièges découverts.

## Références communes

Les profils ont leur source ici ; `pdh-schema` en porte une copie. Modifier
la source, puis recopier (règle de copie du
[CONTRIBUTING](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md#références-communes-à-une-famille)).
Le dictionnaire des variables, le modèle de données et les points de
vigilance sont dans
[`pdh-schema`](https://github.com/basilefuchs/skills/tree/main/skills/pdh-schema),
qui décrit la mise à jour du dictionnaire.
