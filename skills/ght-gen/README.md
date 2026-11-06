# ght-gen

Skill qui génère des candidats d'indicateurs de pilotage hospitalier pour un GHT, calculables depuis le PMSI (MCO, SMR, HAD, psychiatrie) ou le SNDS, en format compressé `[i,d,c,u,l,t,s]` : une ligne par candidat, pour explorer un domaine et en sélectionner avant de développer une fiche complète avec `ght-dev`. Première étape du [parcours indicateurs GHT du dépôt](https://github.com/basilefuchs/skills#parcours-indicateurs-ght).

## Contenu

- `SKILL.md` : la skill (options, veille, format de sortie, règles de génération).

## Prérequis

Aucun fichier. Un outil de recherche web ou PubMed, s'il est disponible, sert à la veille préalable ; sans outil, la skill le dit et génère depuis les connaissances du modèle, sans citer de source.

## Usage

Donner un domaine (`parcours`, `efficience`, `territoire`…), éventuellement précédé d'une transformation (`entropy casemix`) :

- copiée comme skill dans Claude Code (`~/.claude/skills/` ou `.claude/skills/`) : `/ght-gen <domaine>`, avec `--n`, `--lvl`, `--excl`, `--no-web`, `--since` ;
- dans LibreChat : `$ght-gen <domaine>` ;
- sur claude.ai : pas de commande, la skill se déclenche sur sa description.

Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).

Lancée depuis un répertoire qui contient `indicateurs_pmsi/`, l'option `--excl` écarte les candidats qui reformulent une fiche existante. Le dépôt [pilotage-ght](https://github.com/basilefuchs/pilotage-ght) en est un exemple.

## Déroulé

1. **Veille** : 3 à 8 puces datées et sourcées sur le domaine (ATIH, HAS, DREES, IRDES, ScanSanté, PubMed), sauf `--no-web`.
2. **Candidats** : liste numérotée, un candidat par ligne, `s:interne` quand aucune source n'a été vérifiée.
3. **Sélection** : l'utilisateur retient un ou plusieurs numéros. Rien n'est écrit sur disque.

Étape suivante : `/ght-dev <nom_indicateur>` pour la fiche complète.
