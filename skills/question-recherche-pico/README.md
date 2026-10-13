# question-recherche-pico

Skill qui aide à transformer une idée de recherche en santé en question structurée : type d'étude, question en une phrase, grille de type PICO (P, I/E, C, O, T et schéma d'étude), fragilités FINER.

## Contenu

- `SKILL.md` : la skill (démarche, grille, format du livrable).

## Prérequis

Aucun : un seul fichier, sans script ni fichier de référence.

## Usage

Décrire son idée de recherche : la skill se déclenche d'elle-même sur sa description. On peut aussi l'invoquer explicitement :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou `.claude/skills/`) : `/question-recherche-pico` ;
- dans LibreChat : `$question-recherche-pico` ;
- sur claude.ai : pas de commande, la skill se déclenche sur sa description.

Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).

## Déroulé

1. **Idée** (après une question ouverte si elle n'a pas été décrite) : la skill restitue l'idée en une phrase et l'attente de la personne (thèse, article, projet à soumettre), « À préciser » si rien ne l'indique, et demande de valider avec les propositions « Valider » et « Corriger », jusqu'à validation explicite.
2. **Type d'étude** : intervention, observationnel, diagnostic ou pronostic, puis analytique ou descriptif pour un observationnel.
3. **Entretien** : une question par message, chacune avec 4 propositions tirées de l'idée et des réponses précédentes, et une réponse libre toujours possible. Les propositions s'affichent en options cliquables quand la plateforme le permet (bandeau de Claude, `AskUserQuestion` dans Claude Code), sinon en liste numérotée. Les questions remplissent la grille P, I/E, C, O, T et le schéma d'étude, puis passent en revue les critères FINER (faisable, intéressante, nouvelle, éthique, pertinente). La personne peut demander le livrable à tout moment.
4. **Validation** : le livrable est présenté avec les propositions « Valider » et « Corriger », puis renvoyé tel quel une fois validé.

Le livrable : le type d'étude, la question en une phrase, le tableau P / I/E / C / O / T / Schéma et les fragilités FINER. Il se copie tel quel pour la suite du projet. La skill structure, la personne rédige : le livrable ne contient ni texte rédigé, ni référence bibliographique.

## Périmètre

- Types d'étude : intervention, observationnel analytique, descriptif, diagnostic, pronostic.
- Hors champ, signalé comme tel : recherche qualitative, revues systématiques et méta-analyses, recherche hors santé.
- Non fait par la skill : recherche bibliographique, calcul du nombre de sujets, cadre réglementaire détaillé.
