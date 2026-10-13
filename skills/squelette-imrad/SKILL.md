---
name: squelette-imrad
description: >
  Produit le squelette IMRaD d'un protocole ou d'un article de recherche en
  santé à partir d'une question structurée (PICO), avec la ligne directrice
  EQUATOR. À utiliser quand la question est cadrée.
license: MIT
---

# Squelette IMRaD

Tu aides une personne à passer d'une question de recherche en santé structurée à un squelette IMRaD : pour chaque section de son futur article ou protocole, ce qu'elle devra y mettre. Tu structures, la personne rédige : le livrable est fait de puces courtes, hormis la question en une phrase. Ce qui est connu dans la littérature vient de la personne : tu ne cites aucune étude ni référence et tu ne fais aucune recherche bibliographique.

Réponds dans la langue de la personne : question de validation, gabarit et mentions **À préciser** et **Piste** compris. Cette skill se suffit à elle-même : n'évoque aucune autre skill, même après le livrable.

## Démarche

À toute étape, une entrée qui révèle une recherche qualitative (entretiens, groupes de discussion), une revue systématique ou méta-analyse, ou une recherche hors santé est **hors champ** : nomme le type, dis qu'il est hors champ de cette skill, et arrête-toi là.

### 1. Lecture de la question

L'entrée attendue est une question de recherche structurée, quelle qu'en soit la mise en forme : type d'étude, question en une phrase, grille P, I/E, C, O, T et schéma d'étude, avec ou sans fragilités FINER.

Si l'entrée donne le type d'étude (l'un des cinq de la section **Grille**), chaque case utile de la grille de ce type et le schéma : passe au squelette.

Sinon, écris dans le texte de ton message la tête du gabarit (titre avec le type, question en une phrase, tableau) à partir de ce qui est donné : une case manquante devient **À préciser** ; un type incertain devient le plus probable d'après l'entrée, signalé comme tel. Puis, dans la même réponse, demande à la personne de valider, avec les propositions « Valider » et « Corriger ». La tête du gabarit précède toujours la question : avec l'outil de question, elle est dans le texte du message et l'appel de l'outil vient après. Sur « Corriger » sans précision, demande ce qu'il faut changer par une question ouverte, sans propositions. Intègre chaque correction et présente à nouveau, jusqu'à une validation explicite.

C'est fini quand la question est complète ou validée. Le squelette vient toujours après.

### 2. Squelette IMRaD

Réponds avec le gabarit (section **Gabarit**).

C'est fini quand chaque ligne du gabarit est remplie, signalée **Piste** ou marquée **À préciser**, et que la section À préciser reprend chaque ligne marquée **À préciser**.

## Format des questions

Pour la validation :

- quand un outil de question à choix cliquables est disponible, pose-la avec lui, après la tête du gabarit dans le texte de ton message : un seul choix, « Validation » en en-tête, une option par proposition ; l'outil ajoute de lui-même la réponse libre ;
- sinon, écris-la dans ton message :

```markdown
**Validation** · <question>

1. Valider
2. Corriger

Réponds par un numéro, ou librement.
```

La question ouverte sur la correction à apporter se pose sans propositions.

## Grille

| Type | P | I/E | C | O | T | Schémas courants |
|---|---|---|---|---|---|---|
| Intervention | population | intervention | comparateur | critère de jugement | durée de suivi | essai randomisé, essai non randomisé, avant-après |
| Observationnel analytique | population | exposition | non-exposés ou autre niveau d'exposition | critère de jugement | période ou durée de suivi | cohorte, cas-témoins, transversale |
| Descriptif | population | sans objet | sans objet | ce qui est mesuré : prévalence, incidence, pratique | période | transversale, cohorte |
| Diagnostic | population | test évalué | test de référence | maladie cible | délai entre les deux tests | étude d'exactitude diagnostique |
| Pronostic | population | facteur pronostique ou prédicteurs | sans objet | événement | horizon de prédiction | cohorte |

## Repères pour le squelette

### Par type d'étude

| Type | Ligne directrice de reporting | Biais à anticiper |
|---|---|---|
| Intervention | CONSORT si randomisé, et SPIRIT pour son protocole ; TREND sinon | allocation (confusion si non randomisé), absence d'insu, perdus de vue, contamination entre groupes ; avant-après : évolution temporelle et co-interventions |
| Observationnel analytique | STROBE | sélection, classement de l'exposition ou de l'événement, confusion, causalité inverse en transversal |
| Descriptif | STROBE | représentativité, définition et repérage des cas |
| Diagnostic | STARD | spectre des patients, vérification incomplète par le test de référence, lecture des tests sans insu |
| Pronostic | STROBE pour un facteur pronostique ; TRIPOD pour un modèle de prédiction | perdus de vue, données manquantes, surajustement, absence de validation externe |

Avec STROBE, si les données viennent de bases ou dossiers existants (médico-administratives, registres, dossiers informatisés) : ajoute RECORD.

Enquête par questionnaire, descriptive ou analytique : ligne directrice CROSS, et biais de non-réponse.

Nomme la ligne directrice sans année ni référence : la version en vigueur se trouve sur le site de l'EQUATOR Network.

### Analyse principale selon le type d'étude et la nature de O

Retiens la première ligne vraie.

| Situation | Analyse principale |
|---|---|
| Diagnostic | sensibilité, spécificité, valeurs prédictives, aire sous la courbe ROC |
| Modèle de prédiction | discrimination, calibration, validation interne puis externe |
| Descriptif | proportion ou taux avec intervalle de confiance à 95 % |
| O binaire | comparaison de proportions ; régression logistique pour ajuster (conditionnelle si appariement) |
| O continu | comparaison de moyennes ou de rangs ; régression linéaire pour ajuster |
| O délai jusqu'à un événement | Kaplan-Meier et log-rank ; modèle de Cox pour ajuster |
| O dénombrement ou taux | régression de Poisson ou binomiale négative |

Pour un essai, ajoute à l'analyse principale la population d'analyse : intention de traiter, per protocole.

## Gabarit

Réponds avec exactement cette structure, sans le bloc de code :

```markdown
**Question de recherche** · <type d'étude>

> <question en une phrase>

| P | I/E | C | O | T | Schéma |
|---|---|---|---|---|---|
| <…> | <… ou sans objet> | <… ou sans objet> | <…> | <…> | <…> |

### Fragilités FINER
- Faisable : <fragilité | aucune relevée | À préciser>
- Intéressante : <…>
- Nouvelle : <…>
- Éthique : <…>
- Pertinente : <…>

### Introduction
- État des connaissances à documenter : <ce que la personne doit chercher dans la littérature>
- Lacune : <ce qui reste inconnu et que l'étude vise>
- Objectif principal : <aligné sur la question>
- Hypothèse : <… | sans objet (descriptif)>
- Objectifs secondaires : <…>

### Méthodes
- Schéma : <schéma>
- Cadre et source des données : <lieux, période d'inclusion, source ou mode de recueil>
- Population : <P> · inclusion : <…> · exclusion : <…>
- <Intervention | Exposition | Test évalué | Facteur pronostique | Prédicteurs> : <I/E | sans objet>
- <Comparateur | Test de référence> : <C | sans objet>
- Critère de jugement principal : <O, sa définition, le moment de sa mesure>
- Critères de jugement secondaires : <…>
- Analyse principale : <selon le type d'étude et la nature de O> · ajustements : <facteurs de confusion à discuter | sans objet>
- Nombre de sujets : calcul à faire ; hypothèses à réunir, nommées sans valeur : <…>
- Éthique et réglementaire : avis éthique, consentement ou information des participants, cadre réglementaire à préciser
- Ligne directrice de reporting : <nom(s)>

### Résultats · tableaux et figures attendus
- Diagramme de flux : <étapes de sélection des participants>
- Tableau 1 : caractéristiques de la population <par groupe>
- <tableau ou figure du critère principal : lignes, colonnes, mesure>
- <un tableau ou une figure par critère secondaire ou analyse de sensibilité>

### Discussion
- Limites et biais à anticiper : <biais du type, appliqués à cette étude ; fragilités FINER reçues>
- Comparaison à la littérature : <points à confronter>
- Implications : <pour la pratique | pour la recherche>

### À préciser
- <chaque élément marqué À préciser ci-dessus> | rien
```

- La question et la grille reprennent l'entrée, ou la version validée.
- Le bloc Fragilités FINER n'apparaît que si l'entrée en contenait ; il les reprend telles quelles.
- Une ligne que l'entrée ne couvre pas reçoit une piste tirée de la question, écrite « **Piste** : … ».
- **À préciser** marque un choix que seule la personne peut faire, suivi au besoin de ce qu'il faut décider.
- Les Résultats décrivent la forme de chaque tableau ou figure ; leurs cellules restent vides.
