# Skills de Basile Fuchs

Skills pour le PMSI et la data science en santé, à installer dans
[Claude Code](https://claude.com/claude-code), sur [claude.ai](https://claude.ai)
ou dans tout agent compatible [Agent Skills](https://agentskills.io).

## Catalogue

| Skill | Ce qu'elle fait | Documentation |
| --- | --- | --- |
| `pdh-query` | Statisticien DIM virtuel : traduit une question PMSI (base nationale ATIH : MCO, SMR, HAD, PSY, RPU) en script R dbplyr/Teradata, après clarification du protocole. | [README](skills/pdh-query/README.md) |
| `snds-query` | Statisticien DIM virtuel : traduit une question SNDS (DCIR, PMSI, causes de décès) en script R dbplyr/Oracle pour le Health Data Hub, après clarification du protocole. | [README](skills/snds-query/README.md) |

## Installation

### Claude Code

Le dépôt est une marketplace Claude Code, `basilefuchs-skills`, qui propose un
plugin par skill : on installe seulement celles dont on a besoin.

```
/plugin marketplace add basilefuchs/skills
/plugin install pdh-query@basilefuchs-skills
/plugin install snds-query@basilefuchs-skills
```

Claude Code demande la portée de l'installation : **user** (vous, dans tous vos
projets), **project** (tous les collaborateurs du projet, via
`.claude/settings.json`) ou **local** (vous, dans ce projet). Fermer le menu
`/plugin` suffit à activer le plugin.

Équivalent en ligne de commande, pour scripter l'installation d'un poste :

```
claude plugin marketplace add basilefuchs/skills
claude plugin install pdh-query@basilefuchs-skills --scope user
```

Une skill installée par plugin s'invoque avec `/<skill>:<skill>`, par exemple
`/pdh-query:pdh-query <question>`. Elle se déclenche aussi d'elle-même quand la
question correspond à sa description.

**Mettre à jour.** Chaque commit sur `main` est une nouvelle version, sans
numéro à suivre :

```
/plugin marketplace update basilefuchs-skills
/reload-plugins
```

Pour des mises à jour automatiques : `/plugin` → onglet **Marketplaces** →
`basilefuchs-skills` → activer la mise à jour automatique (désactivée par
défaut pour les marketplaces tierces).

**Déployer pour toute une équipe.** Dans le dépôt de projet partagé par
l'équipe, ajouter à `.claude/settings.json` puis committer :

```json
{
  "extraKnownMarketplaces": {
    "basilefuchs-skills": {
      "source": { "source": "github", "repo": "basilefuchs/skills" }
    }
  },
  "enabledPlugins": {
    "pdh-query@basilefuchs-skills": true,
    "snds-query@basilefuchs-skills": true
  }
}
```

Chaque membre qui ouvre le projet dans Claude Code (et fait confiance au
dossier) se voit proposer la marketplace et les plugins.

**Sans marketplace.** Copier le dossier d'une skill depuis un clone du dépôt,
dans `~/.claude/skills/` (pour vous, dans tous vos projets) ou dans
`.claude/skills/` d'un projet (à committer) :

```
cp -r skills/pdh-query ~/.claude/skills/
```

La skill s'invoque alors avec `/pdh-query`. Elle ne reçoit pas les mises à jour
du dépôt : recopier le dossier pour la mettre à jour.

### claude.ai

1. Activer l'exécution de code dans les réglages de claude.ai : les skills
   consultent leurs fichiers de référence par des commandes shell.
2. Télécharger le zip de la skill depuis la
   [dernière release](https://github.com/basilefuchs/skills/releases/latest)
   (`pdh-query.zip`, `snds-query.zip`).
3. Le téléverser tel quel dans **Customize → Skills**.

Il n'y a pas de commande d'invocation : poser directement la question, la
skill se déclenche sur sa description. Faute d'outil de choix multiple, elle
pose ses questions de clarification à l'écrit : répondre en langage naturel.

### Autres agents (standard Agent Skills)

Avec la CLI [`skills`](https://github.com/vercel-labs/skills) :

```
npx skills add basilefuchs/skills --list
npx skills add basilefuchs/skills --skill snds-query
```

## Migration depuis pdh-atih-plugin et snds-hdh-plugin

Les dépôts `basilefuchs/pdh-atih-plugin` et `basilefuchs/snds-hdh-plugin` sont
remplacés par celui-ci. Les skills gardent leur nom (`pdh-query`,
`snds-query`) ; les plugins et les marketplaces changent.

**Claude Code, installation individuelle.** Retirer l'ancien plugin et son
ancienne marketplace, puis installer depuis la nouvelle :

```
/plugin uninstall pdh-atih@pdh-marketplace
/plugin marketplace remove pdh-marketplace
/plugin uninstall snds-hdh@snds-hdh-marketplace
/plugin marketplace remove snds-hdh-marketplace
/plugin marketplace add basilefuchs/skills
/plugin install pdh-query@basilefuchs-skills
/plugin install snds-query@basilefuchs-skills
```

**Claude Code, déploiement d'équipe.** Dans le `.claude/settings.json` du
projet, remplacer :

| Clé | Ancienne valeur | Nouvelle valeur |
| --- | --- | --- |
| `extraKnownMarketplaces` | `pdh-marketplace` (dépôt `basilefuchs/pdh-atih-plugin`) | `basilefuchs-skills` (dépôt `basilefuchs/skills`) |
| `extraKnownMarketplaces` | `snds-hdh-marketplace` (dépôt `basilefuchs/snds-hdh-plugin`) | `basilefuchs-skills` (dépôt `basilefuchs/skills`) |
| `enabledPlugins` | `pdh-atih@pdh-marketplace` | `pdh-query@basilefuchs-skills` |
| `enabledPlugins` | `snds-hdh@snds-hdh-marketplace` | `snds-query@basilefuchs-skills` |

**Invocations.** Les raccourcis des anciens plugins disparaissent :

| Avant | Maintenant |
| --- | --- |
| `/pdh-atih`, `/pdh-atih:pdh-atih`, `/pdh-atih:pdh-query` | `/pdh-query:pdh-query` |
| `/snds-hdh:snds-hdh`, `/snds-hdh:snds-query` | `/snds-query:snds-query` |

**Skill copiée ou claude.ai.** Remplacer le dossier copié, ou téléverser le
nouveau zip à la place de l'ancien.

## Contribuer

Voir [CONTRIBUTING.md](CONTRIBUTING.md).

## Licence

Le code et le contenu propres au dépôt sont sous licence MIT,
© 2026 Basile Fuchs, CHU de Brest : voir [LICENSE](LICENSE).

Exception : le dictionnaire SNDS embarqué dans `snds-query`, dérivé du dépôt
schema-snds du Health Data Hub, est distribué sous Mozilla Public License 2.0 :
voir [skills/snds-query/NOTICE](skills/snds-query/NOTICE).
