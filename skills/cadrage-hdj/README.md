# cadrage-hdj

Skill qui instruit, avec le praticien porteur, un projet d'hôpital de jour (HDJ) MCO au CHU : description des parcours et de la venue type, verdict d'éligibilité au GHS selon la gradation des prises en charge sans nuitée (instruction DGOS/R1/DSS/1A/2020/52 du 10 septembre 2020), organisation, puis une fiche de cadrage Word par parcours.

## Contenu

- `SKILL.md` : la démarche en sept étapes, de la saisie libre au récapitulatif.
- `references/regles.md` : règles de gradation (ordre d'évaluation, décompte des interventions, `SP`, `CP`, `RH`, douleur, repli).
- `references/fiche.md` : champs du JSON qui remplit la fiche.
- `scripts/actes.py` : caractéristiques CCAM d'une venue (classant, activité 4, FFM, SE) et décompte CCAM.
- `scripts/contextes.py` : codes CIM-10 du polyhandicap lourd.
- `scripts/fiche.py` : remplit `assets/fiche.dotx` et écrit `sorties/Cadrage_HJ_<projet>_<parcours>.docx`.
- `assets/` : référentiel CCAM (`actes.csv`), liste polyhandicap (`contextes.csv`), gabarit Word (`fiche.dotx`).

## Prérequis

Python 3, bibliothèque standard seule. Sur claude.ai, activer l'exécution de code.

## Usage

- Copiée comme skill dans Claude Code : `/cadrage-hdj`, depuis le répertoire où écrire `sorties/`.
- Sur claude.ai : décrire son projet d'HDJ, la skill se déclenche sur sa description.

Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).

Le verdict, le DP, les DAS et la gradation proposés sont « à valider DIM » : la décision reste au médecin DIM.

## Référentiel

Socle figé à l'instruction du 10 septembre 2020, annexes 2 et 4. À chaque nouvelle instruction ou version de la CCAM : mettre à jour `references/regles.md` et `assets/actes.csv`.
