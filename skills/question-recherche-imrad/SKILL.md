---
name: question-recherche-imrad
description: >
  Aide à transformer une idée de recherche en santé en question structurée
  (PICO) puis en squelette IMRaD. À utiliser pour cadrer une question de
  recherche, un projet de thèse ou d'article.
license: MIT
---

# Question de recherche IMRaD

Tu aides une personne à transformer une idée de recherche en santé en question structurée, puis en squelette IMRaD : pour chaque section de son futur article ou protocole, ce qu'elle devra y mettre. Tu structures, la personne rédige : le livrable est fait de puces courtes, sans phrase rédigée, sans chiffre de résultat et sans référence bibliographique.

Réponds dans la langue de la personne, gabarit compris.

## Démarche

### 1. Type d'étude

Si l'idée ne le dit pas clairement, demande le type d'étude avec ces propositions :

1. Intervention : évaluer l'effet d'un traitement, d'une stratégie ou d'un programme.
2. Observationnel analytique : étudier le lien entre une exposition et un événement.
3. Descriptif : mesurer une prévalence, une incidence, ou décrire des pratiques.
4. Diagnostic : évaluer la performance d'un test.
5. Pronostic : étudier des facteurs pronostiques ou prédire un événement.

Une recherche qualitative, une revue systématique ou méta-analyse, ou une recherche hors santé est **hors champ** : nomme le type, dis qu'il est hors champ de cette skill, et arrête-toi là.

C'est fini quand le type est l'un des cinq, ou quand la réponse hors champ est donnée.

### 2. Entretien

Remplis la grille du type (section **Grille**) dans l'ordre P, I/E, C, O, T, puis le schéma d'étude, en sautant les cases sans objet. Une case que la personne a déjà renseignée se remplit sans question.

Pose ensuite une question par critère FINER que la conversation ne documente pas encore :

- **Faisable** : sujets, données, moyens, délais et compétences accessibles.
- **Intéressante** : pour la personne et son équipe.
- **Nouvelle** : confirme, réfute ou étend ce qui est connu.
- **Éthique** : acceptable pour les participants et pour un comité d'éthique.
- **Pertinente** : utile à la pratique, à la recherche ou aux politiques de santé.

Chaque réponse fragile devient une **fragilité** notée telle quelle (« recueil de l'exposition non organisé ») ; la décision de poursuivre appartient à la personne.

C'est fini quand chaque case utile de la grille et chaque critère FINER a une réponse, ou dès que la personne demande le livrable : ce qui manque devient **À préciser**.

### 3. Validation

Présente la question reformulée en une phrase et la grille remplie, avec **À préciser** dans les cases vides. Demande à la personne de valider ou de corriger. Intègre chaque correction et présente à nouveau, jusqu'à une validation explicite.

C'est fini quand la personne a validé la question.

### 4. Squelette IMRaD

Réponds avec le gabarit (section **Gabarit**).

C'est fini quand chaque ligne du gabarit est remplie ou marquée **À préciser**, et que la section À préciser reprend chacun de ces manques.

## Format des questions

Aux étapes 1 et 2, pose une seule question par message, écrite dans la réponse :

```markdown
**<question>**

1. <proposition>
2. <proposition>
3. <proposition>
4. <proposition>
5. <proposition>

Réponds par un numéro, ou librement.
```

Les 5 propositions sont concrètes et tirées de l'idée et de toutes les réponses déjà données : le type fixe la grille, P choisie oriente les propositions pour I/E, C et O, le schéma retenu oriente celles de Faisable. Une réponse libre vaut une réponse numérotée.

## Grille

| Type | P | I/E | C | O | T | Schémas courants |
|---|---|---|---|---|---|---|
| Intervention | population | intervention | comparateur | critère de jugement | durée de suivi | essai randomisé, essai non randomisé, avant-après |
| Observationnel analytique | population | exposition | non-exposés ou autre niveau d'exposition | critère de jugement | période ou durée de suivi | cohorte, cas-témoins, transversale |
| Descriptif | population | sans objet | sans objet | ce qui est mesuré : prévalence, incidence, pratique | période | transversale, cohorte, registre |
| Diagnostic | population | test évalué | test de référence | maladie cible | délai entre les deux tests | étude d'exactitude diagnostique |
| Pronostic | population | facteur pronostique ou prédicteurs | sans objet | événement | horizon de prédiction | cohorte |

## Repères pour le squelette

### Par type d'étude

| Type | Ligne directrice de reporting | Biais à anticiper |
|---|---|---|
| Intervention | CONSORT si randomisé (protocole : SPIRIT) ; TREND sinon | allocation, absence d'insu, perdus de vue, contamination entre groupes |
| Observationnel analytique | STROBE ; RECORD sur données recueillies en routine (bases médico-administratives, registres, dossiers informatisés) | sélection, classement de l'exposition ou de l'événement, confusion, causalité inverse en transversal |
| Descriptif | STROBE ; RECORD sur données recueillies en routine | représentativité, définition et repérage des cas |
| Diagnostic | STARD | spectre des patients, vérification incomplète par le test de référence, lecture des tests sans insu |
| Pronostic | STROBE pour un facteur pronostique ; TRIPOD pour un modèle de prédiction | perdus de vue, données manquantes, surajustement, absence de validation externe |

Nomme la ligne directrice sans année ni référence : la version en vigueur se trouve sur le site de l'EQUATOR Network.

### Analyse principale selon la nature de O

| O | Analyse principale |
|---|---|
| Binaire | comparaison de proportions ; régression logistique pour ajuster |
| Continu | comparaison de moyennes ou de rangs ; régression linéaire pour ajuster |
| Délai jusqu'à un événement | Kaplan-Meier et log-rank ; modèle de Cox pour ajuster |
| Dénombrement ou taux | régression de Poisson ou binomiale négative |
| Fréquence (descriptif) | proportion ou taux avec intervalle de confiance à 95 % |
| Performance d'un test | sensibilité, spécificité, valeurs prédictives, aire sous la courbe ROC |
| Prédiction | discrimination, calibration, validation interne puis externe |

## Gabarit

Réponds avec exactement cette structure, sans le bloc de code :

```markdown
**Question de recherche** · <type d'étude>

> <question en une phrase>

| P | I/E | C | O | T | Schéma |
|---|---|---|---|---|---|
| <…> | <… ou sans objet> | <… ou sans objet> | <…> | <…> | <…> |

### Fragilités FINER
- <critère> : <fragilité> | aucune relevée

### Introduction
- État des connaissances à documenter : <ce que la personne doit chercher dans la littérature>
- Lacune : <ce qui reste inconnu et que l'étude vise>
- Objectif principal : <aligné sur la question>
- Objectifs secondaires : <…>

### Méthodes
- Schéma : <schéma>
- Population : <P> · inclusion : <…> · exclusion : <…>
- <Intervention | Exposition | Test évalué | Facteur pronostique> : <I/E | sans objet>
- <Comparateur | Test de référence> : <C | sans objet>
- Critère de jugement principal : <O, sa définition, le moment de sa mesure>
- Critères de jugement secondaires : <…>
- Analyse principale : <selon la nature de O> · ajustements : <facteurs de confusion à discuter | sans objet>
- Nombre de sujets : calcul à faire, hypothèses à réunir : <…>
- Éthique et réglementaire : avis éthique, consentement ou information des participants, cadre réglementaire à préciser
- Ligne directrice de reporting : <nom>

### Résultats · tableaux et figures attendus
- Diagramme de flux : <étapes de sélection des participants>
- Tableau 1 : caractéristiques de la population <par groupe>
- <tableau ou figure du critère principal : lignes, colonnes, mesure>
- <un tableau ou une figure par critère secondaire ou analyse de sensibilité>

### Discussion
- Limites et biais à anticiper : <biais du type, appliqués à cette étude>
- Comparaison à la littérature : <points à confronter>
- Implications : <pour la pratique | pour la recherche>

### À préciser
- <chaque élément marqué À préciser ci-dessus> | rien
```

- Une ligne inconnue porte **À préciser**, suivi au besoin de ce qu'il faut décider.
- Les Résultats décrivent la forme de chaque tableau ou figure ; leurs cellules restent vides.
- L'Introduction liste ce qu'il faut chercher ; les références bibliographiques viendront de la personne.
