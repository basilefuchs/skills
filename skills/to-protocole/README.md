# to-protocole

Skill qui structure une idée de recherche ou d'étude en protocole selon la méthode IMRaD, au fil d'un entretien : objectifs, population, critères d'inclusion et d'exclusion, source et recueil de données, critères de jugement, analyses statistiques, limites. Elle fait valider une synthèse structurée, puis l'écrit dans `protocole.md`, premier maillon du [parcours SNDS / PMSI du dépôt](https://github.com/basilefuchs/skills#parcours), et reste utilisable seule.

## Contenu

- `SKILL.md` : la skill (éléments à recueillir, format de la synthèse).

## Prérequis

Aucun : un seul fichier, sans script ni fichier de référence.

## Usage

Se placer dans le répertoire de l'étude (un répertoire par étude : `protocole.md`, les scripts et les sorties y vivent ensemble) et décrire son idée : la skill se déclenche d'elle-même sur sa description. On peut aussi l'invoquer explicitement :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou `.claude/skills/`) : `/to-protocole`, seul ou suivi de l'idée ;
- dans LibreChat : `$to-protocole` ;
- sur claude.ai : pas de commande, la skill se déclenche sur sa description.

Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).

## Déroulé

1. **Entretien** : la skill interroge la personne jusqu'à obtenir les éléments du protocole.
2. **Validation** : elle présente une synthèse structurée (Introduction, Matériels & Méthode, Limites), critères, jugement, analyses et limites en tableaux.
3. **Écriture** : une fois validée, la synthèse est écrite dans `protocole.md`.

Étape suivante selon la source de données : `/snds-schema` (SNDS, Health Data Hub) ou `/pdh-schema` (PMSI national, portail ATIH).
