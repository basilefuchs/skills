# Documentation du domaine

Comment les skills d'ingénierie doivent lire la documentation du domaine de ce dépôt avant de l'explorer.

## Avant d'explorer, lire

- **`CONTEXT.md`** à la racine du dépôt, ou
- **`CONTEXT-MAP.md`** à la racine s'il existe : il renvoie vers un `CONTEXT.md` par contexte. Lire chacun de ceux qui concernent le sujet.
- **`docs/adr/`** : lire les ADR qui touchent la zone sur laquelle on va travailler. Dans un dépôt multi-contextes, regarder aussi `src/<contexte>/docs/adr/` pour les décisions propres à un contexte.

Si ces fichiers n'existent pas, **continuer sans rien dire**. Ne pas signaler leur absence ni proposer de les créer d'avance. Le skill `/domain-modeling` (atteint via `/grill-with-docs` et `/improve-codebase-architecture`) les crée au fil de l'eau, quand des termes ou des décisions sont effectivement tranchés.

## Structure des fichiers

Dépôt à contexte unique (la plupart des dépôts, dont celui-ci) :

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

Dépôt multi-contextes (présence de `CONTEXT-MAP.md` à la racine) :

```
/
├── CONTEXT-MAP.md
├── docs/adr/                          ← décisions transverses
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/                  ← décisions propres au contexte
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

## Utiliser le vocabulaire du glossaire

Quand une production nomme un concept du domaine (titre d'issue, proposition de refactoring, hypothèse, nom de test), utiliser le terme tel que défini dans `CONTEXT.md`. Ne pas dériver vers des synonymes que le glossaire écarte explicitement.

Si le concept nécessaire n'est pas encore dans le glossaire, c'est un signal : soit on invente un vocabulaire que le projet n'utilise pas (à reconsidérer), soit il y a un vrai manque (à noter pour `/domain-modeling`).

## Signaler les conflits avec un ADR

Si une production contredit un ADR existant, le signaler explicitement plutôt que de passer outre en silence :

> _Contredit l'ADR-0007 (commandes event-sourcées), mais mérite d'être rouvert parce que…_
