# Note méthodologique — <titre court de l'indicateur>

**Question** : <question en langage naturel de l'utilisateur>
**Dossier** : `<nom_du_dossier>/` (exécution : `main.R`)
**Finalité** : <dénombrement interne / rapport / diffusion externe / publication>
<secret statistique appliqué (seuil 11) si diffusion externe>

## Protocole

- **Sources SNDS** : <PMSI MCO / DCIR / CAUSE_DECES ; si plusieurs : intersection
  ou union, et méthode de chaînage retenue (`NIR_ANO_17` = `BEN_NIR_PSA`,
  individu `IR_BEN_R.BEN_IDT_ANO`)> — `01_inclusion.R`
- **Population** : <champ(s), années, critère d'inclusion> — `01_inclusion.R`
- **Exclusions** : <dans l'ordre> — `02_exclusion.R`
- **Critère de jugement** : <unité de compte, indicateur> — `03_critere_jugement.R`
- **Stratification** : <année, sexe, classe d'âge…> — `04_covariables.R`
- **Dictionnaire** : schema-snds, commit <SOURCE.txt> ; chaque table et variable
  vérifiée pour chaque millésime demandé.

## Définitions et source des codes

<Codes CIM-10 / CCAM / ATC retenus, avec la source si issue d'une recherche de
références (Santé publique France, cartographie CNAM, HAS, projet de
l'écosystème SNDS, publication), et les amendements de l'utilisateur.>

| Code | Libellé | Source |
|---|---|---|
| <E10–E14> | <Diabète sucré> | <référence> |

## Flowchart d'attrition

<Reporter la sortie de `05_flowchart.R`.>

| Année | Étape | Nombre de séjours | Exclus | % perdu |
|---|---|---|---|---|
| | 01 Sejours DP cible | | | |
| | 02a chainage exploitable | | | |
| | 02b hors prestations inter-etab. | | | |
| | 02c hors GHM en erreur (90) | | | |

## Limites

<2-3 limites ciblées sur ce protocole précis, parmi : fiabilité du chaînage
inter-source le cas échéant (part de séjours exclus en 02a, appariement
incomplet des décès), année PMSI = année de sortie, évolutions de codage sur
la période, alimentation effective des variables DCIR, dates PMSI absentes
avant 2009, réforme SMR 2023, exhaustivité du statut vital, années Covid dans
une tendance, DP seul sous-estimant une prévalence, petits effectifs.>

## Pistes de sensibilité

<ex. élargir aux DAS (variante de `01_inclusion.R`), croiser avec le DCIR
(pharmacie, actes en ville), inclure les séances, codes complets plutôt que
troncature à 3 caractères, marge de flux DCIR plus large.>

## Confidentialité

Aucune donnée individuelle n'a quitté l'environnement du Health Data Hub :
les tables intermédiaires sont des tables de session Oracle, et aucun fichier
local ne contient d'identifiant, de date ou de localisation individuelle. Les
seules sorties sont des agrégats, <soumis au seuil de 11 / sans secret
statistique (dénombrement interne)>.
