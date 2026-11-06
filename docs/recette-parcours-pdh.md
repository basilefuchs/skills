# Recette du parcours PMSI national

Vérification manuelle de la chaîne `to-protocole` → `pdh-schema`
→ `pdh-query`, dont aucun test automatisé ne couvre le
comportement. À dérouler avant un tag qui touche une skill de la chaîne.

Étude fictive : patients hospitalisés pour diabète, MCO, 2021-2023,
dénombrement interne, source PMSI national, sous-groupe sexe.

## Préparation

- [ ] Les trois skills, copiées depuis la branche à recetter
      (`cp -r skills/<nom> ~/.claude/skills/`) ; plugins `snds-hdh` et
      `pdh-atih` désinstallés.
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

## 2. Données : `/pdh-schema`

Taper `/pdh-schema`, sans argument.

- [ ] Une réponse, sans question ; `./protocole.md` retrouvé.
- [ ] Champ MCO, table `prd_vue_mcobl_{AAAA}.fixe` et ses variables (`dp`,
      `anonyme`, `ano_retour`, `sexe`) vérifiées 2021-2023 dans
      `variables.csv` (`andeb`, `anfin`).
- [ ] Codes E10–E14 avec leur source, ou donnés pour venir des
      connaissances de la skill.
- [ ] Points de vigilance qui s'appliquent et incertitudes signalés.
- [ ] `protocole.md` reçoit `# Données`, rien d'autre ; les sections de
      l'étape 1 sont intactes ; aucun effectif.

## 3. Scripts : `/pdh-query`

Taper `/pdh-query`, sans argument.

- [ ] Une réponse, sans question ; `./protocole.md` retrouvé.
- [ ] `scripts/` généré : `main.R`, `00_setup.R` à `06_sorties.R` ;
      `annees`, codes, question et sources recopiés de
      `protocole.md` ; bloc « PROFIL DE BASE » réduit à la table et aux
      variables de `# Données` ; colonnes « À VÉRIFIER » listées dans la
      réponse (aucune pour cette étude).
- [ ] `00_setup.R` : `exporter()` écrit `manifeste.md` sans ligne
      « Protocole validé le ».
- [ ] `protocole.md` intact.

Taper `/pdh-query génère un rapport .Rmd`.

- [ ] Un fichier `.Rmd` à côté de `protocole.md`, mêmes étapes en chunks,
      sans question ; `protocole.md` intact.

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
- Sources : <sources de # Données>
- Seuil : 11
- Secret appliqué : comptages de 1 à 10 masqués (NA), colonnes dérivées de leur ligne aussi
- Dictionnaire : <dictionnaire, s'il est nommé dans # Données>

| Fichier | Cellules masquées |
| --- | --- |
| flowchart.csv | 1 |
| resultat_annuel.csv | 0 |
| nb_patients_periode.csv | 0 |
| strate_sexe_lib.csv | 0 |
```

## 5. Relance

Dans le répertoire de l'étude, taper `/pdh-schema élargis la position du
diagnostic au DR`, puis `/pdh-query`.

- [ ] `# Données` remplacée en entier : une seule section `# Données`, `dr`
      comprise ; le reste de `protocole.md` intact.
- [ ] Scripts réécrits en entier, sans question ; `protocole.md` intact.
