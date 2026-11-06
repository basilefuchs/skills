# snds-schema — données SNDS d'un protocole

Skill pour [Claude Code](https://claude.com/claude-code), [claude.ai](https://claude.ai)
et les autres agents compatibles [Agent Skills](https://agentskills.io),
destinée aux statisticiens de DIM et chargés d'études qui travaillent sur le
**SNDS via le Health Data Hub** (Oracle). Deuxième maillon du parcours SNDS
du dépôt : elle lit le `protocole.md` écrit par `to-protocole`, y identifie
les données à retenir (tables, variables et millésimes vérifiés dans le
dictionnaire, codes avec leur source, points de vigilance, incertitudes) et
écrit la section `# Données`, que `snds-query` lit pour générer les scripts.

```
/to-protocole  →  /snds-schema  →  /snds-query  →  plateforme
```

Parcours complet : voir le [README du dépôt](https://github.com/basilefuchs/skills#parcours).

## Contenu

- `SKILL.md` : la skill (démarche, livrable).
- `references/dictionnaire/` : dictionnaire du SNDS (tables, variables et
  millésimes, jointures, nomenclatures et leurs valeurs), généré depuis le
  dépôt open source
  [schema-snds](https://gitlab.com/healthdatahub/applications-du-hdh/schema-snds)
  du Health Data Hub (licence MPL-2.0, voir
  [NOTICE](https://github.com/basilefuchs/skills/blob/main/skills/snds-schema/NOTICE)).
- `scripts/build-dictionary.py` : construction du dictionnaire depuis schema-snds.
- `references/modele-donnees.md` : modèle de données (DCIR, PMSI, causes de
  décès, chaînage patient, pièges).
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
  [`to-protocole`](https://github.com/basilefuchs/skills/tree/main/skills/to-protocole),
  dont la source de données est le SNDS (Health Data Hub).
- Aucun accès au Health Data Hub n'est nécessaire : la skill ne lit que le
  protocole et le dictionnaire.

## Usage

Se placer dans le répertoire de l'étude (un répertoire par étude :
`protocole.md`, les scripts et les sorties y vivent ensemble) :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou
  `.claude/skills/`) : `/snds-schema`, sans argument, ou suivi de la
  demande (« élargis la position du diagnostic au DR ») ;
- dans LibreChat : `$snds-schema` ;
- sur claude.ai : téléverser `protocole.md` et taper « identifier les
  données SNDS du protocole ».

Le protocole est `protocole.md` du répertoire courant, ou le fichier fourni.

## Déroulé

Une réponse, sans question :

1. **Dictionnaire** : la copie embarquée, consultée par `grep` ; les
   définitions métier des tables et variables, pas seulement leurs noms.
2. **Vérification** : quand plusieurs variables semblent correspondre,
   granularité, rôle et millésimes sur chaque année de la période ; aucune
   table, variable ni définition absente du dictionnaire.
3. **Codes** : CIM-10, CCAM ou ATC avec leur source, ou donnés pour venir
   des connaissances de la skill.
4. **Vigilance** : les points de vigilance qui s'appliquent et toute
   incertitude que le protocole ne permet pas de trancher.
5. **Écriture** : `# Données` dans `protocole.md` ; sans accès au fichier
   (claude.ai), la section est livrée dans la réponse, à placer soi-même.

## Le fichier `protocole.md`

La skill lit le protocole écrit par `to-protocole` (`# Introduction`,
`# Matériels & Méthode`, `# Limites`) et écrit `# Données`, seule section à
elle : titre fixe, contenu libre (tables, variables, millésimes, codes à
retenir, points de vigilance, incertitudes), remplacée si elle existe. Elle
ne touche à rien d'autre. Le fichier ne contient jamais un effectif ni une
donnée individuelle : il se colle sur claude.ai sans relecture.

Conventions du parcours : voir le
[CONTRIBUTING du dépôt](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md).

## Dictionnaire

La copie embarquée est le dictionnaire : la skill la consulte telle quelle,
sans clone à chaque usage ; son commit et sa date sont dans
`references/dictionnaire/SOURCE.txt`. Elle est générée depuis le dépôt open
source
[schema-snds](https://gitlab.com/healthdatahub/applications-du-hdh/schema-snds)
du Health Data Hub (Table Schema JSON par table + nomenclatures), source qui
alimente aussi la [documentation officielle](https://documentation-snds.health-data-hub.fr/)
et le [dictionnaire interactif](https://health-data-hub.shinyapps.io/dico-snds/).

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
