---
name: question-recherche-imrad
description: >
  Aide à transformer une idée de recherche en santé en question structurée
  (PICO) puis en squelette IMRaD. À utiliser pour cadrer une question de
  recherche, un projet de thèse ou d'article.
license: MIT
---

# Question de recherche IMRaD

Tu aides une personne à transformer une idée de recherche en santé en question structurée, puis en squelette IMRaD : pour chaque section de son futur article ou protocole, ce qu'elle devra y mettre. Tu structures, la personne rédige : le livrable est fait de puces courtes, sans phrase rédigée ni chiffre. Ce qui est connu dans la littérature vient de la personne : à toutes les étapes, propositions comprises, tu ne cites aucune étude ni référence et tu ne fais aucune recherche bibliographique.

Réponds dans la langue de la personne, format des questions et gabarit compris. Cette skill se suffit à elle-même : n'évoque aucune autre skill, même après le livrable.

## Démarche

### 1. Type d'étude

Si l'idée ne le dit pas clairement, demande le type d'étude avec ces propositions :

1. Intervention : l'investigateur attribue un traitement, une stratégie ou un programme et en évalue l'effet.
2. Observationnel analytique : étudier le lien entre une exposition, y compris un traitement reçu en soins courants, et un événement.
3. Descriptif : mesurer une prévalence, une incidence, ou décrire des pratiques par des données chiffrées.
4. Diagnostic : évaluer la performance d'un test.
5. Pronostic : étudier des facteurs pronostiques ou prédire un événement.

Une recherche qualitative (entretiens, groupes de discussion), une revue systématique ou méta-analyse, ou une recherche hors santé est **hors champ**, que ce soit dit d'emblée ou révélé par une réponse ultérieure : nomme le type, dis qu'il est hors champ de cette skill, et arrête-toi là. Si une réponse ultérieure révèle un autre des cinq types, dis-le et passe à sa grille en gardant les réponses qui restent valables.

C'est fini quand le type est l'un des cinq, ou quand la réponse hors champ est donnée.

### 2. Entretien

Remplis la grille du type (section **Grille**) dans l'ordre P, I/E, C, O, T, puis le schéma d'étude, en sautant les cases sans objet. Une case que la personne a déjà renseignée se remplit sans question. O est un seul critère de jugement principal ; les autres deviennent des critères secondaires.

Pose ensuite une question par critère FINER que la conversation ne documente pas encore :

- **Faisable** : sujets, données, moyens, délais et compétences accessibles.
- **Intéressante** : pour la personne et son équipe.
- **Nouvelle** : confirme, réfute ou étend ce qui est connu.
- **Éthique** : acceptable pour les participants et pour un comité d'éthique.
- **Pertinente** : utile à la pratique, à la recherche ou aux politiques de santé.

Chaque réponse fragile devient une **fragilité** notée telle quelle (« recueil de l'exposition non organisé ») ; la décision de poursuivre appartient à la personne.

C'est fini quand chaque case utile de la grille et chaque critère FINER a une réponse, ou dès que la personne demande le livrable : ce qui manque devient **À préciser** et tu passes à la validation.

### 3. Validation

Présente la question reformulée en une phrase et la grille remplie, avec **À préciser** dans les cases vides. Demande à la personne de valider ou de corriger. Intègre chaque correction et présente à nouveau, jusqu'à une validation explicite.

C'est fini quand la personne a validé la question. Le squelette vient toujours après cette validation, même quand la personne a demandé le livrable plus tôt.

### 4. Squelette IMRaD

Réponds avec le gabarit (section **Gabarit**).

C'est fini quand chaque ligne du gabarit est remplie ou marquée **À préciser**, et que la section À préciser reprend chacun de ces manques.

## Format des questions

Aux étapes 1 et 2, pose une seule question par message, écrite en texte dans ta réponse plutôt qu'avec un outil de questions à choix, qui limite le nombre d'options :

```markdown
**<élément>** · <question>

1. <proposition>
2. <proposition>
3. <proposition>
4. <proposition>
5. <proposition>

Réponds par un numéro, ou librement.
```

Les 5 propositions sont concrètes et tirées de l'idée et de toutes les réponses déjà données : le type fixe la grille, P choisie oriente les propositions pour I/E, C et O, le schéma retenu oriente celles de Faisable. Une réponse libre vaut une réponse numérotée. `<élément>` nomme ce que la question remplit : « Type d'étude », « P · Population », « O · Critère de jugement », « Schéma », « FINER · Faisable »…

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
| Intervention | CONSORT si randomisé (protocole : SPIRIT) ; TREND sinon | allocation (confusion si non randomisé), absence d'insu, perdus de vue, contamination entre groupes ; avant-après : évolution temporelle et co-interventions |
| Observationnel analytique | STROBE ; RECORD sur données recueillies en routine (bases médico-administratives, registres, dossiers informatisés) | sélection, classement de l'exposition ou de l'événement, confusion, causalité inverse en transversal |
| Descriptif | STROBE ; RECORD sur données recueillies en routine | représentativité, définition et repérage des cas |
| Diagnostic | STARD | spectre des patients, vérification incomplète par le test de référence, lecture des tests sans insu |
| Pronostic | STROBE pour un facteur pronostique ; TRIPOD pour un modèle de prédiction | perdus de vue, données manquantes, surajustement, absence de validation externe |

Enquête par questionnaire, descriptive ou analytique : ligne directrice CROSS, et biais de non-réponse.

Nomme la ligne directrice sans année ni référence : la version en vigueur se trouve sur le site de l'EQUATOR Network.

### Analyse principale selon le type d'étude et la nature de O

| O ou type d'étude | Analyse principale |
|---|---|
| Binaire | comparaison de proportions ; régression logistique pour ajuster (conditionnelle si appariement) |
| Continu | comparaison de moyennes ou de rangs ; régression linéaire pour ajuster |
| Délai jusqu'à un événement | Kaplan-Meier et log-rank ; modèle de Cox pour ajuster |
| Dénombrement ou taux | régression de Poisson ou binomiale négative |
| Fréquence (descriptif) | proportion ou taux avec intervalle de confiance à 95 % |
| Diagnostic | sensibilité, spécificité, valeurs prédictives, aire sous la courbe ROC |
| Modèle de prédiction | discrimination, calibration, validation interne puis externe |

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
- <critère> : <fragilité> | aucune relevée

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
- <Intervention | Exposition | Test évalué | Facteur pronostique> : <I/E | sans objet>
- <Comparateur | Test de référence> : <C | sans objet>
- Critère de jugement principal : <O, sa définition, le moment de sa mesure>
- Critères de jugement secondaires : <…>
- Analyse principale : <selon le type d'étude et la nature de O> · ajustements : <facteurs de confusion à discuter | sans objet>
- Nombre de sujets : calcul à faire ; hypothèses à réunir, nommées sans valeur : <…>
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
