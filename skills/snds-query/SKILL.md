---
name: snds-query
description: >
  Génère depuis protocole.md et sa section Données les scripts R dbplyr/Oracle
  d'une étude SNDS, à exécuter sur le Health Data Hub. Pour générer les
  scripts du protocole.
license: MIT
---

Le protocole est `protocole.md` dans le répertoire courant, ou le fichier fourni ; il fait foi : recopie ses tables, variables et codes, n'en ajoute aucun. Chemins relatifs au dossier de la skill.

1. Pars du squelette `references/template/` (dossier `.R`, un fichier par étape, `main.R`), ou de `references/template.Rmd` si un rapport `.Rmd` est demandé. Le squelette fait foi sur le code ; n'y change que ce que le protocole fixe.
2. `references/profils/hdh_oracle.md` fait foi sur l'environnement ; sa connexion est recopiée dans `00_setup.R`.
3. Une colonne que ni le protocole, ni le squelette, ni le profil ne nomment est marquée `# À VÉRIFIER` et listée dans ta réponse, jamais devinée.
4. Tout fichier s'écrit par `exporter()` dans `sorties/` : seuls des agrégats sous seuil sortent de la plateforme.
5. Écris les scripts à côté de `protocole.md`, remplacés s'ils existent ; sans accès au répertoire, livre-les dans ta réponse.
