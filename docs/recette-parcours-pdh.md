# Recette du parcours PMSI national

Vérification manuelle de la chaîne `question-recherche-pico` → `pdh-schema`
→ `pdh-query` → `rapport-imrad`, dont aucun test automatisé ne couvre le
comportement. À dérouler avant un tag qui touche une skill de la chaîne.

Étude fictive : patients hospitalisés pour diabète, MCO, 2021-2023,
dénombrement interne, source PMSI national, sous-groupe sexe.

## Préparation

- [ ] Les quatre skills copiées depuis la branche à recetter
      (`cp -r skills/<nom> ~/.claude/skills/`), et `snds-schema` pour
      l'étape 7 ; plugins `snds-hdh` et `pdh-atih` désinstallés.
- [ ] Répertoire vide (`mkdir etude-diabete-pmsi && cd etude-diabete-pmsi`),
      Claude Code lancé dedans.

## 1. Cadrage : `/question-recherche-pico`

Taper `/question-recherche-pico patients hospitalisés pour diabète en MCO de
2021 à 2023`, puis répondre : finalité « Dénombrement interne », source
« PMSI national via le portail ATIH », population France entière par
résidence, patients uniques par année, sous-groupe « sexe », « Valider ».

- [ ] Chemin court : ni question de type d'étude ni critère FINER.
- [ ] `protocole.md` créé avec `## Question` (type Descriptif, tableau P, O,
      T), `## Finalité` (Source de données : PMSI national (portail ATIH))
      et `## Sous-groupes`, rien d'autre ; aucun effectif.
- [ ] Ligne de fin : « Étape suivante : `/pdh-schema` » et la phrase
      « vérifier les données du protocole ».

## 2. Traduction en données : `/pdh-schema`

Taper `/pdh-schema`, sans argument, puis accepter les défauts.

- [ ] `./protocole.md` retrouvé sans question.
- [ ] Population, période, unité de compte et sous-groupes ne sont pas
      redemandés.
- [ ] Dictionnaire embarqué, sa date signalée.
- [ ] Lots de quatre questions au plus, « Tout par défaut » au premier ;
      codes E10–E14 proposés avec leur source.
- [ ] Une seule validation « Valider / Corriger », après la synthèse.
- [ ] `protocole.md` reçoit `## Données` (ligne « Dictionnaire : portail
      ATIH, `variables-<AAAA-MM-JJ>.csv` », table
      `prd_vue_mcobl_{AAAA}.fixe` vérifiée 2021-2023), `## Protocole validé`,
      `## Statut` (`validé le <date du jour>`) et `## Modifications` vide ;
      les sections de l'étape 1 sont intactes ; aucun effectif.
- [ ] Ligne de fin : `/pdh-query` et « générer les scripts du protocole ».

## 3. Scripts : `/pdh-query`

Taper `/pdh-query`, sans argument, puis choisir le dossier `.R`.

- [ ] `./protocole.md` retrouvé sans question ; une seule question, le
      format, aucune sur l'environnement.
- [ ] `scripts/` généré : `main.R`, `00_setup.R` à `06_sorties.R` ;
      `annees`, codes, question, sources, dictionnaire et date de validation
      recopiés du protocole ; bloc « PROFIL DE BASE » avec Sources, la table
      et ses variables, la ligne Dictionnaire ; colonnes « À VÉRIFIER »
      listées dans le message (aucune pour cette étude).
- [ ] `## Scripts` et `## Confidentialité` écrits, le reste de `protocole.md`
      intact.
- [ ] Ligne de fin : exécuter, exporter `sorties/`, `/rapport-imrad`, la
      phrase « rédiger le rapport IMRaD », puis le retour `/pdh-schema` ;
      aucun renvoi vers `snds-copilot`.

## 4. Plateforme simulée : `sorties/`

Sans plateforme, créer `sorties/` à côté de `protocole.md`, aux noms et
en-têtes du contrat, avec une cellule masquée :

`flowchart.csv`

```
"annee","etape","nb_sejours","nb_exclus"
2021,"01 Sejours DP cible",176210,0
2021,"02a hors seances (CMD 28)",171904,4306
2021,"02b hors GHM en erreur (90)",171897,NA
2021,"02c chainage exploitable",169388,2509
2022,"01 Sejours DP cible",179045,0
2022,"02a hors seances (CMD 28)",174652,4393
2022,"02b hors GHM en erreur (90)",174631,21
2022,"02c chainage exploitable",172170,2461
2023,"01 Sejours DP cible",181932,0
2023,"02a hors seances (CMD 28)",177401,4531
2023,"02b hors GHM en erreur (90)",177383,18
2023,"02c chainage exploitable",174902,2481
```

`resultat_annuel.csv`

```
"annee","nb_sejours","nb_patients"
2021,169388,126540
2022,172170,128311
2023,174902,130077
```

`nb_patients_periode.csv`

```
"nb_patients"
290684
```

`strate_sexe_lib.csv`

```
"annee","sexe_lib","nb_sejours","nb_patients","pct_patients"
2021,"Femme",73860,55045,43.5
2021,"Homme",95528,71495,56.5
2022,"Femme",74890,55626,43.4
2022,"Homme",97280,72685,56.6
2023,"Femme",75907,56288,43.3
2023,"Homme",98995,73789,56.7
```

`manifeste.md` : la forme qu'écrit `exporter()` dans `00_setup.R`, avec les
valeurs du protocole, la date du jour, le seuil 11, et 1 cellule masquée pour
`flowchart.csv`, 0 pour les autres.

## 5. Rapport : `/rapport-imrad`

Taper `/rapport-imrad`, sans argument.

- [ ] Aucune question ; `rapport.md` écrit à côté de `protocole.md`.
- [ ] Cible « Rapport interne » : Introduction réduite à Objectif,
      Discussion à Résultat principal, Limites et Statistiques absentes.
- [ ] Avertissement de tête : 1 cellule masquée dans `flowchart.csv` ;
      « < 11 » à sa place dans le tableau, signalé sous lui.
- [ ] Colonne d'effectif du flowchart libellée « Séjours » ; dictionnaire
      `variables-<AAAA-MM-JJ>.csv` en tête et dans les Méthodes.
- [ ] Chaque chiffre est une cellule de `sorties/` ; STROBE et RECORD
      nommées ; limites tirées des points de vigilance de `## Données`.

## 6. Refus d'un CSV à une ligne par séjour

Ajouter `sorties/sejours.csv` :

```
"annee","ident","anonyme","dp","sexe"
2021,"0000001","AAAAAAAAAAAAAAAAA","E119","1"
2021,"0000002","BBBBBBBBBBBBBBBBB","E109","2"
```

Taper `/rapport-imrad`.

- [ ] Un seul message : nomme le fichier et le signe (`ident`, `anonyme`),
      ne cite aucune valeur, demande de retirer le fichier, rappelle que
      seule la procédure d'export de la plateforme fait sortir des données.
- [ ] `rapport.md` inchangé, aucun autre fichier écrit.

Retirer `sorties/sejours.csv`.

## 7. Renvois

Dans un autre répertoire, une copie des trois sections de l'étape 1.

- [ ] `/snds-schema` : une ligne, « Ce protocole vise le PMSI national :
      `/pdh-schema`. », et rien d'autre ; `protocole.md` intact.
- [ ] `/pdh-query` : une ligne, « Le protocole n'est pas validé : lancez
      `/pdh-schema`. », et rien d'autre.

Dans un répertoire vide :

- [ ] `/pdh-query combien de patients hospitalisés pour diabète en 2023 ?` :
      une ligne, « Cadrez d'abord la question :
      `/question-recherche-pico <question>`. ».

## 8. Amendement et régénération

Dans le répertoire de l'étude, taper `/pdh-schema` et demander d'élargir la
position du diagnostic au DR, valider, puis `/pdh-query`.

- [ ] `## Statut` repasse à `validé le <date du jour>`, une ligne datée dans
      `## Modifications`.
- [ ] `/pdh-query` régénère : « (Recommandé) » sur le format de `## Scripts`,
      scripts réécrits en entier, message listant les fichiers réécrits ;
      `## Scripts` remplacée.

## Exécution du 2026-10-16

Déroulée sur la branche du ticket #54, hors dépôt, dans un répertoire vide :
chaque SKILL.md suivi à la main, réponses de l'utilisateur simulées. R et
réseau absents : scripts non exécutés, `sorties/` simulé (étape 4) ;
dictionnaire embarqué `variables-2026-07-18.csv`, variables de `fixe`
utilisées par l'étude présentes de 2016 à 2026.

Étapes 1 à 8 conformes, aux écarts près :

- Corrigé : `rapport-imrad` ne reconnaissait comme identifiants que des
  colonnes SNDS ; `sejours.csv` n'était arrêté que faute de colonne de
  comptage, sans signe nommé. Il reconnaît désormais `anonyme`, `ident`,
  `ident_sej`, `date_entree` et `date_sortie`, et tient `finess` et
  `finessgeo` pour des strates.
- Corrigé : l'en-tête et les Méthodes de `rapport-imrad` attendaient un
  commit de dictionnaire ; le PMSI national a une version
  (`variables-<AAAA-MM-JJ>.csv`).
- Noté : ni `pdh-query` ni `snds-query` ne renvoient un protocole de l'autre
  base. `/pdh-query` sur un protocole SNDS validé répond « lancez
  `/pdh-schema` », qui renvoie à son tour vers `/snds-schema` ; sur
  claude.ai, les deux descriptions portent « générer les scripts du
  protocole », seul le mot-clé de la base les distingue.
