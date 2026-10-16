# snds-schema — traduction d'un protocole en données SNDS

Skill pour [Claude Code](https://claude.com/claude-code), [claude.ai](https://claude.ai)
et les autres agents compatibles [Agent Skills](https://agentskills.io),
destinée aux statisticiens de DIM et chargés d'études qui travaillent sur le
**SNDS via le Health Data Hub** (Oracle). Deuxième maillon du parcours SNDS
du dépôt : elle lit le `protocole.md` écrit par `question-recherche-pico`,
le traduit en données (sources, tables, variables et millésimes vérifiés
dans le dictionnaire, codes avec leur source, position du diagnostic,
exclusions, chaînage, points de vigilance), fait valider le protocole une
seule fois et passe la main à `snds-query`, qui génère les scripts.

```
/question-recherche-pico  →  /snds-schema  →  /snds-query  →  plateforme  →  /rapport-imrad
```

Parcours complet : voir le [README du dépôt](https://github.com/basilefuchs/skills#parcours).

## Contenu

- `SKILL.md` : la skill (démarche, format des questions, livrable, ligne de fin).
- `references/dictionnaire/` : dictionnaire du SNDS (tables, variables et
  millésimes, jointures, nomenclatures et leurs valeurs), généré depuis le
  dépôt open source
  [schema-snds](https://gitlab.com/healthdatahub/applications-du-hdh/schema-snds)
  du Health Data Hub (licence MPL-2.0, voir
  [NOTICE](https://github.com/basilefuchs/skills/blob/main/skills/snds-schema/NOTICE)).
- `scripts/build-dictionary.py` : construction du dictionnaire depuis schema-snds.
- `references/modele-donnees.md` : modèle de données (DCIR, PMSI, causes de
  décès, chaînage patient, pièges).
- `references/traduction.md` : les blocs de questions de traduction, avec
  leurs dépendances.
- `references/points-de-vigilance.md` : registres de risques méthodologiques.
- `references/profils/hdh_oracle.md` : profil de l'environnement Health Data
  Hub (colonnes, filtres qualité recommandés, pièges), qui fait foi sur
  l'environnement.

## Prérequis

- [Claude Code](https://claude.com/claude-code) (CLI ou application), **ou**
  un compte [claude.ai](https://claude.ai) avec la capacité Skills et
  l'exécution de code activée (la skill pèse environ 3 Mo décompressés,
  dictionnaire compris), **ou** un autre agent compatible Agent Skills.
  Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).
- Un `protocole.md` écrit par
  [`question-recherche-pico`](https://github.com/basilefuchs/skills/tree/main/skills/question-recherche-pico),
  dont la source de données est le SNDS (Health Data Hub).
- Aucun accès au Health Data Hub n'est nécessaire : la skill ne lit que le
  protocole et le dictionnaire.

## Usage

Se placer dans le répertoire de l'étude (un répertoire par étude :
`protocole.md`, les scripts et les sorties y vivent ensemble) :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou
  `.claude/skills/`) : `/snds-schema`, sans argument, ou suivi du chemin
  d'un `protocole.md` ;
- dans LibreChat : `$snds-schema` ;
- sur claude.ai : téléverser `protocole.md` et taper « vérifier les données
  du protocole ».

La skill retrouve le protocole seule : chemin passé en argument, sinon
`./protocole.md`, sinon fichier téléversé, sinon une question. Une question
en langage naturel sans protocole est renvoyée vers
`/question-recherche-pico <question>` ; un protocole dont la source est le
PMSI national (portail ATIH) est renvoyé vers `/pdh-schema`.

## Déroulé

1. **Lecture** : la skill restitue le protocole en une phrase (« Ok : … »)
   et repère ce qu'il laisse ouvert.
2. **Dictionnaire** : elle en tire une version fraîche depuis schema-snds si
   le réseau le permet, sinon utilise la copie embarquée, datée et signalée.
3. **Traduction** : proposition par défaut (sources, champ PMSI, codes avec
   leur source trouvée par recherche web quand elle existe, position du
   diagnostic, période, exclusions, chaînage), chaque table, variable et
   millésime vérifié dans le dictionnaire ; puis seulement ce qui reste
   ambigu, par lots de quatre questions au plus ordonnés par dépendances,
   « Tout par défaut » proposé au premier lot, « (Recommandé) » sur le
   défaut, « Ok : … » après chaque lot. Les propositions s'affichent en
   options cliquables quand la plateforme le permet, sinon en liste
   numérotée. Un point de vigilance est signalé dès qu'il apparaît.
4. **Synthèse et validation** : `## Données` et `## Protocole validé` sont
   présentés, avec un seul choix « Valider / Corriger ».
5. **Écriture** : les sections sont écrites dans `protocole.md`, et le
   message se termine par « Étape suivante : `/snds-query` ».

## Le fichier `protocole.md`

La skill lit `## Question`, `## Finalité` et `## Sous-groupes`, écrit
`## Données` (dictionnaire et commit, sources, période, tables, variables et
millésimes vérifiés, codes et leur source, position du diagnostic, unité de
compte traduite en colonnes, dénominateur, exclusions, chaînage, points de
vigilance), `## Protocole validé` (population, exclusions, critère de
jugement, stratification, sources et chaînage), `## Statut`
(`validé le AAAA-MM-JJ`) et `## Modifications`, et ne touche à rien d'autre.
Le fichier ne contient jamais un effectif ni une donnée individuelle : il se
colle sur claude.ai sans relecture.

**Amendement.** Relancer `/snds-schema` sur un protocole déjà validé ouvre
un amendement : la skill demande ce qui change, repasse `## Statut` à
`brouillon` pendant l'entretien, revalide, puis ajoute une ligne datée dans
`## Modifications`. Les scripts générés depuis l'ancienne version sont à
régénérer avec `/snds-query`.

Conventions du parcours : voir le
[CONTRIBUTING du dépôt](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md).

## Dictionnaire

Le dictionnaire est généré depuis le dépôt open source
[schema-snds](https://gitlab.com/healthdatahub/applications-du-hdh/schema-snds)
du Health Data Hub (Table Schema JSON par table + nomenclatures), source qui
alimente aussi la [documentation officielle](https://documentation-snds.health-data-hub.fr/)
et le [dictionnaire interactif](https://health-data-hub.shinyapps.io/dico-snds/).
À chaque usage, la skill en tire une version fraîche par clone partiel si le
réseau le permet ; la copie embarquée sert de secours hors ligne, et le
commit utilisé est inscrit dans `## Données`.

Mettre à jour la copie embarquée :

1. Cloner la source :
   ```
   git clone --depth 1 https://gitlab.com/healthdatahub/applications-du-hdh/schema-snds.git
   ```
2. Régénérer les fichiers (Python 3, bibliothèque standard), depuis le
   dossier de la skill :
   ```
   python3 scripts/build-dictionary.py /chemin/vers/schema-snds
   ```
   Produit `tables.tsv`, `variables.tsv`, `jointures.tsv`,
   `nomenclatures.tsv`, `valeurs.tsv` et `SOURCE.txt` (commit utilisé) dans
   `references/dictionnaire/`. Idempotent.
3. Recopier le dictionnaire dans les skills qui en portent une copie (voir
   ci-dessous), puis committer.

Le dictionnaire ne contient pas les valeurs CIM-10 ni CCAM : la skill
vérifie tables, variables, millésimes et jointures ; les listes de codes
viennent d'une recherche web ou de ses connaissances, source citée.

## Références communes

Une skill est distribuée seule : les références utiles à plusieurs skills
sont copiées, jamais partagées, et les copies restent identiques octet à
octet (règle de copie du
[CONTRIBUTING](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md#références-communes-à-une-famille)).

- Sources ici, copies dans `snds-copilot` : le dictionnaire
  (`references/dictionnaire/`), `scripts/build-dictionary.py` et
  `references/modele-donnees.md`.
- Copie ici, source dans `snds-query` : `references/profils/hdh_oracle.md`.

Les renvois de `modele-donnees.md` et de `points-de-vigilance.md` à
`template/` visent le squelette de scripts de `snds-query`.
