# question-recherche-pico

Skill qui aide à transformer une idée de recherche ou d'étude en santé en question structurée : finalité et source de données, type d'étude, question en une phrase, grille de type PICO (P, I/E, C, O, T et schéma d'étude), sous-groupes, fragilités FINER. Elle écrit le résultat dans `protocole.md`, premier maillon du [parcours SNDS / PMSI du dépôt](https://github.com/basilefuchs/skills#parcours), et reste utilisable seule.

## Contenu

- `SKILL.md` : la skill (démarche, grille, format du livrable, ligne de fin).

## Prérequis

Aucun : un seul fichier, sans script ni fichier de référence.

## Usage

Se placer dans le répertoire de l'étude (un répertoire par étude : `protocole.md`, les scripts et les sorties y vivent ensemble) et décrire son idée : la skill se déclenche d'elle-même sur sa description. On peut aussi l'invoquer explicitement :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou `.claude/skills/`) : `/question-recherche-pico`, seul, suivi de l'idée, ou du chemin d'un `protocole.md` ;
- dans LibreChat : `$question-recherche-pico` ;
- sur claude.ai : pas de commande, la skill se déclenche sur sa description ; téléverser `protocole.md` pour reprendre une étude.

Un `protocole.md` déjà présent (chemin passé, `./protocole.md`, fichier téléversé) est proposé à reprendre, ou remplacé par une nouvelle étude.

Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).

## Déroulé

1. **Idée** (après une question ouverte si elle n'a pas été décrite) : la skill la restitue en une phrase (« Ok : … »).
2. **Finalité et source de données** : dénombrement interne, rapport ou dialogue de gestion, diffusion externe, publication ou thèse ; puis SNDS via le Health Data Hub, PMSI national via le portail ATIH, autre ou aucune. Dénombrement interne ou rapport de gestion : chemin court (type descriptif implicite, questions P, O, T et sous-groupes, pas de critères FINER). Diffusion ou publication : chemin complet.
3. **Type d'étude** (chemin complet) : intervention, observationnel, diagnostic ou pronostic, puis analytique ou descriptif pour un observationnel.
4. **Entretien** : une question par message, chacune avec 4 propositions tirées de l'idée et des réponses précédentes, « (Recommandé) » sur le défaut, et une réponse libre toujours possible. Les propositions s'affichent en options cliquables quand la plateforme le permet (bandeau de Claude, `AskUserQuestion` dans Claude Code), sinon en liste numérotée. Les questions remplissent la grille P, I/E, C, O, T et le schéma d'étude (P avec la base géographique, résidence ou établissement ; O avec l'unité de compte, patients, séjours, prestations ou décès, et le type d'indicateur, effectif, taux ou évolution), puis les sous-groupes (« aucun » est une réponse valable), puis, chemin complet, les critères FINER (faisable, intéressante, nouvelle, éthique, pertinente). La personne peut demander le livrable à tout moment.
5. **Validation** : le livrable est présenté avec les propositions « Valider » et « Corriger », puis, une fois validé, écrit dans `protocole.md` et renvoyé avec la ligne « Étape suivante ».

## Le fichier `protocole.md`

Un répertoire = une étude. La skill y écrit trois sections, à titres exacts, et ne touche à rien d'autre : `## Question` (type d'étude, question en une phrase, grille, schéma, fragilités FINER si posées), `## Finalité` (usage, destinataires, source de données) et `## Sous-groupes`. Le fichier ne contient jamais un effectif ni une donnée individuelle : il se colle sur claude.ai sans relecture. Le livrable reste affiché dans le message ; sur claude.ai, il tient lieu de fichier, à enregistrer sous `protocole.md`.

La ligne de fin nomme la commande suivante selon la source de données, et la phrase à taper sur claude.ai :

| Source de données | Étape suivante |
| --- | --- |
| SNDS (Health Data Hub) | `/snds-schema` — téléverser `protocole.md` et taper « vérifier les données du protocole » |
| PMSI national (portail ATIH) | `/pdh-schema` (skill à venir ; d'ici là, `/pdh-query <question>`) — téléverser `protocole.md` et taper « vérifier les données du protocole » |
| autre ou aucune | `/squelette-imrad` — coller le livrable et taper « squelette IMRaD d'un protocole ou d'un article » |

La skill structure, la personne rédige : le livrable ne contient ni texte rédigé, ni référence bibliographique.

Conventions du parcours : voir le [CONTRIBUTING du dépôt](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md).

## Périmètre

- Types d'étude : intervention, observationnel analytique, descriptif, diagnostic, pronostic.
- Hors champ, signalé comme tel : recherche qualitative, revues systématiques et méta-analyses, recherche hors santé.
- Non fait par la skill : recherche bibliographique, calcul du nombre de sujets, cadre réglementaire détaillé, traduction de la question en tables et variables.
