---
name: rapport-imrad
description: >
  Rédige le rapport IMRaD d'une étude SNDS ou PMSI depuis protocole.md et
  les agrégats de sorties/ : Méthodes et Résultats en prose, Introduction et
  Discussion en puces. Pour rédiger le rapport IMRaD.
license: MIT
---

# Rapport IMRaD

Tu rédiges le rapport IMRaD d'une étude dont le protocole est `protocole.md` et dont les résultats sont les agrégats de `sorties/`, écrits par les scripts de la skill query et sortis de la plateforme (Health Data Hub, portail ATIH) par sa procédure d'export. Méthodes et Résultats sont en prose, depuis le protocole et les agrégats ; Introduction et Discussion en puces, avec **À préciser** là où la littérature ou le jugement de la personne manquent. Quand tout est présent, le rapport sort sans question.

Chaque chiffre du rapport est une cellule d'un fichier de `sorties/`, et aucun n'est sous le seuil : une statistique que les fichiers ne contiennent pas (intervalle de confiance, standardisation, test, total recalculé) est nommée comme absente ; un comptage de 1 à 10 s'écrit « < 11 », comme une cellule masquée (étape 2). Chaque source citée est inscrite dans le protocole : aucune recherche bibliographique. Rédige dans la langue du protocole, mention **À préciser** comprise.

## Entrées

### `protocole.md`

Sections lues, rien d'autre :

| Section (propriétaire) | Ce qui est lu |
|---|---|
| `## Question` (`question-recherche-pico`) | type d'étude, question en une phrase, grille P, I/E, C, O, T et schéma, fragilités FINER si présentes |
| `## Finalité` (`question-recherche-pico`) | Usage, Destinataires, Source de données |
| `## Sous-groupes` (`question-recherche-pico`) | stratifications attendues |
| `## Données` (skill schema) | ligne Dictionnaire, Sources, Période, tableau des tables, variables et millésimes vérifiés, Codes et leur source, Position du diagnostic, Unité de compte, Dénominateur, Exclusions, Chaînage, Points de vigilance |
| `## Protocole validé` (skill schema) | Population, Exclusions, Critère de jugement, Stratification, Sources et chaînage |
| `## Statut` (skill schema) | `validé le AAAA-MM-JJ` ou `brouillon` |
| `## Modifications` (skill schema) | une ligne datée par amendement |
| `## Scripts`, `## Confidentialité` (skill query), si présentes | format et fichiers générés, date de génération ; texte de confidentialité |

### `sorties/`

Fichiers attendus, rien d'autre. Une colonne de comptage commence par `nb_` ; une colonne dérivée commence par `pct_` ou `taux` ; une cellule masquée vaut `NA` ; les guillemets de l'en-tête écrit par R ne comptent pas.

| Fichier | Colonnes attendues | Dans le rapport |
|---|---|---|
| `flowchart.csv` | `annee`, `etape`, `nb_sejours`, `nb_exclus`, exactement | diagramme de flux |
| `resultat_annuel.csv` | `annee`, des comptages, des dérivées éventuelles | résultat principal par année |
| `nb_patients_periode.csv` | `nb_patients` | patients uniques sur la période |
| `strate_<variable>.csv`, une par stratification | `annee`, `<variable>`, des comptages, des dérivées éventuelles | un tableau par sous-groupe |
| `figure_<nom>.png`, optionnelles | — | figure référencée par son nom |
| `manifeste.md` | question, répertoire, date d'exécution, années, sources, seuil, secret appliqué, dictionnaire, date de validation du protocole, tableau fichier / cellules masquées | état de l'export, en tête du rapport |

`nb_sejours` du flowchart compte les lignes de la source, quelle que soit l'unité de compte : séjours en PMSI, prestations en DCIR, décès en CépiDc. Le rapport les nomme d'après Sources de `## Données`.

## Démarche

### 1. Découverte

Dans cet ordre : le chemin passé en argument (répertoire de l'étude, ou son `protocole.md`), sinon `./protocole.md` et `./sorties/`, sinon les fichiers téléversés (claude.ai : `protocole.md` et les fichiers de `sorties/` ensemble), sinon une seule question : « Donnez le chemin du répertoire de l'étude (`protocole.md` et `sorties/`), ou téléversez-les. »

Renvois, en une ligne, puis arrêt :

- `protocole.md` sans `## Données` ni `## Protocole validé` : « Le protocole n'est pas traduit en données : `/snds-schema` ou `/pdh-schema` selon la source. » ;
- `sorties/` absent ou vide : « Exécutez les scripts sur la plateforme et exportez `sorties/` à côté de `protocole.md`. » ;
- un résultat collé dans le message (sortie console de R, tableau recopié) : « Le rapport se rédige depuis les fichiers de `sorties/` tels qu'écrits par les scripts : téléversez-les. »

C'est fini quand `protocole.md` et les fichiers de `sorties/` sont localisés.

### 2. Contrôle de `sorties/`

Avant de lire une seule valeur, lis l'en-tête de chaque CSV et compte ses lignes, puis classe chaque fichier dans le premier cas qui s'applique :

- **Lignes individuelles** : une colonne d'identifiant de personne ou de séjour (`NIR_ANO_17`, `BEN_NIR_PSA`, `BEN_IDT_ANO`, `RSA_NUM`, `RHA_NUM`, `RHS_NUM`, `RIP_NUM`, tout nom contenant `_NIR_` ou `_IDT_` ; `ETA_NUM`, numéro FINESS d'un établissement, est une strate, pas un identifiant), ou une date au jour (`AAAA-MM-JJ`, `EXE_SOI_DTD`, `ENT_DAT`, `SOR_DAT`…), ou des lignes sans colonne de comptage, une par séjour, prestation ou décès. **Arrêt net** : un seul message, qui nomme le fichier et le signe, sans citer une valeur ni une ligne, sans écrire de fichier ni d'artefact ; demande de retirer le fichier de la conversation et du répertoire ; rappelle que seule la procédure d'export de la plateforme fait sortir des données, sous forme d'agrégats. Rien d'autre dans ce message, et pas de rapport.
- **Hors contrat** : nom absent du tableau des fichiers attendus, ou colonnes différentes. Nomme le fichier et les colonnes attendues, demande de relancer les scripts (de les régénérer avec la skill query s'ils sont antérieurs au contrat), et arrête-toi : rien n'est deviné.
- **Conforme** : colonnes au contrat. Note les cellules masquées : `NA` dans un comptage ou une dérivée, et tout comptage strictement compris entre 0 et le seuil du manifeste (de 1 à 10 pour le seuil 11), qui révèle un export sans seuil et devient une cellule masquée, avec les dérivées de sa ligne.

C'est fini quand chaque fichier est classé, et qu'aucun n'est individuel ni hors contrat.

### 3. Lecture

Lis les sections de `protocole.md` et `manifeste.md`, puis fixe :

- la **cible**, d'après Usage de `## Finalité`, sans question :

  | Usage | Cible | Introduction et Discussion |
  |---|---|---|
  | dénombrement interne | Rapport interne | Objectif ; résultat principal, limites, statistiques absentes |
  | rapport ou dialogue de gestion, diffusion externe | Rapport | complètes |
  | publication ou thèse | Article | complètes ; les listes de contrôle STROBE et RECORD sont à joindre à la soumission |

- la **ligne directrice** : STROBE et RECORD ; RECORD-PE en plus quand I/E est un médicament lu dans le DCIR (codes ATC, `ER_PHA_F`). L'analyse est descriptive : effectifs et proportions tels que les agrégats les donnent ;
- les **avertissements** de tête : cellules masquées, avec leur nombre par fichier (manifeste, ou comptage des `NA`) ; export sans seuil (comptages de 1 à 10, masqués par le rapport) ; manifeste daté avant `## Statut` ou avant la dernière ligne de `## Modifications` (sorties antérieures à la dernière validation) ; `## Statut` en brouillon ; années ou sources du manifeste différentes de celles du protocole ;
- les **limites** : chaque point de vigilance de `## Données`, chaque ligne de `## Modifications`, chaque fragilité FINER, le chaînage de `## Données` s'il y en a un, le masquage.

C'est fini quand la cible, la ligne directrice, les avertissements et les limites sont fixés.

### 4. Rédaction

Rédige le rapport (section **Gabarit**).

Méthodes, en prose, depuis `protocole.md` seul : schéma et type d'étude (chemin court sans schéma dans `## Question` : « étude descriptive sur base médico-administrative », schéma marqué **À préciser**) ; sources et chaînage ; population (P, base géographique, période et millésimes, tables du tableau de `## Données`) ; codes retenus avec leur source telle qu'inscrite, position du diagnostic ; unité de compte et indicateur ; exclusions dans l'ordre ; stratification ; secret statistique (seuil, masque des comptages et des dérivées, manifeste, texte de `## Confidentialité` s'il existe) ; ligne directrice. Le dictionnaire et son commit, la date de validation et, si `## Scripts` existe, le format et les fichiers y figurent aussi.

Résultats, en prose, depuis `sorties/` seul : la sélection de la population raconte `flowchart.csv` étape par étape et le montre en tableau (année, étape, effectif, exclus) ; le résultat principal reprend `resultat_annuel.csv` et `nb_patients_periode.csv` ; un sous-titre par `strate_<variable>.csv`, avec son tableau ; chaque figure est référencée par son nom. Un comptage masqué s'écrit « < 11 » (le seuil du manifeste), une dérivée masquée « masquée », et chaque tableau qui en contient le dit sous lui. Une statistique attendue par le protocole et absente des fichiers (taux sur dénominateur externe, intervalle de confiance, évolution calculée) est nommée comme absente, dans les Résultats et dans la Discussion.

Introduction et Discussion, en puces : l'objectif reprend la question ; le contexte, la comparaison à la littérature et les implications sont **À préciser** ; les limites sont celles fixées à l'étape 3, chacune appliquée à ce protocole en une puce.

C'est fini quand chaque chiffre du rapport est une cellule de `sorties/`, chaque source une source du protocole, et chaque ligne du gabarit remplie ou marquée **À préciser**.

### 5. Livraison

Dans le répertoire de l'étude (Claude Code) : écris `rapport.md` à côté de `protocole.md`, remplacé s'il existe, et réponds avec le chemin, les avertissements de tête et la liste des **À préciser**. Sans accès au répertoire (claude.ai) : le rapport entier est le message.

C'est fini quand le rapport est livré. Il n'y a pas d'étape suivante.

## Gabarit

Réponds avec exactement cette structure, sans le bloc de code ; les titres restent ceux du modèle, quelle que soit la langue.

```markdown
# <Rapport interne | Rapport | Article> · <question en une phrase>

<Destinataires> · protocole validé le <AAAA-MM-JJ> · scripts exécutés le <date d'exécution du manifeste> · dictionnaire <commit> · seuil <seuil>

> **Avertissements** · <une puce par avertissement de l'étape 3 | aucun>

## Introduction

- Contexte : **À préciser**
- Objectif : <question en une phrase, population, période>
- Hypothèse : <… | sans objet>

## Méthodes

<prose : schéma et sources, population, codes et critère de jugement, exclusions et stratification, secret statistique, ligne directrice>

## Résultats

### Sélection de la population

<prose depuis flowchart.csv>

| Année | Étape | <Séjours | Prestations | Décès> | Exclus |
|---|---|---|---|
| <…> | <…> | <n | < 11> | <n | < 11> |

### Résultat principal

<prose depuis resultat_annuel.csv et nb_patients_periode.csv, puis le tableau>

### <Sous-groupe : variable>

<prose depuis strate_<variable>.csv, puis le tableau ; figure_<nom>.png référencée>

## Discussion

- Résultat principal : <une phrase, chiffres des agrégats>
- Limites : <une puce par limite de l'étape 3>
- Statistiques absentes des agrégats : <… : non calculées | aucune>
- Comparaison à la littérature : **À préciser**
- Implications : **À préciser**

## À préciser

- <chaque élément marqué À préciser> | rien
```

- Rapport interne : l'Introduction se réduit à Objectif ; la Discussion à Résultat principal, Limites et Statistiques absentes.
- Les tableaux reprennent les colonnes des fichiers, libellées en clair ; un comptage masqué est « < 11 », une dérivée masquée « masquée », jamais 0, ni vide, ni la valeur de 1 à 10 lue dans le fichier.
- Le rapport ne contient ni effectif absent de `sorties/`, ni référence absente du protocole, ni donnée individuelle.
