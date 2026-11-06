# ght-dev

Skill qui développe un indicateur de pilotage hospitalier pour un GHT, donné par son nom ou par un candidat compressé issu de `ght-gen`, en fiche markdown complète : définition, calcul, utilité, sources de données, exemple de valeurs, limites, références. Chaque référence est vérifiée (DOI résolu, PMID confirmé, URL testée) avant d'entrer dans la fiche. Deuxième étape du [parcours indicateurs GHT du dépôt](https://github.com/basilefuchs/skills#parcours-indicateurs-ght).

## Contenu

- `SKILL.md` : la skill (recherche ciblée, vérification des références, format et règles qualité de la fiche, chemin d'écriture).
- `references/exemples/` : deux fiches de référence qui fixent le niveau attendu, `entropie_shannon_casemix.md` et `psi90_patient_safety_indicators.md`.

## Prérequis

Un accès shell pour `curl` (vérification des DOI et des URL). Un outil de recherche web ou PubMed, s'il est disponible, sert à la recherche préalable ; sans outil, la skill le dit et rédige sans aucune référence inventée.

## Usage

Se placer dans le répertoire de la base d'indicateurs et donner le nom de l'indicateur ou le candidat compressé :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou `.claude/skills/`) : `/ght-dev <nom>`, avec `--cat`, `--write`, `--no-web`, `--since`, `--depth` ;
- dans LibreChat : `$ght-dev <nom>` ;
- sur claude.ai : pas de commande, la skill se déclenche sur sa description et livre la fiche dans la réponse.

Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).

La fiche est écrite dans `indicateurs_pmsi/<NN>_<categorie>/<nom>.md` du répertoire courant, dans une catégorie existante ou, à défaut, dans l'une des dix catégories par défaut. Le dépôt [pilotage-ght](https://github.com/basilefuchs/pilotage-ght) est une base d'exemple de ce format, avec une page de recherche publiée.

## Déroulé

1. **Recherche** : méthode (PubMed), réglementaire et technique (ATIH, HAS, ScanSanté, DREES), anti-doublon, sauf `--no-web`.
2. **Vérification** : chaque DOI vient d'une API et résout sur `doi.org` ; chaque URL est testée ; une variable PMSI non confirmée est marquée `[à confirmer]`.
3. **Rédaction** : fiche en sept sections, montrée avec son chemin, puis écrite après confirmation (ou d'emblée avec `--write`).

Étape suivante, pour calculer l'indicateur sur une base nationale : `/to-protocole` avec la fiche comme idée d'étude, puis `/pdh-schema` et `/pdh-query` (portail ATIH) ou `/snds-schema` et `/snds-query` (Health Data Hub).
