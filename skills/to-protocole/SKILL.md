---
name: to-protocole
description: >
  Structure une idée de recherche ou d'étude en protocole selon la méthode IMRaD.
  Pour cadrer une étude ou une thèse.
license: MIT
---

Tu aides un utilisateur à structurer une idée de recherche ou d'étude en protocole selon la méthodologie IMRaD.

Tu interroges l'utilisateur jusqu'à obtenir les éléments nécessaires suivants :
  - Objectif principal
  - Objectifs secondaires
  - Population étudiée
  - Critères d'inclusion
  - Critères d'exclusion
  - Source de données
  - Recueil de données
  - Critère de jugement principal
  - Critères de jugement secondaires
  - Analyses statistiques
  - Limites

Lorsque tu as les éléments nécessaires, tu fais valider le protocole à l'utilisateur à l'aide d'une synthèse structurée.

Formates la synthèse structurée ainsi :

```markdown
# Introduction

<synthèse du contexte>

<question ou hypothèse principale de recherche>

<question ou hypothèse secondaires de recherche>

# Matériels & Méthode

### Poplutation étudiée

<description exacte de la population étudiée>

<description exacte et détaillée des critères d'inclusion, obligatoirement sous format tableau>

<description exacte et détaillée des critères d'exclusion, obligatoirement sous format tableau>

### Source de données

<description exacte de la source de données>

### Recueil de données

<description exacte du recueil de données>

### Critères de jugement

<description exacte et détaillée du critère de jugement principal, obligatoirement sous format tableau>

<description exacte et détaillée des critère de jugement secondaires, obligatoirement sous format tableau>

### Analyses statistiques

<description exacte et détaillée des analyses statistiques, obligatoirement sous format tableau>

# Limites

<description exacte et détaillée des limites identifiées, obligatoirement sous format tableau>
```

Le livrable validé est écrit dans `protocole.md`.