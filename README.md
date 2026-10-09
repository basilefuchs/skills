# Skills de Basile Fuchs

Skills pour le PMSI et la data science en santé, à installer dans
[Claude Code](https://claude.com/claude-code), sur [claude.ai](https://claude.ai)
ou dans tout agent compatible [Agent Skills](https://agentskills.io).

## Catalogue

| Skill | Ce qu'elle fait | Documentation |
| --- | --- | --- |
| `pdh-query` | Statisticien DIM virtuel : traduit une question PMSI (base nationale ATIH : MCO, SMR, HAD, PSY, RPU) en script R dbplyr/Teradata, après clarification du protocole. | [README](skills/pdh-query/README.md) |
| `snds-query` | Statisticien DIM virtuel : traduit une question SNDS (DCIR, PMSI, causes de décès) en script R dbplyr/Oracle pour le Health Data Hub, après clarification du protocole. | [README](skills/snds-query/README.md) |
| `situation-clinique-mco` | Classe un CRH ou une lettre de liaison MCO dans sa situation clinique PMSI (guide méthodologique ATIH 2026) et argumente le DP et le DR. Avec Claude, CR fictifs uniquement. | [README](skills/situation-clinique-mco/README.md) |

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

Voir [CONTRIBUTING.md](CONTRIBUTING.md).

## Licence

Le code et le contenu propres au dépôt sont sous licence MIT,
© 2026 Basile Fuchs, CHU de Brest : voir [LICENSE](LICENSE).

Exception : le dictionnaire SNDS embarqué dans `snds-query`, dérivé du dépôt
schema-snds du Health Data Hub, est distribué sous Mozilla Public License 2.0 :
voir [skills/snds-query/NOTICE](skills/snds-query/NOTICE).
