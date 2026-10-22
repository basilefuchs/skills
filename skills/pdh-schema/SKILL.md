---
name: pdh-schema
description: >
  Identifie dans protocole.md les champs, tables, variables, années et codes
  du PMSI national (portail ATIH) à retenir et écrit la section Données. Pour
  identifier les données PMSI du protocole.
license: MIT
---

Le protocole est `protocole.md` dans le répertoire courant, ou le fichier fourni. Chemins relatifs au dossier de la skill.

1. Consulte `references/dictionnaire/variables.csv` (séparateur `;`, colonnes et enregistrements multilignes décrits dans son `README.md`) pour identifier les tables et variables pertinentes ; filtre par `grep`, jamais de lecture intégrale.
2. Appuie-toi sur leurs définitions métier, pas uniquement sur leurs noms ; le profil du champ `references/profils/portail_atih_<champ>.md` fait foi sur l'environnement, `references/modele-donnees.md` décrit le modèle de données.
3. Si plusieurs variables semblent correspondre, vérifie leur granularité, leur rôle et leur présence sur chaque année de la période.
4. N'invente aucune table, variable ni définition absente du dictionnaire. Propose les codes CIM-10, CCAM ou CSARR avec leur source, ou dis qu'ils viennent de tes connaissances.
5. Signale les points de vigilance de `references/points-de-vigilance.md` qui s'appliquent, et toute incertitude que les informations ne permettent pas de trancher.
6. Écris champs, tables, variables, années et codes à retenir sous `# Données` dans `protocole.md`, remplacé s'il existe ; sans accès au fichier, dans ta réponse.
