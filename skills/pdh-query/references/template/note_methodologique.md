# Note méthodologique — <titre court de l'indicateur>

**Question** : <question en langage naturel de l'utilisateur>
**Dossier** : `<nom_du_dossier>/` (exécution : `main.R`)
**Finalité** : <dénombrement interne / rapport / diffusion externe / publication>
<secret statistique appliqué (seuil 11) si diffusion externe>

## Protocole

- **Population** : <champ(s) PMSI, années, critère d'inclusion> — `01_inclusion.R`
- **Exclusions** : <dans l'ordre> — `02_exclusion.R`
- **Critère de jugement** : <unité de compte, indicateur> — `03_critere_jugement.R`
- **Stratification** : <année, sexe, classe d'âge…> — `04_covariables.R`

## Définitions et source des codes

<Codes CIM-10 / CCAM retenus, avec la source si issue d'une recherche de
références (Santé publique France, cartographie CNAM, fiche ATIH, publication),
et les amendements de l'utilisateur.>

| Code | Libellé | Source |
|---|---|---|
| <E10–E14> | <Diabète sucré> | <référence> |

## Flowchart d'attrition

<Reporter la sortie de `05_flowchart.R`.>

| Année | Étape | Nombre de séjours | % perdu |
|---|---|---|---|
| | 01 Sejours DP cible | | |
| | 02a hors seances (CMD 28) | | |
| | 02b hors GHM en erreur (90) | | |
| | 02c chainage exploitable | | |

## Limites

<2-3 limites ciblées sur ce protocole précis, parmi : exhaustivité du chaînage
(part de séjours exclus en 02c), année PMSI = année de sortie, séjours à cheval,
évolutions de codage sur la période, années Covid dans une tendance, DP seul
sous-estimant une prévalence, petits effectifs.>

## Pistes de sensibilité

<ex. élargir aux DAS (variante de `01_inclusion.R`), ajouter les champs SMR/HAD,
inclure les séances, codes complets plutôt que troncature à 3 caractères.>
