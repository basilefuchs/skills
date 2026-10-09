# Système de tickets : GitHub

Les issues et les specs de ce dépôt sont des issues GitHub. Utiliser la CLI `gh` pour toutes les opérations.

## Conventions

- **Créer une issue** : `gh issue create --title "..." --body "..."`. Utiliser un heredoc pour un corps sur plusieurs lignes.
- **Lire une issue** : `gh issue view <numéro> --comments`, en filtrant les commentaires avec `jq` et en récupérant aussi les labels.
- **Lister les issues** : `gh issue list --state open --json number,title,body,labels,comments --jq '[.[] | {number, title, body, labels: [.labels[].name], comments: [.comments[].body]}]'`, avec les filtres `--label` et `--state` adaptés.
- **Commenter une issue** : `gh issue comment <numéro> --body "..."`
- **Ajouter / retirer des labels** : `gh issue edit <numéro> --add-label "..."` / `--remove-label "..."`
- **Fermer** : `gh issue close <numéro> --comment "..."`

Le dépôt se déduit de `git remote -v` ; `gh` le fait automatiquement dans un clone.

## Pull requests comme surface de triage

**PR comme surface de demande : non.** _(Passer à `oui` si ce dépôt traite les PR externes comme des demandes de fonctionnalité ; `/triage` lit cet indicateur.)_

Avec `oui`, les PR suivent les mêmes labels et états que les issues, avec les équivalents `gh pr` :

- **Lire une PR** : `gh pr view <numéro> --comments`, et `gh pr diff <numéro>` pour le diff.
- **Lister les PR externes à trier** : `gh pr list --state open --json number,title,body,labels,author,authorAssociation,comments`, puis ne garder que les `authorAssociation` `CONTRIBUTOR`, `FIRST_TIME_CONTRIBUTOR` ou `NONE` (écarter `OWNER`/`MEMBER`/`COLLABORATOR`).
- **Commenter / labelliser / fermer** : `gh pr comment`, `gh pr edit --add-label`/`--remove-label`, `gh pr close`.

Issues et PR partagent la même numérotation sur GitHub : un `#42` seul peut désigner l'une ou l'autre. Résoudre avec `gh pr view 42`, sinon `gh issue view 42`.

## Quand un skill dit « publier dans le système de tickets »

Créer une issue GitHub.

## Quand un skill dit « récupérer le ticket concerné »

Lancer `gh issue view <numéro> --comments`.

## Opérations de wayfinding

Utilisées par `/wayfinder`. La **carte** est une issue unique dont les **enfants** sont les tickets.

- **Carte** : une issue unique avec le label `wayfinder:map`, qui contient les sections Notes / Décisions prises / Zones floues. `gh issue create --label wayfinder:map`.
- **Ticket enfant** : une issue rattachée à la carte comme sous-issue GitHub (`gh api` sur l'endpoint des sous-issues). Si les sous-issues ne sont pas activées, ajouter l'enfant à une liste de tâches dans le corps de la carte et mettre `Part of #<carte>` en tête du corps de l'enfant. Labels : `wayfinder:<type>` (`research`/`prototype`/`grilling`/`task`). Une fois pris, le ticket est assigné au développeur qui le pilote.
- **Blocage** : les **dépendances d'issues natives** de GitHub, visibles dans l'interface. Ajouter un lien avec `gh api --method POST repos/<owner>/<repo>/issues/<enfant>/dependencies/blocked_by -F issue_id=<id-bloquant>`, où `<id-bloquant>` est l'**id de base de données** numérique du bloquant (`gh api repos/<owner>/<repo>/issues/<n> --jq .id`, _pas_ le `#numéro` ni le `node_id`). GitHub expose `issue_dependencies_summary.blocked_by` (bloquants ouverts uniquement). Si les dépendances ne sont pas disponibles, mettre une ligne `Blocked by: #<n>, #<n>` en tête du corps de l'enfant. Un ticket est débloqué quand tous ses bloquants sont fermés.
- **Requête de frontière** : lister les enfants ouverts de la carte (`gh issue list --state open`, limité aux sous-issues / à la liste de tâches de la carte), écarter ceux qui ont un bloquant ouvert (`issue_dependencies_summary.blocked_by > 0`, ou une issue ouverte dans la ligne `Blocked by`) ou un assigné ; le premier dans l'ordre de la carte l'emporte.
- **Prise** : `gh issue edit <n> --add-assignee @me`, première écriture de la session.
- **Résolution** : `gh issue comment <n> --body "<réponse>"`, puis `gh issue close <n>`, puis ajouter un pointeur (résumé + lien) dans la section Décisions prises de la carte.
