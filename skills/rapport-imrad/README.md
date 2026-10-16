# rapport-imrad — rapport IMRaD depuis le protocole et les agrégats

Skill pour [Claude Code](https://claude.com/claude-code), [claude.ai](https://claude.ai)
et les autres agents compatibles [Agent Skills](https://agentskills.io),
destinée aux statisticiens de DIM et chargés d'études. Dernier maillon du
parcours SNDS / PMSI du dépôt, commun aux deux bases : après l'exécution des
scripts sur la plateforme (Health Data Hub, portail ATIH) et l'export de
`sorties/`, elle lit `protocole.md` et les agrégats, et rédige le rapport
IMRaD : Méthodes et Résultats en prose, Introduction et Discussion en puces.

```
/question-recherche-pico  →  /snds-schema | /pdh-schema  →  /snds-query | /pdh-query
        →  plateforme (hors Claude) : exécution, export de sorties/  →  /rapport-imrad
```

## Contenu

- `SKILL.md` : la skill (entrées lues, démarche, gabarit du rapport).

## Prérequis

- [Claude Code](https://claude.com/claude-code) (CLI ou application), **ou**
  un compte [claude.ai](https://claude.ai) avec la capacité Skills, **ou** un
  autre agent compatible Agent Skills. Installation : voir le
  [README du dépôt](https://github.com/basilefuchs/skills).
- Un répertoire d'étude avec `protocole.md` validé par la skill schema
  ([`snds-schema`](https://github.com/basilefuchs/skills/tree/main/skills/snds-schema)
  ou `pdh-schema`) et `sorties/` écrit par les scripts de la skill query
  ([`snds-query`](https://github.com/basilefuchs/skills/tree/main/skills/snds-query)
  ou `pdh-query`), exporté de la plateforme à côté de `protocole.md`.
- Aucun accès à la plateforme : la skill ne lit que le protocole et les
  agrégats.

## Usage

Se placer dans le répertoire de l'étude (un répertoire par étude :
`protocole.md`, les scripts et `sorties/` y vivent ensemble) :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou
  `.claude/skills/`) : `/rapport-imrad`, sans argument, ou suivi du chemin
  du répertoire de l'étude ;
- dans LibreChat : `$rapport-imrad` ;
- sur claude.ai : téléverser `protocole.md` et les fichiers de `sorties/`
  ensemble, et taper « rédiger le rapport IMRaD ».

La skill retrouve ses entrées seule : chemin passé en argument, sinon
`./protocole.md` et `./sorties/`, sinon fichiers téléversés, sinon une
question. Quand tout est présent, le rapport sort sans question ; la cible
(rapport interne, rapport, article) découle de la finalité du protocole.

## Ce que la skill lit

- Dans `protocole.md` : `## Question`, `## Finalité`, `## Sous-groupes`
  (écrites par `question-recherche-pico`), `## Données`,
  `## Protocole validé`, `## Statut`, `## Modifications` (skill schema), et,
  si elles existent, `## Scripts` et `## Confidentialité` (skill query).
  Rien d'autre.
- Dans `sorties/` : `flowchart.csv`, `resultat_annuel.csv`,
  `nb_patients_periode.csv`, `strate_<variable>.csv`, les
  `figure_<nom>.png` et `manifeste.md`, aux en-têtes du contrat des scripts.
  Rien d'autre.

## Ce que la skill refuse

- **Lignes individuelles** (colonne d'identifiant, date au jour, une ligne
  par séjour sans colonne de comptage) : arrêt net, rien cité, aucun fichier
  écrit ; la skill demande de retirer le fichier et rappelle que seule la
  procédure d'export de la plateforme fait sortir des données.
- **Fichier hors contrat** (nom ou en-tête inattendu) : la skill demande de
  relancer les scripts, sans deviner.
- **Sortie console collée** dans le message : refusée, seuls les fichiers de
  `sorties/` sont lus.
- **Cellules de 1 à 10** dans un agrégat (export sans seuil) : rédigées
  « < 11 », leurs dérivées « masquée », avec un avertissement en tête du
  rapport.

## Le rapport

- Méthodes, en prose depuis le protocole : schéma, sources et chaînage,
  population, codes et leur source, unité de compte, exclusions,
  stratification, secret statistique, ligne directrice STROBE et RECORD
  (RECORD-PE quand l'exposition est un médicament du DCIR).
- Résultats, en prose depuis les agrégats : diagramme de flux depuis
  `flowchart.csv`, tableaux depuis les autres fichiers, « < 11 » pour toute
  cellule masquée, signalée sous le tableau et en tête du rapport.
- Introduction et Discussion en puces, avec **À préciser** là où la
  littérature ou le jugement de la personne manquent ; limites tirées des
  points de vigilance et de `## Modifications` du protocole.
- Aucune recherche bibliographique : seules les sources inscrites dans le
  protocole sont reprises. Aucune statistique absente des agrégats
  (intervalle de confiance, standardisation…) : elle est nommée comme
  absente.
- Livrable : `rapport.md` à côté de `protocole.md` dans Claude Code ; le
  rapport dans le message sur claude.ai.

## Confidentialité

Claude ne voit jamais de données individuelles : il reçoit des agrégats sous
seuil, sortis par la procédure d'export de la plateforme, seule juge de ce
qui sort. Un téléversement sur claude.ai est un transfert à un tiers,
acceptable pour ces agrégats seulement.

Conventions du parcours : voir le
[CONTRIBUTING du dépôt](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md).

## Périmètre

- Non fait par la skill : recherche bibliographique, calcul statistique
  au-delà des agrégats, Discussion rédigée en prose.
- Un squelette avant les données relève de
  [`squelette-imrad`](https://github.com/basilefuchs/skills/tree/main/skills/squelette-imrad).
