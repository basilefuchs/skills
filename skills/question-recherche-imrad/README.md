# question-recherche-imrad

Skill qui aide à transformer une idée de recherche en santé en question structurée (grille de type PICO), puis en squelette IMRaD : pour chaque section du futur article ou protocole (Introduction, Méthodes, Résultats, Discussion), ce qu'il faudra y mettre.

## Contenu

- `SKILL.md` : la skill (démarche, grille, repères, gabarit de réponse).

## Prérequis

Aucun : un seul fichier, sans script ni fichier de référence.

## Usage

Décrire son idée de recherche : la skill se déclenche d'elle-même sur sa description. On peut aussi l'invoquer explicitement :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou `.claude/skills/`) : `/question-recherche-imrad` ;
- dans LibreChat : `$question-recherche-imrad`.

Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).

## Déroulé

1. **Type d'étude** : intervention, observationnel analytique, descriptif, diagnostic ou pronostic.
2. **Entretien** : une question par message, chacune avec 5 propositions numérotées tirées de l'idée et des réponses précédentes, et une réponse libre toujours possible. Les questions remplissent la grille P, I/E, C, O, T et le schéma d'étude, puis passent en revue les critères FINER (faisable, intéressante, nouvelle, éthique, pertinente). La personne peut demander le livrable à tout moment.
3. **Validation** : la question est reformulée en une phrase avec sa grille, à valider ou à corriger.
4. **Squelette IMRaD** à puces, avec la ligne directrice de reporting EQUATOR adaptée au schéma (CONSORT, STROBE, RECORD, STARD, TRIPOD…), et la liste de ce qui reste à préciser.

La skill structure, la personne rédige : le squelette ne contient ni texte rédigé, ni chiffre de résultat, ni référence bibliographique.

## Périmètre

- Types d'étude : intervention, observationnel analytique, descriptif, diagnostic, pronostic.
- Hors champ, signalé comme tel : recherche qualitative, revues systématiques et méta-analyses, recherche hors santé.
- Non fait par la skill : recherche bibliographique, calcul du nombre de sujets (signalé comme à faire), cadre réglementaire détaillé.
