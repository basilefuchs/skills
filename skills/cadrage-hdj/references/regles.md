# Règles de gradation des prises en charge sans nuitée

Source : instruction DGOS/R1/DSS/1A/2020/52 du 10 septembre 2020, annexes 2 et 4. Socle figé à cette version.

Les critères s'apprécient **pour chaque journée** de prise en charge, que la prise en charge soit unique ou itérative.

## Ordre d'évaluation d'une venue

Appliquer dans l'ordre, s'arrêter au premier niveau atteint.

1. **Sans condition spécifique → GHS** : hospitalisation écourtée (décès, transfert, fugue, sortie contre avis médical, avec moyens déjà mobilisés) ; séance CMD 28 ou prise en charge assimilable (acte ou diagnostic de la CMD 28 codé en DAS) ; soins palliatifs 23Z02T respectant l'arbre décisionnel de l'Assurance Maladie.
2. **Condition commune** à tout ce qui suit : admission dans une structure d'hospitalisation de jour individualisée (art. D. 6124-301-1 CSP), utilisant ses locaux, matériel et personnel. Seule dérogation : les prises en charge de médecine (point 5), qui peuvent se faire dans une autre unité pour raison d'organisation.
3. **Acte classant** (`classant` = vrai dans `actes.py`) → **GHS plein**, quel que soit le groupage. Code de critère : `AC`.
4. **Anesthésie générale ou loco-régionale** → **GHS plein** si : acte non classant acceptant l'activité 4 (`activite_4` = vrai), réalisée ou non ; ou acte non classant + anesthésie complémentaire codée ; ou séjour sans acte CCAM avec AG/ALR. Code de critère : `AC`.
5. **Médecine sans acte classant**, interventions coordonnées par un professionnel médical (médecin, chirurgien-dentiste, sage-femme), tracées dans un CRH ou une lettre de liaison :
   - 3 interventions décomptables → **GHS intermédiaire**
   - 4 ou plus → **GHS plein**
   - `RH`, `SP` ou `CP` présent → **GHS plein**, quel que soit le nombre
6. Sinon → **repli** (voir plus bas).

Cas particuliers :
- Acte associé à un forfait SE (`se` non vide) : pas de GHS en principe, sauf si réalisé sous AG/ALR, au cours d'une prise en charge comportant d'autres interventions, ou chez un patient dont le contexte justifie l'hospitalisation.
- Addictologie : article 11 bis et annexe 9 de l'arrêté du 19 février 2015, programme de soins formalisé ; ni décompte, ni SP/CP recueillis au PMSI. Signaler au praticien que ce cas sort du décompte standard.
- Douleur : voir la section dédiée.

## Décompte des interventions

Une intervention compte si elle est **soit un acte CCAM codé**, **soit réalisée directement auprès du patient** par un professionnel médical, paramédical ou socio-éducatif.

### Actes CCAM (calculé par `actes.py`)

- Deux actes comptent séparément s'ils relèvent de sous-paragraphes différents, ou du même sous-paragraphe avec deux techniques différentes. `decompte_ccam` applique cette règle.
- Un acte de guidage qui prolonge l'acte technique compte avec lui pour une seule technique : à retirer à la main, `actes.py` ne le détecte pas.
- DEQP003 (ECG 12 dérivations) ne compte jamais.

### Professionnels médicaux

- Exclus : intervention hors présence du patient (biologiste, anatomopathologiste au laboratoire) ; professionnel déjà compté via son acte CCAM (radiologue).
- Inclus : pharmacien clinicien en entretien pharmaceutique avec le patient.
- Plusieurs médecins : spécialités ou surspécialités distinctes exigées (qualification ordinale ; DU/DESC pour la surspécialité).
- Un seul médecin qui fait tout (ex. pédiatre) : tous ses actes et interventions comptent.
- Télémédecine, téléexpertise, intervention dans un autre établissement (facturée en PIE) : comptent.

### Paramédicaux et socio-éducatifs

- Comptent, actes NGAP ou non.
- Infirmier(e) : les soins courants (constantes, pansement, perfusion, nursing) comptent pour une intervention. Si la même venue comporte en plus une consultation d'ETP ou de pratique avancée (IPA), cela fait **deux** interventions, même personne ou non.
- Entretien paramédical du PPS en cancérologie : compte.

### Interventions collectives

Une intervention auprès de plusieurs patients en même temps compte pour chacun d'eux.

## Surveillance particulière (`SP`)

Situations, à tracer dans le dossier :
- prélèvement complexe (ex. épreuves dynamiques hormonales, notamment chez l'enfant) ;
- isolement prophylactique ayant mobilisé des moyens supplémentaires ;
- environnement de bloc ou interventionnel, ou asepsie stricte, pour un acte sans activité 4 réalisé sans AG/ALR (ex. EPLF002, EBLA003) ;
- surveillance prolongée pour risque de complication (tests allergologiques, désensibilisation, réintroduction avec risque anaphylactique ; première administration d'une immunothérapie à risque) ;
- séjour sans nuitée après accouchement hors établissement ;
- autre situation, si justifiée dans le dossier.

## Contexte patient (`CP`)

Fragilité ou terrain à risque imposant des précautions que d'autres patients n'auraient pas requises. Situations, à tracer dans le dossier :
1. âge ;
2. handicap — pour le polyhandicap lourd, vérifier les codes CIM-10 avec `contextes.py` ;
3. pathologie psychiatrique ;
4. état grabataire ;
5. antécédents (autre pathologie, traitement, échec ou impossibilité de l'acte en externe) ;
6. précarité sociale ;
7. difficultés de coopération ou incapacité à s'exprimer (ex. sédation pour IRM chez un jeune enfant ou un patient autiste) ;
8. suspicion de maltraitance (mineur, majeur protégé) ou protection d'une femme victime de violences conjugales — l'hospitalisation d'un mineur pour suspicion de maltraitance justifie à elle seule un GHS plein ;
9. prise en charge en urgence ou non programmée (non planifiée dans les 24 h) hors UHCD, d'un patient qui cumule : pathologie évolutive ou diagnostic incertain + surveillance ne pouvant être délivrée qu'en hospitalisation + examens complémentaires ou actes thérapeutiques ;
10. autre situation, si justifiée dans le dossier.

## Réserve hospitalière (`RH`)

Administration d'un produit de la réserve hospitalière (art. R. 5121-82 CSP) → GHS plein. Hors AMM : moratoire sur le contrôle de la facturation en HDJ, mais l'usage reste soumis à l'art. L. 5121-12-1 CSP ; le signaler.

## Douleur

- Acte classant → point 3.
- Infiltrations rachidiennes, blocs facettaires, rhizolyse : externe par défaut ; GHS plein si `CP`.
- Radiologie interventionnelle lourde (blocs neurolytiques, vertébroplastie, cimentoplastie…) : GHS plein (acte classant ou `SP` en salle interventionnelle).
- Analgésie loco-régionale : volumes ou doses conséquents → GHS plein (`SP`) ; autres blocs : externe, sauf pathologie ou état clinique justifiant l'hospitalisation.
- Analgésie périmédullaire (pompe intrathécale, péridurale) : GHS plein (`SP`).
- Mise en place d'une PCA : GHS plein (`SP`).
- Capsaïcine 8 % patch : GHS plein (`RH`).
- Blood patch : GHS plein (`SP`).
- Bilan de douleur chronique pluriprofessionnel : décompte, 3 → intermédiaire, 4+ → plein.
- Douleurs induites par les soins chez l'enfant : décompte ; jeune enfant ou enfant handicapé → GHS plein (`CP`).

## Repli quand la venue n'atteint pas le seuil

Ces forfaits ne se cumulent pas entre eux (ATU, FFM, SE, APE) et excluent le GHS pour la même venue. Les AMI ne sont facturables en sus d'aucun.

| Situation | Facturation |
|---|---|
| Consultations, actes sans environnement particulier | ACE (actes et consultations externes) |
| Acte inscrit sur une liste SE (`se` non vide) | Forfait SE correspondant + ACE ; 2 actes de listes différentes → 2 SE, le moins cher minoré de 50 % |
| Soin non programmé avec petit matériel (`ffm` non vide), sans AG/ALR, établissement sans urgences autorisées | FFM + ACE |
| Administration d'un produit ou d'une spécialité de la liste en sus, sans hospitalisation | APE + produit + ACE |

## Traçabilité exigée

Le dossier patient doit mentionner chaque intervention et chaque acte CCAM, ainsi que les éléments justifiant `SP`, `CP` ou `RH`. Le CRH ou la lettre de liaison est rédigé par le professionnel médical coordonnateur.
