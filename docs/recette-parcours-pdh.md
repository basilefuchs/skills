# Recette du parcours PMSI national

Vérification manuelle de la chaîne `to-protocole` → `pdh-schema`
→ `pdh-query`, dont aucun test automatisé ne couvre le
comportement. À dérouler avant un tag qui touche une skill de la chaîne.

Étude fictive : patients hospitalisés pour diabète, MCO, 2021-2023,
dénombrement interne, source PMSI national, sous-groupe sexe.

## Préparation

- [ ] Les trois skills copiées depuis la branche à recetter
      (`cp -r skills/<nom> ~/.claude/skills/`), et `snds-schema` et
      `snds-query` pour l'étape 5 ; plugins `snds-hdh` et `pdh-atih`
      désinstallés.
- [ ] Répertoire vide (`mkdir etude-diabete-pmsi && cd etude-diabete-pmsi`),
      Claude Code lancé dedans.

## 1. Cadrage : `/to-protocole`

Taper `/to-protocole patients hospitalisés pour diabète en MCO de
2021 à 2023`, puis répondre : objectif « Dénombrement interne », source
« PMSI national via le portail ATIH », population France entière par
résidence, critère de jugement principal « patients uniques par année »,
analyse stratifiée par sexe, puis valider la synthèse.

- [ ] `protocole.md` créé avec la synthèse validée (`# Introduction`,
      `# Matériels & Méthode`, `# Limites`), rien d'autre ; aucun effectif.

## 2. Traduction en données : `/pdh-schema`

Taper `/pdh-schema`, sans argument, puis accepter les défauts.

- [ ] `./protocole.md` retrouvé sans question.
- [ ] Population, période, unité de compte et sous-groupes ne sont pas
      redemandés.
- [ ] Dictionnaire embarqué, sa date signalée.
- [ ] Lots de quatre questions au plus, « Tout par défaut » au premier ;
      codes E10–E14 proposés avec leur source.
- [ ] Une seule validation « Valider / Corriger », après la synthèse.
- [ ] `protocole.md` reçoit `# Données` (ligne « Dictionnaire : portail
      ATIH, `variables-<AAAA-MM-JJ>.csv` », table
      `prd_vue_mcobl_{AAAA}.fixe` vérifiée 2021-2023), `# Protocole validé`,
      `# Statut` (`validé le <date du jour>`) et `# Modifications` vide ;
      les sections de l'étape 1 sont intactes ; aucun effectif.

## 3. Scripts : `/pdh-query`

Taper `/pdh-query`, sans argument, puis choisir le dossier `.R`.

- [ ] `./protocole.md` retrouvé sans question ; une seule question, le
      format, aucune sur l'environnement.
- [ ] `scripts/` généré : `main.R`, `00_setup.R` à `06_sorties.R` ;
      `annees`, codes, question, sources, dictionnaire et date de validation
      recopiés du protocole ; bloc « PROFIL DE BASE » avec Sources, la table
      et ses variables, la ligne Dictionnaire ; colonnes « À VÉRIFIER »
      listées dans le message (aucune pour cette étude).
- [ ] `# Scripts` et `# Confidentialité` écrits, le reste de `protocole.md`
      intact.

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

`manifeste.md`, tel qu'`exporter()` l'écrit, chevrons remplacés par les
valeurs de `protocole.md` ; la figure, que la recette ne simule pas, en est
absente :

```
# Manifeste de sorties/

- Question : <question principale de # Introduction>
- Répertoire : etude-diabete-pmsi
- Date d'exécution : <AAAA-MM-JJ HH:MM du jour>
- Années : 2021, 2022, 2023
- Sources : <valeur de la ligne Sources de # Données>
- Seuil : 11
- Secret appliqué : comptages de 1 à 10 masqués (NA), colonnes dérivées de leur ligne aussi
- Dictionnaire : <valeur de la ligne Dictionnaire de # Données>
- Protocole validé le : <date de # Statut>

| Fichier | Cellules masquées |
| --- | --- |
| flowchart.csv | 1 |
| resultat_annuel.csv | 0 |
| nb_patients_periode.csv | 0 |
| strate_sexe_lib.csv | 0 |
```

## 5. Renvois

Dans un autre répertoire, une copie du `protocole.md` de l'étape 1, sans
les sections ajoutées ensuite.

- [ ] `/snds-schema` : une ligne, « Ce protocole vise le PMSI national :
      `/pdh-schema`. », et rien d'autre ; `protocole.md` intact.
- [ ] `/pdh-query` : une ligne, « Le protocole n'est pas validé : lancez
      `/pdh-schema`. », et rien d'autre.
- [ ] `/snds-query` : une ligne, « Ce protocole vise le PMSI national :
      `/pdh-query`. », et rien d'autre.

Dans un répertoire vide :

- [ ] `/pdh-query combien de patients hospitalisés pour diabète en 2023 ?` :
      une ligne, « Cadrez d'abord la question :
      `/to-protocole <question>`. ».

Dans un répertoire dont le `protocole.md` est à l'ancien format (`## Question`,
`## Finalité`, `## Sous-groupes`) :

- [ ] `/pdh-schema` : une ligne, « Ce protocole est à l'ancien format :
      relancez `/to-protocole`. », et rien d'autre ; `protocole.md` intact.

## 6. Amendement et régénération

Dans le répertoire de l'étude, taper `/pdh-schema` et demander d'élargir la
position du diagnostic au DR, valider, puis `/pdh-query`.

- [ ] `# Statut` repasse à `validé le <date du jour>`, une ligne datée dans
      `# Modifications`.
- [ ] `/pdh-query` régénère : « (Recommandé) » sur le format de `# Scripts`,
      scripts réécrits en entier, message listant les fichiers réécrits ;
      `# Scripts` remplacée.

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
- Corrigé depuis (ticket #43) : ni `pdh-query` ni `snds-query` ne
  renvoyaient un protocole de l'autre base ; `/pdh-query` sur un protocole
  SNDS validé répondait « lancez `/pdh-schema` », qui renvoyait à son tour
  vers `/snds-schema`. Chaque skill query lit désormais la source de données
  de `## Finalité` et renvoie vers l'autre query. Case ajoutée à l'étape 7,
  jouée le 2026-10-16 sur la branche du ticket #43, SKILL.md suivi à la
  main : conforme.
