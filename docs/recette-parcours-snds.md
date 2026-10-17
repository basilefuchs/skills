# Recette du parcours SNDS

Vérification manuelle de la chaîne `question-recherche-pico` → `snds-schema`
→ `snds-query` → `rapport-imrad`, dont aucun test automatisé ne couvre le
comportement. À dérouler avant un tag qui touche une skill de la chaîne.

Étude fictive : patients hospitalisés pour diabète, MCO, 2021-2023,
dénombrement interne, source SNDS, sous-groupe sexe.

## Préparation

- [ ] Les quatre skills et `snds-copilot`, copiées depuis la branche à
      recetter (`cp -r skills/<nom> ~/.claude/skills/`) ; plugins
      `snds-hdh` et `pdh-atih` désinstallés.
- [ ] Répertoire vide (`mkdir etude-diabete && cd etude-diabete`), Claude Code
      lancé dedans.

## 1. Cadrage : `/question-recherche-pico`

Taper `/question-recherche-pico patients hospitalisés pour diabète en MCO de
2021 à 2023`, puis répondre : finalité « Dénombrement interne », source « SNDS
via le Health Data Hub », population France entière par résidence, patients
uniques par année, sous-groupe « sexe », « Valider ».

- [ ] Chemin court : ni question de type d'étude ni critère FINER.
- [ ] Une question par message, « Ok : … » avant chacune.
- [ ] `protocole.md` créé avec `## Question` (type Descriptif, tableau P, O,
      T, sans bloc Fragilités FINER), `## Finalité` (Usage, Destinataires,
      Source de données : SNDS (Health Data Hub)) et `## Sous-groupes`, rien
      d'autre ; aucun effectif.
- [ ] Ligne de fin : « Étape suivante : `/snds-schema` » et la phrase
      « vérifier les données du protocole ».

## 2. Traduction en données : `/snds-schema`

Taper `/snds-schema`, sans argument, puis accepter les défauts.

- [ ] `./protocole.md` retrouvé sans question.
- [ ] Population, période, unité de compte et sous-groupes ne sont pas
      redemandés.
- [ ] Dictionnaire : commit frais de schema-snds, ou copie embarquée signalée
      avec sa date.
- [ ] Lots de quatre questions au plus, « Tout par défaut » au premier ;
      codes E10–E14 proposés avec leur source.
- [ ] Une seule validation « Valider / Corriger », après la synthèse.
- [ ] `protocole.md` reçoit `## Données` (ligne Dictionnaire et son commit,
      tables `T_MCO{aa}B` et `T_MCO{aa}C` vérifiées 2021-2023),
      `## Protocole validé`, `## Statut` (`validé le <date du jour>`) et
      `## Modifications` vide ; les sections de l'étape 1 sont intactes ;
      aucun effectif.
- [ ] Ligne de fin : `/snds-query` et « générer les scripts du protocole ».

## 3. Scripts : `/snds-query`

Taper `/snds-query`, sans argument, puis choisir le dossier `.R`.

- [ ] `./protocole.md` retrouvé sans question ; une seule question, le format.
- [ ] `scripts/` généré : `main.R`, `00_setup.R` à `06_sorties.R` ;
      `annees`, codes, question, dictionnaire et date de validation recopiés
      du protocole ; colonnes « À VÉRIFIER » listées dans le message.
- [ ] `## Scripts` et `## Confidentialité` écrits, le reste de `protocole.md`
      intact.
- [ ] Ligne de fin : exécuter, exporter `sorties/`, `/rapport-imrad`, la
      phrase « rédiger le rapport IMRaD », puis les retours (`/snds-schema`,
      `/snds-copilot`).

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

- Question : <question en une phrase de ## Question>
- Répertoire : etude-diabete
- Date d'exécution : <AAAA-MM-JJ HH:MM du jour>
- Années : 2021, 2022, 2023
- Sources : <valeur de la ligne Sources de ## Données>
- Seuil : 11
- Secret appliqué : comptages de 1 à 10 masqués (NA), colonnes dérivées de leur ligne aussi
- Dictionnaire : <valeur de la ligne Dictionnaire de ## Données>
- Protocole validé le : <date de ## Statut>

| Fichier | Cellules masquées |
| --- | --- |
| flowchart.csv | 1 |
| resultat_annuel.csv | 0 |
| nb_patients_periode.csv | 0 |
| strate_sexe.csv | 0 |
```

## 5. Rapport : `/rapport-imrad`

Taper `/rapport-imrad`, sans argument.

- [ ] Aucune question ; `rapport.md` écrit à côté de `protocole.md`.
- [ ] Cible « Rapport interne » : Introduction réduite à Objectif,
      Discussion à Résultat principal, Limites et Statistiques absentes.
- [ ] Avertissement de tête : 1 cellule masquée dans `flowchart.csv` ;
      « < 11 » à sa place dans le tableau, signalé sous lui.
- [ ] Colonne d'effectif du flowchart libellée « Séjours ».
- [ ] Méthodes : « étude descriptive sur base médico-administrative »,
      schéma marqué **À préciser** (chemin court).
- [ ] Chaque chiffre est une cellule de `sorties/` ; STROBE et RECORD
      nommées ; limites tirées des points de vigilance de `## Données`.

## 6. Refus d'un CSV à une ligne par séjour

Ajouter `sorties/sejours.csv` :

```
"annee","ETA_NUM","RSA_NUM","DGN_PAL","COD_SEX"
2021,"000000000","0000000001","E119","1"
2021,"000000000","0000000002","E109","2"
```

Taper `/rapport-imrad`.

- [ ] Un seul message : nomme le fichier et le signe (`RSA_NUM`), ne cite
      aucune valeur, demande de retirer le fichier, rappelle que seule la
      procédure d'export de la plateforme fait sortir des données.
- [ ] `rapport.md` inchangé, aucun autre fichier écrit.

Retirer `sorties/sejours.csv`.

## 7. Renvoi vers l'autre base

Dans un autre répertoire, une copie des trois sections de l'étape 1, puis
`/pdh-schema`, copiée elle aussi depuis la branche à recetter.

- [ ] Une ligne, « Ce protocole vise le SNDS : `/snds-schema`. », et rien
      d'autre ; `protocole.md` intact.

## Exécution du 2026-10-16

Déroulée sur la branche du ticket #55, hors dépôt, dans un répertoire vide :
chaque SKILL.md suivi à la main, réponses de l'utilisateur simulées. R
absent : scripts non exécutés, `sorties/` simulé (étape 4). Réseau présent :
dictionnaire frais, schema-snds commit 7bfdf37 (2026-04-27), tables et
variables de l'étude présentes de 2021 à 2023.

Étapes 1 à 6 conformes, aux écarts près :

- Corrigé : `rapport-imrad` nommait la colonne `nb_sejours` du flowchart
  d'après l'unité de compte du protocole, soit « Patients » pour cette étude,
  alors que le flowchart compte des séjours à chaque étape. Il la nomme
  désormais d'après la source : séjours en PMSI, prestations en DCIR, décès
  en CépiDc.
- Corrigé (8ecdf9b) : le chemin court n'a pas de schéma d'étude, que la
  section Méthodes de `rapport-imrad` demandait ; elle écrit désormais
  « étude descriptive sur base médico-administrative », schéma marqué
  **À préciser** (case ajoutée à l'étape 5).
- Corrigé (8ecdf9b) : la valeur par défaut de `dictionnaire` dans les
  squelettes ajoutait « schema-snds, commit » devant la ligne Dictionnaire
  de `## Données`, préfixe doublé dans le manifeste ; elle recopie
  désormais la ligne telle quelle.

L'étape 7 jouait alors `/snds-schema` sur un protocole PMSI national, faute
de `pdh-schema` (ticket #52). Dans sa forme actuelle, `/pdh-schema` sur les
trois sections de l'étape 1, elle a été rejouée le 2026-10-16 sur la branche
du ticket #43, SKILL.md suivi à la main : conforme.
