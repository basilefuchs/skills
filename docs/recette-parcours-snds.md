# Recette du parcours SNDS

Vérification manuelle de la chaîne `to-protocole` → `snds-schema`
→ `snds-query`, dont aucun test automatisé ne couvre le
comportement. À dérouler avant un tag qui touche une skill de la chaîne.

Étude fictive : patients hospitalisés pour diabète, MCO, 2021-2023,
dénombrement interne, source SNDS, sous-groupe sexe.

## Préparation

- [ ] Les trois skills, copiées depuis la branche à recetter
      (`cp -r skills/<nom> ~/.claude/skills/`) ; plugins `snds-hdh` et
      `pdh-atih` désinstallés.
- [ ] Répertoire vide (`mkdir etude-diabete && cd etude-diabete`), Claude Code
      lancé dedans.

## 1. Cadrage : `/to-protocole`

Taper `/to-protocole patients hospitalisés pour diabète en MCO de
2021 à 2023`, puis répondre : objectif « Dénombrement interne », source
« SNDS via le Health Data Hub », population France entière par
résidence, critère de jugement principal « patients uniques par année »,
analyse stratifiée par sexe, puis valider la synthèse.

- [ ] `protocole.md` créé avec la synthèse validée (`# Introduction`,
      `# Matériels & Méthode`, `# Limites`), rien d'autre ; aucun effectif.

## 2. Données : `/snds-schema`

Taper `/snds-schema`, sans argument.

- [ ] Une réponse, sans question ; `./protocole.md` retrouvé.
- [ ] Tables `T_MCO{aa}B` (`DGN_PAL`, `COD_SEX`) et `T_MCO{aa}C`
      (`NIR_ANO_17`, codes retour) et leurs millésimes vérifiés 2021-2023
      dans le dictionnaire embarqué, sans clone de schema-snds.
- [ ] Codes E10–E14 avec leur source, ou donnés pour venir des
      connaissances de la skill.
- [ ] Points de vigilance qui s'appliquent et incertitudes signalés.
- [ ] `protocole.md` reçoit `# Données`, rien d'autre ; les sections de
      l'étape 1 sont intactes ; aucun effectif.

## 3. Scripts : `/snds-query`

Taper `/snds-query`, sans argument.

- [ ] Une réponse, sans question ; `./protocole.md` retrouvé.
- [ ] `scripts/` généré : `main.R`, `00_setup.R` à `06_sorties.R` ;
      `annees`, codes, question et sources recopiés de
      `protocole.md` ; colonnes « À VÉRIFIER » listées dans la réponse.
- [ ] `00_setup.R` : `exporter()` écrit `manifeste.md` sans ligne
      « Protocole validé le ».
- [ ] `protocole.md` intact.

Taper `/snds-query génère un rapport .Rmd`.

- [ ] Un fichier `.Rmd` à côté de `protocole.md`, mêmes étapes en chunks,
      sans question ; `protocole.md` intact.

## 4. Plateforme simulée : `sorties/`

Sans plateforme, créer `sorties/` à côté de `protocole.md`, aux noms et
en-têtes du contrat, avec une cellule masquée :

`flowchart.csv`

```
"annee","etape","nb_sejours","nb_exclus"
2021,"01 Sejours DP cible",182430,0
2021,"02a chainage exploitable",179870,2560
2021,"02b hors prestations inter-etab.",179863,NA
2021,"02c hors GHM en erreur (90)",179790,73
2022,"01 Sejours DP cible",185112,0
2022,"02a chainage exploitable",182650,2462
2022,"02b hors prestations inter-etab.",182631,19
2022,"02c hors GHM en erreur (90)",182560,71
2023,"01 Sejours DP cible",187905,0
2023,"02a chainage exploitable",185410,2495
2023,"02b hors prestations inter-etab.",185388,22
2023,"02c hors GHM en erreur (90)",185322,66
```

`resultat_annuel.csv`

```
"annee","nb_sejours","nb_patients"
2021,179790,131204
2022,182560,133018
2023,185322,134877
```

`nb_patients_periode.csv`

```
"nb_patients"
301456
```

`strate_sexe.csv`

```
"annee","sexe","nb_sejours","nb_patients","pct_patients"
2021,"Homme",101532,73811,56.3
2021,"Femme",78258,57393,43.7
2022,"Homme",103344,75015,56.4
2022,"Femme",79216,58003,43.6
2023,"Homme",105102,76132,56.4
2023,"Femme",80220,58745,43.6
```

`manifeste.md`, tel qu'`exporter()` l'écrit, chevrons remplacés par les
valeurs de `protocole.md` ; la figure, que la recette ne simule pas, en est
absente :

```
# Manifeste de sorties/

- Question : <question principale de # Introduction>
- Répertoire : etude-diabete
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
| strate_sexe.csv | 0 |
```

## 5. Relance

Dans le répertoire de l'étude, taper `/snds-schema élargis la position du
diagnostic au DR`, puis `/snds-query`.

- [ ] `# Données` remplacée en entier : une seule section `# Données`,
      `DGN_REL` comprise ; le reste de `protocole.md` intact.
- [ ] Scripts réécrits en entier, sans question ; `protocole.md` intact.
