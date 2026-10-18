# pdh-schema — traduction d'un protocole en données PMSI national

Skill pour [Claude Code](https://claude.com/claude-code), [claude.ai](https://claude.ai)
et les autres agents compatibles [Agent Skills](https://agentskills.io),
destinée aux statisticiens de DIM et chargés d'études qui travaillent sur la
**base nationale PMSI du portail ATIH** (Teradata). Deuxième maillon du
parcours PMSI national du dépôt : elle lit le `protocole.md` écrit par
`to-protocole`, le traduit en données (champs PMSI, tables,
variables et années vérifiées dans le dictionnaire, codes avec leur source,
position du diagnostic, exclusions, chaînage, points de vigilance), fait
valider le protocole une seule fois et passe la main à `pdh-query`, qui
génère les scripts.

```
/to-protocole  →  /pdh-schema  →  /pdh-query  →  plateforme
```

Parcours complet : voir le [README du dépôt](https://github.com/basilefuchs/skills#parcours).

## Contenu

- `SKILL.md` : la skill (démarche, format des questions, livrable, ligne de fin).
- `references/dictionnaire/variables-<AAAA-MM-JJ>.csv` : dictionnaire des
  variables du portail ATIH (librairie, table, variable, libellé, années
  `andeb`/`anfin`, droits d'accès), métadonnées sans aucune donnée patient.
- `references/modele-donnees.md` : modèle de données (champs, tables clés et
  leur grain, chaînage patient, nomenclatures, pièges).
- `references/traduction.md` : les blocs de questions de traduction, avec
  leurs dépendances.
- `references/points-de-vigilance.md` : registres de risques méthodologiques.
- `references/profils/portail_atih_<champ>.md` : profils MCO, SMR, HAD, PSY
  et RPU du portail ATIH (schémas, colonnes, pièges, défauts recommandés),
  qui font foi sur l'environnement.

## Prérequis

- [Claude Code](https://claude.com/claude-code) (CLI ou application), **ou**
  un compte [claude.ai](https://claude.ai) avec la capacité Skills et
  l'exécution de code activée, **ou** un autre agent compatible Agent
  Skills. Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).
- Un `protocole.md` écrit par
  [`to-protocole`](https://github.com/basilefuchs/skills/tree/main/skills/to-protocole),
  dont la source de données est le PMSI national (portail ATIH).
- Aucun accès au portail ATIH n'est nécessaire : la skill ne lit que le
  protocole et le dictionnaire.

## Usage

Se placer dans le répertoire de l'étude (un répertoire par étude :
`protocole.md`, les scripts et les sorties y vivent ensemble) :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou
  `.claude/skills/`) : `/pdh-schema`, sans argument, ou suivi du chemin
  d'un `protocole.md` ;
- dans LibreChat : `$pdh-schema` ;
- sur claude.ai : téléverser `protocole.md` et taper « vérifier les données
  du protocole ».

La skill retrouve le protocole seule : chemin passé en argument, sinon
`./protocole.md`, sinon fichier téléversé, sinon une question. Une question
en langage naturel sans protocole est renvoyée vers
`/to-protocole <question>` ; un protocole dont la source est le
SNDS est renvoyé vers `/snds-schema`.

## Déroulé

1. **Lecture** : la skill restitue le protocole en une phrase (« Ok : … »)
   et repère ce qu'il laisse ouvert.
2. **Dictionnaire** : la copie embarquée, dont la date est inscrite dans
   `## Données`.
3. **Traduction** : proposition par défaut, chaque table, variable et année
   vérifiée dans le dictionnaire, codes avec leur source ; puis seulement ce
   qui reste ambigu, par lots de quatre questions au plus, « Tout par
   défaut » proposé au premier lot. Un point de vigilance est signalé dès
   qu'il apparaît.
4. **Synthèse et validation** : `## Données` et `## Protocole validé` sont
   présentés, avec un seul choix « Valider / Corriger ».
5. **Écriture** : les sections sont écrites dans `protocole.md`, et le
   message se termine par « Étape suivante : `/pdh-query` ».

## Le fichier `protocole.md`

La skill lit `## Question`, `## Finalité` et `## Sous-groupes`, écrit
`## Données`, `## Protocole validé`, `## Statut` (`validé le AAAA-MM-JJ`)
et `## Modifications`, et ne touche à rien d'autre. Le fichier ne contient
jamais un effectif ni une donnée individuelle : il se colle sur claude.ai
sans relecture.

**Amendement.** Relancer `/pdh-schema` sur un protocole déjà validé ouvre
un amendement : la skill reprend l'écart entre la question et le protocole
validé quand `to-protocole` a changé la question, sinon demande
ce qui change, repasse `## Statut` à `brouillon` pendant l'entretien,
revalide, puis ajoute une ligne datée dans `## Modifications`. Les scripts
générés depuis l'ancienne version sont à régénérer avec `/pdh-query`.

Conventions du parcours : voir le
[CONTRIBUTING du dépôt](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md).

## Dictionnaire

Le dictionnaire embarqué fait foi ; la date de son nom de fichier est la
version inscrite dans `## Données`. Il ne contient pas les valeurs CIM-10,
CCAM ni CSARR : la skill vérifie tables, variables et années ; les listes
de codes viennent d'une recherche web ou de ses connaissances, source citée.

Mettre à jour la copie embarquée :

1. Exporter le dictionnaire des variables depuis le portail ATIH (format :
   `librairie;table;var;libelle;andeb;anfin;jointure;commentaire;type;longueur;droits`).
2. Le convertir en UTF-8 (l'export natif est en Windows-1252), depuis le
   dossier de la skill, puis supprimer l'ancien fichier et committer :
   ```
   iconv -f WINDOWS-1252 -t UTF-8 nouvel-export.csv > references/dictionnaire/variables-AAAA-MM-JJ.csv
   ```

## Références communes

Une skill est distribuée seule : les références utiles à plusieurs skills
sont copiées, jamais partagées, et les copies restent identiques octet à
octet (règle de copie du
[CONTRIBUTING](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md#références-communes-à-une-famille)).

- Copies ici, source dans `pdh-query` : `references/profils/`.
- Le dictionnaire, le modèle de données, les blocs de traduction et les
  points de vigilance ne sont qu'ici : `pdh-query` lit leur résultat dans
  `## Données`.
