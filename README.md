# Skills de Basile Fuchs

Skills pour le PMSI et la data science en santé, à installer dans
[Claude Code](https://claude.com/claude-code), sur [claude.ai](https://claude.ai)
ou dans tout agent compatible [Agent Skills](https://agentskills.io).

## Catalogue

| Skill | Ce qu'elle fait | Documentation |
| --- | --- | --- |
| `pdh-query` | Statisticien DIM virtuel : traduit une question PMSI (base nationale ATIH : MCO, SMR, HAD, PSY, RPU) en dossier de scripts R dbplyr/Teradata, un script par étape du protocole, après clarification du protocole. | [README](skills/pdh-query/README.md) |
| `pdh-schema` | Traduit en données PMSI (base nationale du portail ATIH) le `protocole.md` écrit par `question-recherche-pico` : champs, tables, variables et années vérifiés dans le dictionnaire, codes avec leur source, exclusions, points de vigilance, puis validation unique du protocole. | [README](skills/pdh-schema/README.md) |
| `question-recherche-pico` | Transforme une idée de recherche ou d'étude en santé en question structurée (finalité, source de données, type d'étude, grille PICO, mesure, sous-groupes, critères FINER), au fil d'un entretien, et l'écrit dans `protocole.md`. | [README](skills/question-recherche-pico/README.md) |
| `rapport-imrad` | Rédige le rapport IMRaD d'une étude SNDS ou PMSI depuis `protocole.md` et les agrégats de `sorties/` exportés de la plateforme : Méthodes et Résultats en prose, Introduction et Discussion en puces. | [README](skills/rapport-imrad/README.md) |
| `situation-clinique-mco` | Classe un CRH ou une lettre de liaison MCO dans sa situation clinique PMSI (guide méthodologique ATIH 2026) et argumente le DP et le DR. Avec Claude, CR fictifs uniquement. | [README](skills/situation-clinique-mco/README.md) |
| `snds-copilot` | Copilote d'une requête SNDS que l'utilisateur écrit lui-même (SQL Oracle, R dbplyr) sur le Health Data Hub : relecture d'une requête collée, table ou variable à trouver, fragment à écrire. | [README](skills/snds-copilot/README.md) |
| `snds-query` | Génère, depuis le `protocole.md` validé par `snds-schema`, le dossier de scripts R dbplyr/Oracle à exécuter sur le Health Data Hub, un script par étape, qui n'écrit que des agrégats sous seuil dans `sorties/`. | [README](skills/snds-query/README.md) |
| `snds-schema` | Traduit en données SNDS (Health Data Hub) le `protocole.md` écrit par `question-recherche-pico` : tables, variables et millésimes vérifiés dans le dictionnaire, codes avec leur source, exclusions, points de vigilance, puis validation unique du protocole. | [README](skills/snds-schema/README.md) |
| `squelette-imrad` | Produit le squelette IMRaD d'un protocole ou d'un article à partir d'une question de recherche structurée, avec la ligne directrice EQUATOR adaptée. | [README](skills/squelette-imrad/README.md) |

## Parcours

De la question de recherche au rapport, sur le SNDS (Health Data Hub) :
quatre skills se relaient par un fichier, `protocole.md`, et chacune termine
par la commande suivante. Les quatre sont à installer (voir
[Installation](#installation)).

```
/question-recherche-pico  →  /snds-schema  →  /snds-query
        →  plateforme (hors Claude) : exécution, export de sorties/  →  /rapport-imrad
```

Un répertoire = une étude : `protocole.md` à sa racine, les scripts et
`sorties/` à côté. Dans Claude Code, chaque commande se tape depuis ce
répertoire, sans argument : la skill retrouve `protocole.md` seule. Sur
claude.ai, pas de commande : téléverser les fichiers indiqués et taper la
phrase.

| Étape | Claude Code | claude.ai | Écrit |
| --- | --- | --- | --- |
| 1. Cadrer la question | `/question-recherche-pico <idée>` | décrire son idée d'étude | `protocole.md` : question, finalité, source de données, sous-groupes |
| 2. Traduire en données, valider le protocole | `/snds-schema` | téléverser `protocole.md`, taper « vérifier les données du protocole » | `protocole.md` : données, protocole validé, statut, modifications |
| 3. Générer les scripts | `/snds-query` | téléverser `protocole.md`, taper « générer les scripts du protocole » | `scripts/` (ou `analyse.Rmd`) ; `protocole.md` : scripts, confidentialité |
| 4. Exécuter sur la plateforme | hors Claude | hors Claude | `sorties/` : agrégats sous seuil et `manifeste.md` |
| 5. Rédiger le rapport | `/rapport-imrad` | téléverser `protocole.md` et les fichiers de `sorties/`, taper « rédiger le rapport IMRaD » | `rapport.md` |

Un dénombrement interne ou un rapport de gestion prend un chemin court, sans
critères FINER.

**Frontière de la plateforme.** L'utilisateur copie le répertoire de l'étude
sur le Health Data Hub et y exécute les scripts ; Claude n'y est jamais. Les
scripts n'écrivent que des agrégats sous seuil, dans `sorties/`, que
l'utilisateur sort par la procédure d'export de la plateforme et place à côté
de `protocole.md`.

**Confidentialité.** Claude ne voit jamais de données individuelles ; il
reçoit des agrégats sous seuil sortis par la procédure d'export de la
plateforme, seule juge de ce qui sort ; un téléversement sur claude.ai est un
transfert à un tiers, acceptable pour ces agrégats seulement. `protocole.md`
ne contient aucun effectif.

**Retours.** Un critère à changer : `/snds-schema` amende le protocole, puis
`/snds-query` régénère le dossier de scripts en entier. Une erreur à
l'exécution : `/snds-copilot`, avec le script et le message d'erreur, corrige
le fichier sans toucher au protocole. Une correction faite dans les scripts
n'est pas mémorisée : une régénération l'écrase.

**Hors parcours.** Sans base médico-administrative, `question-recherche-pico`
mène à `/squelette-imrad`. `snds-copilot` sert aussi seul, pour relire ou
écrire sa propre requête SNDS. `situation-clinique-mco` est indépendante.

**PMSI national (portail ATIH).** `/pdh-schema` traduit et valide le
protocole, comme `/snds-schema`. `/pdh-query` ne lit pas encore
`protocole.md` et ne prend donc pas la suite de `/pdh-schema` : d'ici là,
`/pdh-query <question>` va de la question aux scripts d'un bloc.

Désinstaller les plugins `snds-hdh` et `pdh-atih`, sur claude.ai comme dans
Claude Code : ce parcours les remplace.

## Installation

### Claude Code

Copier le dossier d'une skill depuis un clone du dépôt, dans `~/.claude/skills/`
(pour vous, dans tous vos projets) ou dans `.claude/skills/` d'un projet (à
committer) :

```
mkdir -p ~/.claude/skills && cp -r skills/pdh-query ~/.claude/skills/
```

Ou, sans cloner le dépôt, avec la CLI
[`skills`](https://github.com/vercel-labs/skills) (`-g` pour vous, dans tous
vos projets ; sans `-g`, dans le projet courant) :

```
npx skills add basilefuchs/skills --skill pdh-query -a claude-code -g
```

La skill s'invoque alors avec `/<nom>`, par exemple `/pdh-query <question>`.
Elle se déclenche aussi d'elle-même quand la question correspond à sa
description.

**Mettre à jour.** Une skill copiée ne reçoit pas les mises à jour du dépôt :
mettre à jour le clone, supprimer le dossier copié puis le recopier.

```
git pull && rm -rf ~/.claude/skills/pdh-query && cp -r skills/pdh-query ~/.claude/skills/
```

Installée avec la CLI `skills` : `npx skills update pdh-query`.

### claude.ai

1. Activer l'exécution de code dans les réglages de claude.ai : les skills
   consultent leurs fichiers de référence par des commandes shell.
2. Télécharger le zip de la skill depuis la
   [dernière release](https://github.com/basilefuchs/skills/releases/latest)
   (`<nom>.zip`).
3. Le téléverser tel quel dans **Customize → Skills**.

Il n'y a pas de commande d'invocation : la skill se déclenche d'elle-même sur
sa description.

### Autres agents (standard Agent Skills)

Avec la CLI [`skills`](https://github.com/vercel-labs/skills) :

```
npx skills add basilefuchs/skills --list
npx skills add basilefuchs/skills --skill snds-query
```

### LibreChat

LibreChat charge les skills de deux façons (voir la
[documentation de LibreChat](https://www.librechat.ai/docs/features/skills)) :

- **Skills de déploiement** : copier le dossier de la skill (par exemple
  `skills/situation-clinique-mco/`) dans le répertoire désigné par
  `DEPLOYMENT_SKILLS_DIR` (par défaut `./skill` à la racine de LibreChat),
  puis redémarrer LibreChat, à nouveau après chaque mise à jour du dossier.
- **Synchronisation GitHub** : déclarer le dépôt `basilefuchs/skills` dans la
  section `skillSync.github` de `librechat.yaml`, avec le chemin
  `skills/<nom>` de chaque skill voulue.

Dans la conversation, `$<nom>` invoque la skill (par exemple
`$situation-clinique-mco`) ; elle se déclenche aussi d'elle-même sur sa
description.

## Contribuer

Voir [CONTRIBUTING.md](CONTRIBUTING.md). Recette manuelle du parcours SNDS :
[docs/recette-parcours-snds.md](docs/recette-parcours-snds.md).

## Licence

Le code et le contenu propres au dépôt sont sous licence MIT,
© 2026 Basile Fuchs, CHU de Brest : voir [LICENSE](LICENSE).

Exception : le dictionnaire SNDS embarqué dans `snds-schema` et
`snds-copilot`, dérivé du dépôt schema-snds du Health Data Hub, est distribué
sous Mozilla Public License 2.0 : voir
[skills/snds-schema/NOTICE](skills/snds-schema/NOTICE) et
[skills/snds-copilot/NOTICE](skills/snds-copilot/NOTICE).
