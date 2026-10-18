# snds-query — scripts R d'un protocole SNDS

Skill pour [Claude Code](https://claude.com/claude-code), [claude.ai](https://claude.ai)
et les autres agents compatibles [Agent Skills](https://agentskills.io),
destinée aux statisticiens de DIM et chargés d'études qui travaillent sur le
**SNDS via le Health Data Hub** (Oracle). Troisième maillon du parcours SNDS
du dépôt : elle lit le `protocole.md` validé par `snds-schema` et en génère
les scripts R dbplyr/Oracle, un par étape du protocole, à exécuter sur la
plateforme. Elle ne clarifie rien et ne consulte aucun dictionnaire : la
question est cadrée par `to-protocole`, les tables, variables et
millésimes sont vérifiés par `snds-schema`.

```
/to-protocole  →  /snds-schema  →  /snds-query  →  plateforme
```

Parcours complet : voir le [README du dépôt](https://github.com/basilefuchs/skills#parcours).

## Contenu

- `SKILL.md` : la skill (démarche, contrat de `sorties/`, livrable).
- `references/profils/hdh_oracle.md` : profil de l'environnement Health Data
  Hub (connexion, colonnes, filtres qualité, pièges), qui fait foi sur
  l'environnement.
- `references/template/` : squelette du dossier de scripts, un fichier par
  étape, avec les patterns dbplyr/Oracle validés.
- `references/template.Rmd` : squelette du rapport R Markdown, mêmes étapes.

## Prérequis

- [Claude Code](https://claude.com/claude-code) (CLI ou application), **ou**
  un compte [claude.ai](https://claude.ai) avec la capacité Skills et
  l'exécution de code activée, **ou** un autre agent compatible Agent Skills.
  Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).
- Un `protocole.md` validé par
  [`snds-schema`](https://github.com/basilefuchs/skills/tree/main/skills/snds-schema).
- Un accès au Health Data Hub pour exécuter les scripts ; la génération n'en
  a pas besoin.

## Usage

Se placer dans le répertoire de l'étude (un répertoire par étude :
`protocole.md`, les scripts et `sorties/` y vivent ensemble) :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou
  `.claude/skills/`) : `/snds-query`, sans argument, ou suivi du chemin
  d'un `protocole.md` ;
- dans LibreChat : `$snds-query` ;
- sur claude.ai : téléverser `protocole.md` et taper « générer les scripts
  du protocole ».

La skill retrouve le protocole seule : chemin passé en argument, sinon
`./protocole.md`, sinon fichier téléversé, sinon une question. Un protocole
du PMSI national (`### Source de données`) est renvoyé vers
`/pdh-query` ; un protocole non validé (`# Statut` en brouillon, ou sans
`# Données`), vers `/snds-schema` ; une question en langage naturel sans
protocole, vers `/to-protocole <question>`.

Elle ne pose qu'une question, le format : dossier `scripts/` de fichiers
`.R` (par défaut) ou rapport `analyse.Rmd`. Un fichier `analyse.R` unique
est fourni sur demande.

## Ce que la skill écrit

- Les scripts, à côté de `protocole.md` : `main.R`, `00_setup.R`,
  `01_inclusion.R`, `02_exclusion.R`, `03_critere_jugement.R`,
  `04_covariables.R`, `05_flowchart.R`, `06_sorties.R` dans `scripts/`, ou
  les mêmes étapes en chunks de `analyse.Rmd`. Tables, variables,
  millésimes, codes et commit du dictionnaire sont recopiés du protocole.
  Une colonne que ni le protocole ni le squelette ne nomment porte le
  marqueur « À VÉRIFIER », signalé dans le message final.
- Dans `protocole.md` : `# Scripts` (format, fichiers, contrat de
  `sorties/`, date de génération) et `# Confidentialité`, rien d'autre.

À l'exécution, les scripts écrivent `sorties/` à côté de `protocole.md` :
`flowchart.csv`, `resultat_annuel.csv`, `nb_patients_periode.csv`, un
`strate_<variable>.csv` par stratification, `figure_resultat_annuel.png`
et `manifeste.md`. Tout fichier est sous secret statistique, quelle que
soit la finalité : un effectif de 1 à 10 est masqué (`NA`), avec les
pourcentages et taux de sa ligne. Ce masque est primaire : une cellule
masquée peut se déduire par différence, toujours dans `flowchart.csv`, où
les exclus d'une étape sont l'écart de deux effectifs écrits ; la procédure
d'export de la plateforme reste seule juge de ce qui sort. L'écran reste
brut, pour contrôler le travail ; `secret_statistique <- TRUE` dans
`00_setup.R` l'aligne sur les fichiers. Le rapport HTML rendu depuis
`analyse.Rmd` est un fichier : `secret_statistique` y vaut `TRUE` par
défaut, tables identiques à `sorties/` ; à `FALSE`, il est brut, à lire sur
la plateforme et à ne jamais exporter.

## Après la génération

- **Exécuter** sur le Health Data Hub, exporter `sorties/` par la procédure
  de la plateforme.
- **Un critère à changer** : `/snds-schema` amende le protocole, puis
  `/snds-query` régénère les scripts en entier et liste les fichiers
  réécrits. Les corrections faites à la main dans les scripts ne sont pas
  mémorisées : la régénération les écrase.
- **Une erreur à l'exécution** :
  [`/snds-copilot`](https://github.com/basilefuchs/skills/tree/main/skills/snds-copilot),
  avec le script et le message d'erreur ; il corrige le script sans toucher
  au protocole.

## Confidentialité

Claude ne voit jamais de données individuelles : il reçoit des agrégats sous
seuil, sortis par la procédure d'export de la plateforme, seule juge de ce
qui sort. Un téléversement sur claude.ai est un transfert à un tiers,
acceptable pour ces agrégats seulement. Pour générer les scripts, Claude ne
reçoit que `protocole.md`, qui ne contient aucun effectif.

## Autre environnement

Un autre environnement que le Health Data Hub (base locale, export
parquet/DuckDB…) se traite avant de lancer la skill, en ajoutant un profil :
copier `references/profils/hdh_oracle.md` sous un autre nom dans
`references/profils/`, adapter ses valeurs, puis `/snds-query <profil>`. Le
squelette contient aussi des éléments propres à Oracle (`REGEXP_LIKE` via
`sql()`, `ora_date()`, tables temporaires de session, limite des listes
`IN`) à adapter pour un autre SGBD. Au cadrage, choisir la source « SNDS
via le Health Data Hub », même pour une copie locale au même format :
`snds-schema` vérifie le protocole dans le dictionnaire du SNDS, et une
source « autre » sort du parcours.

## Références communes

Le profil et le squelette de scripts ont leur source ici ; `snds-schema`
porte une copie du profil, `snds-copilot` une copie du profil et du
squelette. Modifier la source, puis recopier (règle de copie du
[CONTRIBUTING](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md#références-communes-à-une-famille)).
