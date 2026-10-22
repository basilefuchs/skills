# pdh-schema — données PMSI national d'un protocole

Skill pour [Claude Code](https://claude.com/claude-code), [claude.ai](https://claude.ai)
et les autres agents compatibles [Agent Skills](https://agentskills.io),
destinée aux statisticiens de DIM et chargés d'études qui travaillent sur la
**base nationale PMSI du portail ATIH** (Teradata). Deuxième maillon du
parcours PMSI national du dépôt : elle lit le `protocole.md` écrit par
`to-protocole`, y identifie les données à retenir (champs PMSI, tables,
variables et années vérifiées dans le dictionnaire, codes avec leur source,
points de vigilance, incertitudes) et écrit la section `# Données`, que
`pdh-query` lit pour générer les scripts.

```
/to-protocole  →  /pdh-schema  →  /pdh-query  →  plateforme
```

Parcours complet : voir le [README du dépôt](https://github.com/basilefuchs/skills#parcours).

## Contenu

- `SKILL.md` : la skill (démarche, livrable).
- `references/dictionnaire/variables.csv` : dictionnaire des variables du
  portail ATIH (librairie, table, variable, libellé, années `andeb`/`anfin`,
  droits d'accès), métadonnées sans aucune donnée patient ; date de l'export
  dans `SOURCE.txt`, colonnes et enregistrements multilignes décrits dans
  `README.md`.
- `references/modele-donnees.md` : modèle de données (champs, tables clés et
  leur grain, chaînage patient, nomenclatures, pièges).
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
  `.claude/skills/`) : `/pdh-schema`, sans argument, ou suivi de la demande
  (« élargis la position du diagnostic au DR ») ;
- dans LibreChat : `$pdh-schema` ;
- sur claude.ai : téléverser `protocole.md` et taper « identifier les
  données PMSI du protocole ».

Le protocole est `protocole.md` du répertoire courant, ou le fichier fourni.

## Déroulé

Une réponse, sans question :

1. **Dictionnaire** : `variables.csv`, consulté par `grep` ; les
   définitions métier des tables et variables, pas seulement leurs noms.
2. **Vérification** : quand plusieurs variables semblent correspondre,
   granularité, rôle et présence (`andeb`, `anfin`) sur chaque année de la
   période ; aucune table, variable ni définition absente du dictionnaire.
3. **Codes** : CIM-10, CCAM ou CSARR avec leur source, ou donnés pour venir
   des connaissances de la skill.
4. **Vigilance** : les points de vigilance qui s'appliquent et toute
   incertitude que le protocole ne permet pas de trancher.
5. **Écriture** : `# Données` dans `protocole.md` ; sans accès au fichier
   (claude.ai), la section est livrée dans la réponse, à placer soi-même.

## Le fichier `protocole.md`

La skill lit le protocole écrit par `to-protocole` (`# Introduction`,
`# Matériels & Méthode`, `# Limites`) et écrit `# Données`, seule section à
elle : titre fixe, contenu libre (champs, tables, variables, années, codes à
retenir, points de vigilance, incertitudes), remplacée si elle existe. Elle
ne touche à rien d'autre. Le fichier ne contient jamais un effectif ni une
donnée individuelle : il se colle sur claude.ai sans relecture.

Conventions du parcours : voir le
[CONTRIBUTING du dépôt](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md).

## Dictionnaire

`references/dictionnaire/variables.csv` fait foi ; la date de l'export est
dans `SOURCE.txt`. Il ne contient pas les valeurs CIM-10, CCAM ni CSARR :
la skill vérifie tables, variables et années ; les listes de codes viennent
d'une recherche web ou de ses connaissances, source citée.

Mettre à jour la copie embarquée :

1. Exporter le dictionnaire des variables depuis le portail ATIH (format :
   `librairie;table;var;libelle;andeb;anfin;jointure;commentaire;type;longueur;droits`).
2. Le convertir en UTF-8 (l'export natif est en Windows-1252), depuis le
   dossier de la skill, mettre la date dans `SOURCE.txt`, puis committer :
   ```
   iconv -f WINDOWS-1252 -t UTF-8 export.csv > references/dictionnaire/variables.csv
   ```

## Références communes

Une skill est distribuée seule : les références utiles à plusieurs skills
sont copiées, jamais partagées, et les copies restent identiques octet à
octet (règle de copie du
[CONTRIBUTING](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md#références-communes-à-une-famille)).

- Copies ici, source dans `pdh-query` : `references/profils/`.
- Le dictionnaire, le modèle de données et les points de vigilance ne sont
  qu'ici : `pdh-query` lit leur résultat dans `# Données`.
