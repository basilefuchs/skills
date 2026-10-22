# snds-query — scripts R d'un protocole SNDS

Skill pour [Claude Code](https://claude.com/claude-code), [claude.ai](https://claude.ai)
et les autres agents compatibles [Agent Skills](https://agentskills.io),
destinée aux statisticiens de DIM et chargés d'études qui travaillent sur le
**SNDS via le Health Data Hub** (Oracle). Troisième maillon du parcours SNDS
du dépôt : elle lit `protocole.md` et sa section `# Données`, écrite par
`snds-schema`, et en génère les scripts R dbplyr/Oracle, un par étape du
protocole, à exécuter sur la plateforme. Elle ne consulte aucun
dictionnaire : la question est cadrée par `to-protocole`, les tables,
variables et millésimes sont identifiés par `snds-schema`.

```
/to-protocole  →  /snds-schema  →  /snds-query  →  plateforme
```

Parcours complet : voir le [README du dépôt](https://github.com/basilefuchs/skills#parcours).

## Contenu

- `SKILL.md` : la skill.
- `references/profils/hdh_oracle.md` : profil de l'environnement Health Data
  Hub (connexion, colonnes, filtres qualité, pièges), qui fait foi sur
  l'environnement.
- `references/template/` : squelette du dossier de scripts, un fichier par
  étape, avec les patterns dbplyr/Oracle validés ; `00_setup.R` définit
  `exporter()`, seule voie d'écriture de fichier.
- `references/template.Rmd` : squelette du rapport R Markdown, mêmes étapes.

## Prérequis

- [Claude Code](https://claude.com/claude-code) (CLI ou application), **ou**
  un compte [claude.ai](https://claude.ai) avec la capacité Skills et
  l'exécution de code activée, **ou** un autre agent compatible Agent Skills.
  Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).
- Un `protocole.md` dont la section `# Données` est écrite par
  [`snds-schema`](https://github.com/basilefuchs/skills/tree/main/skills/snds-schema).
- Un accès au Health Data Hub pour exécuter les scripts ; la génération n'en
  a pas besoin.

## Usage

Se placer dans le répertoire de l'étude (un répertoire par étude :
`protocole.md`, les scripts et `sorties/` y vivent ensemble) :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou
  `.claude/skills/`) : `/snds-query`, sans argument, ou suivi de la demande ;
- dans LibreChat : `$snds-query` ;
- sur claude.ai : téléverser `protocole.md` et taper « générer les scripts
  du protocole ».

Le protocole est `protocole.md` du répertoire courant, ou le fichier fourni.
La skill répond sans question : un dossier `scripts/` de fichiers `.R` ; un
rapport `analyse.Rmd` en le demandant (`/snds-query génère un rapport
.Rmd`).

## Déroulé

1. **Squelette** : les scripts partent de `references/template/` (ou de
   `references/template.Rmd`), qui fait foi sur le code ; seul ce que le
   protocole fixe y change. Tables, variables, millésimes et codes sont
   recopiés de `# Données`, sans ajout.
2. **Profil** : `references/profils/hdh_oracle.md` fait foi sur
   l'environnement ; sa connexion est recopiée dans `00_setup.R`.
3. **À VÉRIFIER** : une colonne que ni le protocole, ni le squelette, ni le
   profil ne nomment porte le marqueur `# À VÉRIFIER` et est listée dans la
   réponse, jamais devinée.
4. **`exporter()`** : tout fichier s'écrit par cette fonction dans
   `sorties/` ; seuls des agrégats sous seuil sortent de la plateforme.
5. **Écriture** : les scripts sont écrits à côté de `protocole.md`,
   remplacés s'ils existent ; sans accès au répertoire (claude.ai), ils sont
   livrés dans la réponse et l'utilisateur les place lui-même.

## Le fichier `protocole.md`

La skill lit `protocole.md`, et d'abord `# Données` : ses tables, variables,
millésimes et codes font foi et sont recopiés sans ajout. Elle n'y écrit
rien : les scripts sont le livrable.

Conventions du parcours : voir le
[CONTRIBUTING du dépôt](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md).

## `sorties/`

À l'exécution, les scripts écrivent `sorties/` à côté de `protocole.md` :
`flowchart.csv`, `resultat_annuel.csv`, `nb_patients_periode.csv`, un
`strate_<variable>.csv` par stratification, `figure_resultat_annuel.png`
et `manifeste.md` (question, répertoire, date d'exécution, années, sources,
seuil, secret appliqué, dictionnaire, cellules masquées par fichier). Tout
fichier passe par `exporter()` et est sous secret statistique, quelle que
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
- **Un critère à changer** : `/snds-schema` réécrit `# Données`, puis
  `/snds-query` régénère les scripts en entier. Les corrections faites à
  la main dans les scripts ne sont pas mémorisées : la régénération les
  écrase.
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
`references/profils/`, adapter ses valeurs, puis le nommer dans la demande
(`/snds-query <profil>`). Le squelette contient aussi des éléments propres à
Oracle (`REGEXP_LIKE` via `sql()`, `ora_date()`, tables temporaires de
session, limite des listes `IN`) à adapter pour un autre SGBD. Au cadrage,
choisir la source « SNDS via le Health Data Hub », même pour une copie
locale au même format : `snds-schema` identifie les données dans le
dictionnaire du SNDS, et une source « autre » sort du parcours.

## Références communes

Le profil et le squelette de scripts ont leur source ici ; `snds-schema`
porte une copie du profil, `snds-copilot` une copie du profil et du
squelette. Modifier la source, puis recopier (règle de copie du
[CONTRIBUTING](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md#références-communes-à-une-famille)).
