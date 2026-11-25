# Remplir la fiche de cadrage

Liste exhaustive des champs : `python scripts/fiche.py --champs`.

Un fichier JSON par parcours. Clés absentes ou vides : la case reste vide (`fiche.py` les liste dans `champs_vides`). Un `\n` dans une valeur devient un retour à la ligne.

## Valeurs par famille de champs

| Champs | Valeur |
|---|---|
| `projet_court` | nom court pour le nom de fichier (sinon `projet_intitule`) |
| `parcours_nom` | nom du parcours, aussi utilisé dans le nom de fichier et le titre de la lettre |
| `cb_*` (cases ☐) | `true` coche, `false` ou absent laisse vide |
| `ck_*_oui` / `ck_*_non` (check-list) | `true` sur l'une des deux, l'autre absente |
| `cma_*_cma` / `cma_*_service` | `true` sur le réalisateur ; `cma_*_rem` texte libre |
| `interventions` | liste, une ligne du tableau 1.2.2 par élément |
| `synthese` | total et critère, ex. `4 → GHS plein`, `2 + CP → GHS plein`, `2 → repli SE1 + ACE` |
| `dp`, `das`, `actes_sejour`, `gradation` | proposition suivie de ` (à valider DIM)` |
| `uf_*`, `um_*`, `ghm`, `ghs`, `valo_sejour`, `recettes`, `dim_referent`, `cdg_referent` | vides sauf si le praticien les donne |
| `lettre_liaison` | texte complet de la lettre pré-remplie |

## Une ligne d'intervention

| Clé | Contenu |
|---|---|
| `nom` | intitulé de l'intervention |
| `qualite` | profession et spécialité de l'intervenant |
| `acte` | code CCAM ou NGAP ; pour l'ETP labellisée : `lettre-clé ETP UTEP du programme` |
| `decomptable` | `Oui`, ou `Non – <motif court>` |
| `hdj` | `1` si compte dans le décompte, ou le critère qu'elle apporte : `AC`, `SP`, `CP`, `RH` ; vide sinon |

## Exemple

```json
{
  "projet_intitule": "HDJ bilan troubles cognitifs du sujet âgé",
  "projet_court": "cognitif-age",
  "parcours_nom": "Bilan initial",
  "resp_nom": "Dr Martin Anne",
  "cb_cma_non": true,
  "cb_rh_existantes": true,
  "ck_responsable_oui": true,
  "interventions": [
    {"nom": "Consultation gériatrique", "qualite": "Médecin gériatre", "acte": "", "decomptable": "Oui", "hdj": "1"},
    {"nom": "Bilan neuropsychologique", "qualite": "Neuropsychologue", "acte": "", "decomptable": "Oui", "hdj": "1"},
    {"nom": "Évaluation autonomie", "qualite": "Ergothérapeute", "acte": "", "decomptable": "Oui", "hdj": "1"},
    {"nom": "ECG", "qualite": "IDE", "acte": "DEQP003", "decomptable": "Non – ECG exclu", "hdj": ""}
  ],
  "synthese": "3 → GHS intermédiaire",
  "dp": "<code CIM-10> (à valider DIM)",
  "gradation": "Intermédiaire (à valider DIM)",
  "file_active_annuelle": "300 venues",
  "lettre_liaison": "Motif d'hospitalisation : ...\nInterventions réalisées : ..."
}
```

## Lettre de liaison

Contenu attendu : motif d'hospitalisation, professionnel médical coordonnateur, liste des interventions réalisées (intervenant, nature, acte), éléments justifiant `SP`, `CP` ou `RH` le cas échéant, conclusion et suites. Laisser des `[à compléter]` pour les données propres au patient.
