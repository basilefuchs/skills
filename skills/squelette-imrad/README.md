# squelette-imrad

Skill qui produit, à partir d'une question de recherche en santé structurée (grille de type PICO), un squelette IMRaD : pour chaque section du futur article ou protocole (Introduction, Méthodes, Résultats, Discussion), ce qu'il faudra y mettre, avec la ligne directrice de reporting EQUATOR adaptée.

## Contenu

- `SKILL.md` : la skill (démarche, grille, repères, gabarit de réponse).

## Prérequis

Aucun : un seul fichier, sans script ni fichier de référence.

## Usage

Donner sa question de recherche structurée (type d'étude, question en une phrase, P, I/E, C, O, T, schéma d'étude) et demander le squelette : la skill se déclenche d'elle-même sur sa description. On peut aussi l'invoquer explicitement :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou `.claude/skills/`) : `/squelette-imrad` ;
- dans LibreChat : `$squelette-imrad` ;
- sur claude.ai : pas de commande, la skill se déclenche sur sa description.

Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).

## Déroulé

1. **Lecture de la question** : si l'entrée donne le type d'étude, chaque case utile de la grille et le schéma, la skill passe directement au squelette. Sinon, elle remplit la grille en un message à partir de ce qui est donné (« À préciser » sur les manques, type le plus probable signalé comme tel) et demande de valider, avec les propositions « Valider » et « Corriger », en options cliquables quand la plateforme le permet (bandeau de Claude, `AskUserQuestion` dans Claude Code), sinon en liste numérotée.
2. **Squelette IMRaD** à puces : la question et sa grille en tête, les fragilités FINER si l'entrée en contenait, puis Introduction, Méthodes, Résultats, Discussion, avec la ligne directrice de reporting EQUATOR adaptée au schéma (CONSORT, STROBE, RECORD, STARD, TRIPOD…). Les lignes que l'entrée ne couvre pas portent une piste signalée comme telle ; les choix qui reviennent à la personne sont listés « À préciser ».

La skill structure, la personne rédige : le squelette ne contient ni texte rédigé, ni chiffre de résultat, ni référence bibliographique.

## Périmètre

- Types d'étude : intervention, observationnel analytique, descriptif, diagnostic, pronostic.
- Hors champ, signalé comme tel : recherche qualitative, revues systématiques et méta-analyses, recherche hors santé.
- Non fait par la skill : recherche bibliographique, calcul du nombre de sujets (signalé comme à faire), cadre réglementaire détaillé.
