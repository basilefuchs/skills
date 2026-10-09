---
name: situation-clinique-mco
description: >
  Classe un séjour MCO dans sa situation clinique PMSI (guide méthodologique
  2026, chapitre VI) et argumente le DP et le DR. À utiliser quand on fournit
  un CRH ou une lettre de liaison à coder.
license: MIT
---

# Situation clinique MCO

Tu reçois le compte rendu d’un séjour MCO. Tu détermines la situation clinique du RUM de l’UM émettrice, la règle du guide méthodologique qui s’applique, puis le DP et le DR qui en découlent, en montrant chaque étape du raisonnement.

Ton référentiel est la section **Référentiel** : chapitre VI du Guide méthodologique MCO 2026 (version définitive, applicable au 1er janvier 2026) et définitions du DP et du DR de son chapitre IV, cités mot pour mot. Les passages marqués « Convention de la skill » sont des arbitrages propres à cette skill.

## Périmètre

- Entrée : un CRH ou une lettre de liaison décrivant un seul séjour MCO.
- Unité d’analyse : le RUM de l’UM émettrice du CR.
- Présupposé : les conditions d’admission en hospitalisation (arrêté « prestations », instruction gradation) sont réunies. Seule l’issue « aucun RUM » de 1.6 les met en cause.
- Sortie : situation, section, règle, DP, DR, et les diagnostics associés que la règle appliquée désigne. Code CIM-10 seulement quand le guide l’impose ; sinon libellé en clair.

## Démarche

1. Lis tout le CR, y compris les résultats qu’il rapporte (anatomopathologie, imagerie, biologie) : le DP s’énonce en connaissance de l’ensemble des informations du séjour.
2. Parcours l’arbre dans l’ordre, de E0 à E3, et arrête la descente à la première issue atteinte. Fais ensuite les contrôles de E4.
3. À chaque nœud parcouru, réponds **oui**, **non** ou **non documenté**, avec l’extrait du CR qui fonde la réponse, cité mot pour mot entre guillemets. Une réponse sans extrait citable vaut **non documenté**.
4. Sur un nœud non documenté, prends la branche par défaut quand l’arbre en indique une, sinon la plus probable d’après le CR. La conclusion devient **provisoire** : note dans Incertitudes l’autre branche, la conclusion qu’elle donnerait et l’information du dossier qui ferait basculer.
5. Décisions réservées par le guide : le statut cancer ou antécédent de cancer (médecin qui dispense les soins), le caractère esthétique, réparateur ou de confort d’une intervention (médecin qui l’effectue, en cohérence avec la prise en charge AMO), la réalité d’une poussée aiguë (à étayer dans le dossier). Reprends ce que le CR énonce ; s’il ne tranche pas, le nœud est non documenté. En M2, liste les ex aequo sans choisir.
6. Applique la règle atteinte telle que le Référentiel la cite. DR seulement quand le DP est un code Z, selon la définition du DR. Diagnostics associés seulement quand la règle les désigne. Quand une règle a plusieurs points, cite le point appliqué.
7. Quand la suite relève d’un autre chapitre du guide (accouchement non normal, emploi détaillé des codes Z au chapitre V, séances au chapitre VII…), écris « DP selon chapitre X » à la place du DP.
8. Rédige la réponse avec le gabarit.

C’est fini quand une issue est atteinte, que chaque nœud parcouru porte un extrait du CR ou la mention non documenté, et que l’énoncé de la règle appliquée est cité mot pour mot.

## Arbre de décision

### E0 · Recevabilité

- Le document est-il un CRH ou une lettre de liaison d’un séjour d’hospitalisation MCO ? Non → **hors champ** : la réponse s’arrête à la recevabilité.
- Le CR décrit-il plusieurs UM ? Oui → alerte ; classe pour l’UM émettrice du CR.

### E1 · Prise en charge prévue non réalisée (1.6)

Le patient était-il admis pour une prise en charge prévue à l’avance qui n’a pas été réalisée ? Non → E2. Oui :

- la non-réalisation ne justifie pas d’hospitalisation (lecture d’un examen et explication, panne, plateau technique indisponible) → **aucun RUM** ;
- l’affection cause de la contre-indication a nécessité une prise en charge diagnostique ou thérapeutique → DP : cette affection, ou sa symptomatologie si la cause n’est pas trouvée ; diagnostic associé : Z53 ;
- le motif de non-réalisation n’a justifié qu’une surveillance, sans affection mise en évidence → DP : Z53.–.

### E2 · Motifs à issue imposée

Si le motif d’admission figure dans cette table, retiens la première ligne qui correspond et applique sa règle. Sinon → E3.

| Motif d’admission | Règle | DP imposé |
|---|---|---|
| Enregistrement d’EEG de longue durée | D3 | Z04.800 |
| Enregistrement polysomnographique | D3 | Z04.801 |
| Tests allergologiques | D3 | Z01.5 |
| Séjour de bilan préopératoire ou préinterventionnel | D3 | Z04.802 |
| Curiethérapie ou irradiation en dose unique | T10 | Z51.01 |
| Injection unique de fer pour carence martiale | T10 | Z51.2 |
| Traitement répétitif : dialyse, chimiothérapie, radiothérapie, transfusion, aphérèse, oxygénothérapie hyperbare, fer IV, autre traitement à administrations répétées | T1 | code Z adéquat (Z49.1, catégorie Z51) |
| Soins palliatifs, définition respectée | T11 | Z51.5 |
| Prise en charge spécifiquement algologique d’une douleur chronique rebelle | T2 | R52.10 ou R52.18 |
| Évacuation d’ascite | T2 | R18 |
| Évacuation d’épanchement pleural | T2 | J90, J91 ou J94.– |
| Injection de toxine botulique | T2 | l’affection neurologique |
| Chirurgie esthétique non prise en charge par l’AMO | T4 | Z41.0 ou Z41.1 |
| Chirurgie plastique réparatrice prise en charge par l’AMO | T5 | chapitres I à XIX ou catégorie Z42 |
| Intervention de confort non prise en charge par l’AMO | T6 | Z41.80 |
| Soins de stomie, de prothèse ou d’autre appareil | T7 | catégories Z43 à Z47, Z49.0 |
| Intervention prophylactique | T15 | catégorie Z40 |
| Accouchement normal (accouchement non normal : hors chapitre VI) | T12 | O80.0 |
| Nouveau-né séjournant en maternité avec sa mère | T13 | catégorie Z38 |
| Interruption volontaire de grossesse | 1.2.3 5° | catégorie O04 |
| Interruption médicale de grossesse | 1.2.3 6° | catégorie O04 avant 22 SA ; cause fœtale ou maternelle ensuite |
| Post-partum après transfert depuis l’établissement de naissance, sans complication | S4 | mère Z39.08 ; nouveau-né Z76.2 |
| Diabète : rupture de la prise en charge selon les critères de 1.2.3 2° | 1.2.3 2° | le diabète |

### E3 · Motif d’admission dans l’UM

- **A, par défaut** (convention de la skill) : une symptomatologie ou une suspicion à explorer, y compris chez un patient atteint d’une maladie chronique connue ; ou le bilan initial d’extension d’un cancer → branche DIAGNOSTIC.
- **B**, seulement si le CR dit explicitement que le diagnostic était posé avant l’entrée dans l’UM (ville, SMUR, urgences, UHCD, autre UM ou établissement) et que l’admission vise son traitement → branche TRAITEMENT.
- **C** : le suivi d’une affection connue, antérieurement diagnostiquée (« bilan » de surveillance, surveillance après un traitement fait dans un autre établissement) → branche SURVEILLANCE.

Le mot « bilan » n’oriente pas : qualifie son but (1.3.4).

### Branche DIAGNOSTIC (1.1)

Retiens la première ligne vraie.

1. Bilan initial d’extension d’un cancer qui vient d’être diagnostiqué → **D9**.
2. Patient atteint d’une maladie chronique ou de longue durée connue, et le séjour conclut à :
   - une poussée aiguë étayée dans le dossier → la CIM-10 a-t-elle une rubrique propre à l’état aigu ? Oui → **D6** ; non → **D5** ;
   - une complication de la maladie ou de son traitement → **D7** ;
   - une affection ou une lésion intercurrente, indépendante de la maladie → **D8** ;
   - une évolution naturelle de la maladie (tumeur, anévrysme, gradient…) → branche SURVEILLANCE ;
   - aucune de ces conclusions → ligne 3.
3. Affection causale diagnostiquée au cours du séjour → **D1**.
4. Aucun diagnostic étiologique :
   - séjour programmé pour un examen diagnostique motivé par un antécédent, un facteur de risque ou un signe → **D4** ;
   - sinon → **D2**.

### Branche TRAITEMENT (1.2)

Le traitement répétitif est traité en E2. Retiens la première ligne vraie.

1. Reprise ou deuxième temps d’un traitement unique, décidé sur les examens per- ou postinterventionnels du premier → **T14** (chirurgical) ou **T8** (interventionnel).
2. Traitement chirurgical → **T3**.
3. Traitement interventionnel : voie endoscopique ou endovasculaire, imagerie interventionnelle → **T8**.
4. Première administration d’un traitement médicamenteux au long cours, lors d’un séjour distinct de celui du diagnostic → **1.2.3 1°**.
5. Traitement médical → **T9**.

### Branche SURVEILLANCE (1.3)

1. Une affection nouvelle, liée à la maladie surveillée et respectant la définition du DP, a-t-elle été découverte ?
   - Oui → s’agit-il de la récidive d’un cancer remplissant les conditions de SD2 ? Oui → **SD2** ; non → **SD1**.
   - Non → ligne 2. Une affection fortuite sans rapport, une adaptation du traitement ou une évolution naturelle laissent la surveillance négative.
2. Patient transplanté → **S2** ; porteur d’un implant ou d’une greffe cardiovasculaire de la catégorie Z95 → **S3** ; sinon → **S1**.

### E4 · Contrôles finaux

- Plusieurs problèmes de santé ont-ils chacun motivé l’admission ? Oui → **M1** ; prises en charge d’importance comparable → **M2**.
- Si le DP retenu est une maladie chronique ou de longue durée, vérifie qu’il relève d’une des circonstances de 1.4 ; sinon reprends l’arbre.

## Gabarit de réponse

Réponds avec exactement cette structure, sans le bloc de code :

```markdown
**Situation clinique MCO** · Référentiel : Guide méthodologique MCO 2026 (version définitive)

### 1. Recevabilité
- Document : <CRH | lettre de liaison>
- UM émettrice : <UM>
- Alertes : <aucune | plusieurs UM : … | …>

### 2. Cheminement
- **E1** · Prise en charge prévue non réalisée ? → <oui | non | non documenté> · « <extrait du CR> »
- **<nœud>** · <question du nœud> → <réponse> · « <extrait du CR> »
- <un nœud parcouru par ligne, dans l’ordre du parcours>

### 3. Conclusion · <définitive | provisoire>
- Situation : <diagnostic | traitement | surveillance négative | surveillance positive | prise en charge prévue non réalisée>
- Section : <numéro de section du guide>
- Règle : <identifiant> · « <énoncé de la règle, mot pour mot> »
- DP : <libellé> <(code, s’il est imposé) | DP selon chapitre X>
- DR : <libellé | aucun>
- Diagnostics associés désignés par la règle : <libellé (DA | DAS) | aucun>

### 4. Incertitudes
- <information manquante ou décision réservée> → <conclusion alternative> | aucune
```

- Hors champ : seule la section 1, avec le motif.
- Aucun RUM (1.6) : la section 3 donne « Issue : aucun RUM » à la place du DP, du DR et des diagnostics associés.
- M2 : la ligne DP liste les ex aequo et précise « choix laissé à l’établissement ».
- La situation et la section se lisent dans l’en-tête de la règle appliquée.

## Référentiel

Extraits cités mot pour mot du Guide méthodologique MCO 2026. Chaque règle porte en en-tête son identifiant, sa situation et sa section. L’énoncé à citer dans la conclusion est en citation ; suivent les précisions et les exemples du guide.

### Définitions (chapitre IV)

#### DP · chapitre IV, 1.1

> Le diagnostic principal (DP) du RUM est le problème de santé qui a motivé l’admission du patient dans l’unité médicale (UM), pris en charge pendant le séjour et déterminé à la sortie de celle-ci conformément au guide des situations cliniques chapitre 0 [sic : chapitre VI]. Il résulte de cette définition qu’un problème de santé inexistant à l’admission ou étranger au motif de celle-ci, et apparu ou découvert au cours du séjour dans l’UM, ne peut jamais être le DP.

- « Le DP peut être : une maladie, un syndrome, un symptôme, une lésion traumatique ou une intoxication classés dans les chapitres I à XIX voire XXII de la CIM–10 ; ou l’une des entités classées dans le chapitre XXI Facteurs influant sur l’état de santé et motifs de recours aux services de santé (« codes Z »). En revanche, l’emploi du chapitre XX Causes externes de morbidité et de mortalité (codes commençant par les lettres V, W, X et Y) n’est pas autorisé pour le codage du DP. »
- « Le DP est déterminé à la fin du séjour du patient dans l’unité médicale, conformément au guide des situations cliniques du chapitre VI. Il est énoncé en connaissance de l’ensemble des informations médicales le concernant, y compris les résultats d’examens effectués pendant le séjour qui parviendraient postérieurement à la sortie (anatomopathologie, virologie...). »

#### DR · chapitre IV, 1.2

> Le diagnostic relié (DR) a pour rôle, en association avec le DP, de rendre compte de la prise en charge du patient lorsque celui-ci n’y suffit pas en termes médicoéconomiques. Sa détermination repose sur trois principes : il n’y a lieu de mentionner un DR que lorsque le DP est codé avec le chapitre XXI de la CIM–10 ; le DR est une maladie chronique ou de longue durée ou un état permanent, présent au moment du séjour objet du résumé ; le DR répond à la question : « pour quelle maladie ou état la prise en charge enregistrée comme DP a-t-elle été effectuée ? ».

- « [L]e fait qu’un DR ne doive être mentionné que lorsque le DP est un code Z ne signifie pas qu’un DR soit obligatoire chaque fois que le DP est un code Z. »
- « Une maladie justifiant des soins palliatifs entre dans ce cadre. Une séquelle — c’est-à-dire un code intitulé « Séquelles de... » dans la CIM–10 […] — peut aussi être codée comme DR à partir du 1er mars 2013. À l’exception d’une hémopathie maligne, le DR ne peut pas être une affection aigüe. »
- « Seule une maladie chronique en cours (« active ») au moment de l’hospitalisation, un état permanent ou une maladie justifiant des soins palliatifs peut être mentionné comme DR. En conséquence, au terme d’un séjour conclu par la non-confirmation d’une affection suspectée, celle-ci ne peut pas être codée comme DR. »
- « Par « état permanent » on entend : certaines entités classées dans le chapitre XXI de la CIM–10, telles un antécédent personnel ou familial (catégories Z80 et suivantes), un état postopératoire (stomie, présence d’implant ou de greffe, absence acquise d’un membre ou d’un organe…) ; une séquelle : code de la CIM–10 intitulé « Séquelles de... » ; éventuellement d’exceptionnels symptômes sans diagnostic étiologique (chapitre XVIII, codes « R ») : ronflement, troubles de la sensibilité cutanée, amnésie… »
- « Le DR est l’affection motivant la prise en charge indiquée par le DP. »

### 1.1 · Hospitalisation pour diagnostic

« La situation est celle d’un patient hospitalisé en raison d’une symptomatologie, pour un diagnostic étiologique. Le mot symptomatologie inclut les signes cliniques et les résultats anormaux d’examens complémentaires. Que le diagnostic s’accompagne ou non d’un traitement au cours du séjour, la règle est la même. »

#### D1 · Affection causale diagnostiquée — diagnostic · 1.1.1

> Lorsque le séjour a permis le diagnostic de l’affection causale, elle est le DP.

- « Dans cette situation, le codage du DP utilise en général les chapitres I à XVII et XIX (voire XXII) de la CIM–10. Il ne fait pas appel aux « codes Z », il ne doit donc pas être mentionné de DR dans le RUM. »
- Mise en route du traitement (1.4) : « situation de diagnostic (1.1.1) lorsque la mise en route accompagne le diagnostic initial […] ; la maladie diagnostiquée et dont le traitement est mis en route est le DP (il n’y a pas de DR) ».
- Complication révélatrice d’une maladie méconnue : voir D7.
- Exemples : « hospitalisation en raison d’une confusion ; découverte d’une tumeur cérébrale ; DP : tumeur cérébrale » ; « hospitalisation en raison de douleurs thoraciques ; diagnostic d’angine de poitrine ; DP : angine de poitrine » ; « hospitalisation en raison d’une anémie ou pour occlusion intestinale ; découverte d’un cancer colique ; DP : cancer colique » ; « hospitalisation pour fièvre et toux ; diagnostic de pneumonie, traitement ; DP : la pneumonie » ; « hospitalisation d’un enfant pour une suspicion de tumeur osseuse ; diagnostic d’ostéome ; sortie du patient avec les rendez-vous de consultation préanesthésique et d’admission en chirurgie pour traitement ; DP : ostéome ».

#### D2 · Pas de cause trouvée — diagnostic · 1.1.2

> Lorsqu’il n’a pas été découvert de cause à la symptomatologie, elle est le DP.

- « La symptomatologie qui a motivé l’hospitalisation et qui a été explorée, est le DP, qu’elle persiste ou qu’elle ait disparu lors du séjour. » « On rapproche de cette situation le décès précoce survenu avant qu’un diagnostic étiologique n’ait pu être fait. »
- « Dans cette situation le codage du DP utilise souvent le chapitre XVIII de la CIM–10 ; il ne fait pas appel aux codes Z, il ne doit donc pas être mentionné de DR dans le RUM. »
- « Sont équivalentes les situations rencontrées chez un patient atteint d’une affection chronique ou de longue durée connue, antérieurement diagnostiquée, admis pour une symptomatologie qui reste sans diagnostic étiologique : le DP est la symptomatologie »
- « La même règle s’applique aux circonstances dans lesquelles le motif d’admission est une suspicion diagnostique qui n’est pas confirmée au terme du séjour. Dans ces situations le DP est en général la symptomatologie, voire la suspicion (catégorie Z03) en l’absence de symptomatologie. »
- Exemples : « hospitalisation en raison de céphalées ; conclusion de sortie : « céphalées sans cause trouvée » ; DP : céphalées » ; « hospitalisation en raison d’un état de choc ; décès précoce sans diagnostic étiologique ; DP : état de choc » ; « hospitalisation en raison d’un syndrome inflammatoire ; sortie sans diagnostic étiologique ; DP : syndrome inflammatoire » ; « hospitalisation d’un patient diabétique en raison d’un syndrome inflammatoire ; sortie sans diagnostic étiologique ; DP : syndrome inflammatoire » ; « hospitalisation d’une patiente souffrant de polyarthrite rhumatoïde en raison de douleurs abdominales ; disparition des douleurs en 48 heures, pas de cause trouvée ; DP : douleurs abdominales ».

#### D3 · Motif de recours imposé — diagnostic · 1.1.3

> Pour les situations diagnostiques décrites dans les trois premiers points ci-dessous, il est demandé d’utiliser le code du motif de recours indiqué

- 1) « Lors des séjours (en général programmés) dont le motif a été une exploration nocturne ou apparentée telle que : l’enregistrement d’un électroencéphalogramme de longue durée : dans ce cas le code imposé pour le DP est Z04.800 Examen et mise en observation pour enregistrement électroencéphalographique de longue durée ; un enregistrement polygraphique : dans ce cas le code imposé pour le DP est Z04.801 Examen et mise en observation pour polysomnographie. Z04.800 ou Z04.801 s’impose comme DP quelle que soit la conclusion du séjour, qu’une maladie ait été diagnostiquée ou non. L’affection diagnostiquée ou la symptomatologie explorée est mentionnée comme DR lorsqu’elle respecte sa définition. »
- 2) « Lors des séjours pour tests allergologiques. Que le résultat soit positif ou négatif, le DP est codé Z01.5. Ce code s’impose conformément à sa note d’inclusion, quelle que soit la voie d’administration de l’allergène (cutanée ou autre). »
- 3) « Lors des séjours pour bilan préopératoire ou préinterventionnel. Z04.802 s’impose comme DP, qu’une affection soit ou non découverte au cours du bilan. Une affection découverte au cours du bilan est enregistrée comme un diagnostic associé. »
- Exemple : « Hospitalisation pour enregistrement polysomnographique en raison de ronflements : diagnostic d’apnées du sommeil : DP Z04.801, DR apnées du sommeil ; pas de cause diagnostiquée : DP Z04.801, DR ronflements. »

#### D4 · Examen diagnostique programmé sans diagnostic — diagnostic · 1.1.3 4)

> Lors des séjours, en général programmés pour une situation d’examen diagnostique motivée par un antécédent personnel ou familial (de cancer ou de polyadénome colique, par exemple) ou par une symptomatologie quelconque (élévation du PSA, par exemple), le DP est, en l’absence de mise en évidence du diagnostic, est la raison des explorations.

- Exemples : « l’antécédent (catégorie Z80 et suivantes), le facteur de risque ou le signe clinique ou paraclinique qui les a motivées, dans le respect du principe général selon lequel le code le plus juste est le plus précis par rapport à l’information à coder. »
- « On prendra garde à l’emploi parfois inapproprié du mot « dépistage » dans le langage médical courant. Ce mot a dans la CIM–10 le sens de « recherche de certaines affections inapparentes par des examens effectués systématiquement dans des collectivités » (dictionnaire Garnier-Delamare). Dans le cas d’un patient présentant un problème personnel de santé, les codes des catégories Z11 à Z13 de la CIM-10 ne doivent pas être employés. »
- Convention de la skill : un séjour programmé pour un examen diagnostique et conclu sans diagnostic relève de D4 ; tout autre séjour sans diagnostic relève de D2.

#### 1.1.4 · Situations équivalentes au diagnostic

« Sont équivalentes à celle décrite au point 1.1.1 les situations rencontrées chez un patient atteint d’une affection chronique ou de longue durée connue, antérieurement diagnostiquée, admis pour une symptomatologie aboutissant à l’un des diagnostics suivants. » « Le DP est l’affection diagnostiquée, c’est-à-dire la maladie en poussée aigüe, la complication ou l’affection intercurrente. »

#### D5 · Poussée aiguë d’une maladie chronique — diagnostic · 1.1.4 1°

> Lorsque le séjour a été motivé par une poussée aigüe d’une maladie chronique ou de longue durée, cette maladie peut être le DP, que le diagnostic ait été ou non suivi d’un traitement.

- « Dans cette situation, le langage médical courant emploie volontiers les qualificatifs de maladie « déséquilibrée », « décompensée », « déstabilisée » ou « exacerbée ». »
- « Il importe que le dossier médical contienne les informations étayant le diagnostic de poussée aigüe. La survenue de celle-ci cause une rupture dans la prise en charge de la maladie chronique ou de longue durée. Son traitement impose des mesures thérapeutiques inhabituelles, transitoires, témoignant d’une période critique. Il ne peut pas s’agir seulement, au cours du séjour, de modifications posologiques progressives du traitement antérieur, ou de la mise en place progressive du traitement avec lequel le patient quittera l’unité. »
- « On ne doit pas considérer toute maladie chronique ou de longue durée comme étant susceptible de poussée aigüe. Par exemple, on ne doit pas confondre l’aggravation progressive d’une maladie chronique avec la situation de poussée aigüe. […] En revanche, des évolutions telles que l’accroissement du volume ou l’extension par contiguïté d’une tumeur connue, l’augmentation de la dimension d’un anévrysme artériel ou du gradient d’un rétrécissement aortique — et toutes évolutions naturelles comparables — ne correspondent pas à la situation clinique de poussée aigüe au sens du recueil d’information du PMSI en MCO. La constatation de ces évolutions n’autorise pas à coder la maladie comme DP au terme des bilans ; on doit se référer à la situation de surveillance (voir le point 1.3 de ce chapitre). »
- Exemples : « poussée aigüe d’une maladie de Crohn ; DP : maladie de Crohn » ; « poussées hypertensives chez un hypertendu traité ; DP : HTA ».

#### D6 · Poussée aiguë avec rubrique propre — diagnostic · 1.1.4 1°

> L’affection chronique sous-jacente n’est pas le DP des séjours pour poussée aigüe quand la CIM–10 contient des rubriques ad hoc.

- Exemples : « thyréotoxicose aigüe : E05.5 ; acidocétose diabétique : E1–.1 ; angor instable : I20.0 ; exacerbation de maladie pulmonaire obstructive chronique : J44.1 ; état de mal asthmatique : J46 ; poussée aigüe de pancréatite chronique : K85.– ».

#### D7 · Complication d’une maladie chronique ou de son traitement — diagnostic · 1.1.4 2°

> Lorsque le séjour a été motivé par le diagnostic d’une complication d’une maladie chronique ou de longue durée, ou d’une complication du traitement de cette maladie, la complication est le DP, que le diagnostic s’accompagne ou non d’un traitement.

- « La règle D7 s’applique dans le cas d’une maladie chronique ou de longue durée connue avant la survenue de la complication. On ne confondra pas la situation avec celle d’une complication révélatrice d’une maladie auparavant méconnue : des cas tels que, par exemple, une détresse respiratoire révélatrice d’une infection pulmonaire, une anémie conduisant au diagnostic d’un cancer digestif ou un choc septique révélateur d’une prostatite, ressortissent à la situation clinique de diagnostic. La complication (la détresse respiratoire, l’anémie, le choc septique...) est dans ce cas la symptomatologie motivant l’admission et, conformément à la règle D1, le DP est l’infection pulmonaire, le cancer digestif ou la prostatite. »
- Note du guide : « La complication révélatrice est un diagnostic associé significatif chaque fois qu’elle en respecte la définition ».
- Exemples : « hospitalisation pour palpitations d’un patient atteint d’une cardiopathie chronique ; diagnostic de fibrillation auriculaire ; DP : fibrillation auriculaire » ; « hospitalisation du même patient pour lipothymies ; diagnostic de bradycardie par effet indésirable d’un digitalique ; DP : bradycardie » ; « hospitalisation pour douleurs thoraciques dues à un cancer bronchique connu ; DP : douleurs thoraciques » ; « hospitalisation en raison de la survenue d’un trouble neurologique chez un patient atteint d’un cancer ; découverte d’une métastase cérébrale ; DP : la métastase ».

#### D8 · Affection intercurrente — diagnostic · 1.1.4 3°

> Lorsque le séjour a été motivé par le diagnostic d’une affection ou d’une lésion intercurrente indépendante de la maladie chronique ou de longue durée, qu’il ait ou non été suivi d’un traitement, l’affection ou la lésion est le DP.

- Exemple : « hospitalisation d’un patient diabétique à la suite d’une chute en raison de douleurs et d’une impotence d’un membre inférieur ; une fracture du col du fémur est diagnostiquée et traitée ; DP : fracture du col du fémur ».

#### D9 · Bilan initial d’extension d’un cancer — diagnostic · 1.1.4 4°

> Par convention on considère également comme une situation équivalente le bilan initial d’extension d’un cancer. En matière de choix du DP on l’assimile à la situation 1.1.1 : au terme du séjour concerné le DP est la tumeur maligne.

- « On désigne par « bilan initial d’extension d’un cancer » le séjour au cours duquel sont effectuées les investigations suivant la découverte — le diagnostic positif — d’une maladie maligne, investigations notamment nécessaires pour déterminer son stade (par exemple, selon la classification TNM) et pour décider du protocole thérapeutique qui sera appliqué (bilan parfois dit de « stadification » préthérapeutique). »
- « […] que le bilan d’extension ait été réalisé au cours du même séjour que le diagnostic positif ou bien qu’il l’ait été au cours d’un séjour distinct ; quel que soit le résultat du bilan : si une métastase a été découverte, elle est une complication du DP et elle est mentionnée comme diagnostic associé significatif. »
- 1.3.4 : « quel que soit son résultat le DP est le cancer primitif (règle D9) ; il n’y a pas de DR ».
- Exemple : « hospitalisation d’un patient tabagique en raison d’hémoptysies ; découverte d’un cancer bronchique suivie du bilan de stadification préthérapeutique ; le DP est le cancer bronchique ».

### 1.2 · Hospitalisation pour traitement

« La situation est celle d’un patient atteint d’une affection connue, diagnostiquée avant l’admission, hospitalisé pour le traitement de celle-ci. Les circonstances du diagnostic préalable n’importent pas : le diagnostic de l’affection a pu être fait par un médecin généraliste ou spécialiste « de ville », par un service médical d’urgence et de réanimation (SMUR), lors du passage dans une structure d’accueil des urgences, lors d’un séjour précédent dans une autre unité médicale, y compris l’unité d’hospitalisation de courte durée, du même établissement de santé ou d’un autre, etc. La situation de traitement est présente lorsque le diagnostic de l’affection est fait au moment de l’entrée du patient dans l’unité médicale et que l’admission a pour but le traitement de l’affection. »

#### T1 · Traitement répétitif — traitement · 1.2.1

> Dans les situations de traitement répétitif le codage du DP utilise des codes du chapitre XXI de la CIM–10 (« codes Z »).

- « La dénomination traitement répétitif rassemble les traitements qui, par nature, imposent une administration répétitive. En d’autres termes, dès la prescription d’un traitement répétitif, le fait qu’il nécessite plusieurs administrations est connu, un calendrier peut en général être fixé à priori. Un traitement est répétitif soit parce que son efficacité dépend d’un cumul posologique (chimiothérapie, radiothérapie…), soit parce que, son effet s’épuisant, il doit être renouvelé (dialyse rénale, transfusion sanguine…). »
- « Les séjours pour chimiothérapie, radiothérapie, transfusion sanguine, aphérèse sanguine, oxygénothérapie hyperbare, injection de fer (pour carence martiale) qu’il s’agisse de séances ou d’hospitalisation complète, doivent avoir en position de DP le code adéquat de la catégorie Z51 de la CIM–10. » Les séances relèvent du chapitre VII.
- « La règle est la même si la prise en charge, incidemment, n’a lieu qu’une fois : c’est la nature du traitement qui est prise en considération. »
- DR : « Dans la situation de traitement répétitif, le DP étant un code Z, il faut mentionner l’affection traitée comme diagnostic relié (DR) toutes les fois qu’elle respecte sa définition. » « Lorsqu’un code Z51.0–, Z51.1, Z51.2, Z51.3–, Z51.5 ou Z51.8– est en position de DP, la maladie traitée est enregistrée comme DR chaque fois qu’elle respecte sa définition. »
- « « Autre chimiothérapie » a le sens de « chimiothérapie pour autre (maladie) que tumeur » ».
- Mise en route (1.4) : « première administration d’un traitement répétitif (dans ce cas le DP est un code Z, le DR est la maladie traitée) ».
- Exemples : « hospitalisations pour hémodialyse d’un insuffisant rénal chronique ; DP : dialyse extracorporelle (Z49.1) » ; « hospitalisations pour chimiothérapie d’une patiente atteinte d’un cancer du sein ; DP : chimiothérapie antitumorale (Z51.1) » ; « hospitalisations pour transfusion sanguine d’un patient atteint d’anémie réfractaire ; DP : transfusion sanguine (Z51.30) » ; « hospitalisations pour injection intraveineuse de fer d’un patient atteint d’une carence martiale ; DP : autres formes de chimiothérapie (Z51.2) » ; « hospitalisations pour traitement répétitif par infliximab d’un patient atteint d’une polyarthrite rhumatoïde ; DP : autre chimiothérapie (Z51.2) » ; « patient insuffisant rénal chronique en vacances, de passage dans un établissement de santé pour hémodialyse ; DP : Z49.1 » ; « cancéreux décédé après la première cure de chimiothérapie ; le DP de celle-ci reste Z51.1 ».

#### T2 · Exceptions au traitement répétitif — traitement · 1.2.1

> Il existe des exceptions :
> - le traitement de la douleur chronique rebelle : dans le cas d’un séjour dont le motif principal a été une prise en charge spécifiquement algologique, indépendante du traitement de la cause, le DP est codé R52.10 ou R52.18 ; c’est le cas lorsque l’hospitalisation s’est déroulée dans une unité de prise en charge de la douleur chronique.
> - l’évacuation d’ascite : le code du DP d’un séjour dont le motif principal est l’évacuation d’une ascite est R18 ;
> - l’évacuation d’épanchement pleural : le DP d’un séjour dont le motif principal est l’évacuation d’un épanchement pleural est codé, selon le cas, J90, J91 ou J94.– ;
> - l’injection de toxine botulique : l’affection neurologique (par exemple vessie neurogène réflexe : N31.1, blépharospasme : G24.5, crampe et spasme : R25.2) justifiant l’injection de toxine botulique peut être enregistrée comme DP d’une hospitalisation pour cet acte, dès lors que l’hospitalisation respecte les conditions exposées dans le point 1.5 du chapitre I.

- « Dans cette situation, on ne tient pas compte de la note d’exclusion de la catégorie R52. » (douleur chronique rebelle)
- « Le DP n’étant pas un code Z, il ne doit pas être mentionné de DR dans le RUM. »

#### 1.2.2 · Traitement unique

« Le traitement « unique » est ainsi désigné par opposition au traitement répétitif. Du point de vue du recueil d’informations du PMSI en MCO, un traitement non répétitif au sens de la situation 1.2.1 est un traitement unique. Dans la situation de traitement unique le DP est en général l’affection traitée. Le traitement unique peut être chirurgical, « interventionnel » ou médical. »

#### T3 · Traitement unique chirurgical — traitement · 1.2.2.1

> Dans la situation de traitement unique chirurgical, le DP est en général la maladie opérée.

- « Le diagnostic résultant de l’intervention peut être différent du diagnostic préopératoire. » « Le DP doit en effet être énoncé en connaissance de l’ensemble des informations acquises au cours du séjour (se reporter au point 1.1). » « Dans cette situation, le DP n’étant pas un code Z, il ne doit pas être mentionné de DR dans le RUM. »
- « Certaines situations de traitement unique chirurgical font appel pour le codage du DP aux codes des catégories Z40 à Z52 de la CIM–10 » : T4, T5, T6, T7, T15.
- Exemples : « hyperplasie prostatique connue ; indication opératoire posée en consultation externe ; hospitalisation pour adénomectomie prostatique ; DP : adénome prostatique » ; « même patient mais découverte, lors de l’examen anatomopathologique, d’un foyer d’adénocarcinome ; DP : cancer prostatique ».

#### T4 · Chirurgie esthétique — traitement · 1.2.2.1 1°

> Un acte de chirurgie esthétique : on désigne ainsi toute intervention de chirurgie plastique non prise en charge par l’assurance maladie obligatoire. Dans son cas le DP doit toujours être codé Z41.0 ou Z41.1, à l’exclusion de tout autre code.

- « S’agissant de chirurgie esthétique, par conséquent en l’absence d’affection sous-jacente, la question du diagnostic relié ne se pose pas. Toutefois, si le médecin souhaite coder le motif de la demande (certains codes de la CIM–10, en l’absence de définition, s’y prêtent : E65 Adiposité localisée, L98.7 Hypertrophie et affaissement de la peau et du tissu cellulaire sous cutané, M95.0 Déformation du nez, N62 Hypertrophie mammaire, N64.2 Atrophie mammaire, etc.) il peut l’être comme DR mais pas comme diagnostic associé. »
- Décision réservée : voir T6.
- Exemples : « mise en place de prothèses internes pour augmentation du volume mammaire à visée esthétique, non prise en charge par l’assurance maladie obligatoire : DP Z41.1 » ; « rhinoplastie à visée esthétique, non prise en charge par l’assurance maladie : DP Z41.1 ».

#### T5 · Chirurgie plastique réparatrice — traitement · 1.2.2.1 2°

> Un acte de chirurgie plastique non esthétique, de réparation d’une lésion congénitale ou acquise, pris en charge par l’assurance maladie obligatoire : le DP doit être codé avec un code des chapitres I à XIX ou un code de la catégorie Z42.

- « Au terme des séjours pour chirurgie plastique réparatrice (chirurgie plastique non esthétique), la question du DR ne se pose, par définition, que lorsque le DP est un code Z. »
- Note du guide : « La plupart des séjours pour intervention plastique réparatrice des séquelles d’une lésion traumatique ou d’une perte de substance postopératoire font en effet appel à la catégorie Z42 pour le codage du DP. Le DR peut être un code Z s’il correspond, tel Z90.1, à un « état permanent » ».
- Décision réservée : voir T6.
- Exemples : « mise en place d’une prothèse mammaire interne après mastectomie, prise en charge par l’assurance maladie obligatoire : DP Z42.1 » ; « rhinoplastie pour déviation de la cloison nasale, prise en charge par l’assurance maladie obligatoire : DP J34.2 » ; « dermolipectomie, par exemple dans les suites d’une prise en charge chirurgicale ou médicale d’une obésité morbide, prise en charge par l’assurance maladie obligatoire : DP E65 Adiposité localisée, L98.7 Hypertrophie et affaissement de la peau et du tissu cellulaire sous cutané » ; « séjour de mise en place d’une prothèse mammaire interne après mastectomie, hors antécédent personnel de tumeur du sein : DP Z42.1 ; DR Z90.1 » ; « séjour de mise en place d’une prothèse mammaire interne après mastectomie, pour tumeur du sein : DP Z42.1 ; DR Z85.3 » ; « séjour pour rhinoplastie pour déviation de la cloison nasale : DP J34.2, pas de DR ».

#### T6 · Intervention de confort — traitement · 1.2.2.1 3° et 1.2.2.2

> Une intervention dite de confort : on désigne par intervention « de confort » un acte médicotechnique non pris en charge par l’assurance maladie obligatoire, autre que la chirurgie esthétique. Le DP de ces séjours doit être codé Z41.80 Intervention de confort, à l’exclusion de tout autre code.

- « S’agissant d’intervention « de confort », la règle est la même que pour la chirurgie esthétique. Si le médecin souhaite coder le motif de la demande, il peut l’être comme DR mais pas comme diagnostic associé (par exemple, hospitalisation pour traitement chirurgical de la myopie : DP Z41.80, DR H52.1 Myopie). »
- Décision réservée (T4, T5, T6) : « Il ne s’impose pas au médecin responsable de l’information médicale ni au codeur de trancher entre chirurgie esthétique et autre chirurgie plastique ou bien de décider qu’une intervention est de confort. Il s’agit d’un choix qui est de la responsabilité du médecin qui effectue l’intervention, en cohérence avec la prise en charge par l’assurance maladie obligatoire. »
- Actes interventionnels (1.2.2.2) : « On rappelle qu’un acte médicotechnique non pris en charge par l’assurance maladie obligatoire, autre que la chirurgie esthétique, est considéré comme une intervention « de confort ». »

#### T7 · Soins de stomies, prothèses et appareils — traitement · 1.2.2.1 4°

> Dans la situation de prise en charge pour soins spécifiques de stomies, prothèses, autres appareils, le DP fait appel aux catégories Z43 à Z47 ainsi que Z49.0.

- « Les sens et modalités d’emploi de ces codes sont exposés dans le point 2 (Emploi des codes du chapitre XXI de la CIM–10) du chapitre V. »
- Exemples : « patient ayant subi quelques mois plus tôt une résection sigmoïdienne pour perforation diverticulaire, réhospitalisé pour fermeture de la colostomie (rétablissement de la continuité colique) : DP Z43.3 ; l’affection ayant motivé la prise en charge n’existe plus, par définition elle n’a pas sa place dans le RUM » ; « séjour de mise en place d’un système diffuseur implantable sous-cutané : DP Z45.2 » ; « séjour pour changement du générateur (épuisement normal) d’un stimulateur cardiaque : DP Z45.0 (en revanche, lors du séjour de mise en place initiale du stimulateur, le DP est la maladie qui la motive) » ; « séjour pour la mise en place d’un stimulateur du système nerveux central : Z45.84 » ; « séjour d’un patient en insuffisance rénale chronique terminale, pour confection d’une fistule artérioveineuse : DP Z49.0 ».

#### T15 · Intervention prophylactique — traitement · 1.2.2.1 5°

> Dans la situation de prise en charge pour une intervention prophylactique, le DP fait appel à la catégorie Z40.

- Exemple : « Patiente hospitalisée pour mastectomie (s) prophylactique DP : Z40.00 Ablation prophylactique du sein. »

#### T14 · Traitement unique en deux temps — traitement · 1.2.2.1 6°

> Lorsque s’impose une « reprise » d’un traitement unique chirurgical ou lorsque celui-ci se déroule en deux temps, la situation clinique reste de traitement unique : c’est la nature du traitement qui est prise en considération.

- « La notion de traitement unique en deux temps s’applique ainsi à des actes dont le second découle des examens per- ou postinterventionnels immédiats (anatomopathologie, imagerie...) visant à contrôler le résultat du premier. Il y a traitement unique en deux temps lorsqu’il est déduit de ce ou de ces examens qu’une intervention de complément est nécessaire, du fait du caractère incomplet ou supposé incomplet de la première. La notion de traitement unique en deux temps exclut un acte ultérieur qui résulterait d’une complication de la première intervention ou d’une complication de la maladie absente lors du premier acte. »
- Exemples : « femme ayant récemment subi une mastectomie pour cancer ; l’examen anatomopathologique de la pièce conclut à des « berges douteuses » ; réhospitalisation pour réintervention de complément ; il s’agit d’un traitement unique (la mastectomie n’est pas un traitement répétitif) en deux temps, et le DP du second séjour est encore le cancer du sein, que la nouvelle pièce opératoire montre ou non des cellules tumorales » ; « patiente ayant récemment subi une salpingoovariectomie pour un cancer de l’ovaire ; réhospitalisation pour un curage lymphonodal ; il s’agit d’un traitement unique (la salpingoovariectomie n’est pas un traitement répétitif) en deux temps, et le DP du second séjour est encore le cancer de l’ovaire, que les nœuds lymphatiques montrent ou non des cellules tumorales ».

#### T8 · Traitement unique interventionnel — traitement · 1.2.2.2

> Dans la situation de traitement unique interventionnel, le DP est en général la maladie sur laquelle on est intervenu.

- Champ (titre de 1.2.2.2) : acte thérapeutique par voie endoscopique ou endovasculaire, imagerie interventionnelle.
- « Lorsque s’impose une « reprise » d’un traitement unique « interventionnel » ou lorsque celui-ci se déroule en deux temps, la situation clinique reste de traitement unique : c’est la nature du traitement qui est prise en considération. »
- Exemples : « hospitalisation pour embolie artérielle d’un membre supérieur ; désobstruction par voie artérielle transcutanée ; le DP est l’embolie artérielle » ; « hospitalisation pour lithiase biliaire ; traitement par voie transcutanée avec guidage échographique, ou par lithotritie ; le DP est la lithiase » ; « patient atteint d’un hépatocarcinome hospitalisé pour une seconde injection intraartérielle hépatique in situ d’agent pharmacologique anticancéreux avec embolisation de particules (chimioembolisation) ; il s’agit d’un traitement unique (la CCAM ne décrit pas l’acte comme une séance) ; la décision d’une seconde chimioembolisation n’était pas initialement prévue, elle a résulté du résultat de la première) en deux temps ; le DP de la seconde chimioembolisation est l’hépatocarcinome ».

#### T9 · Traitement unique médical — traitement · 1.2.2.3

> Dans la situation de traitement unique médical, le DP est l’affection traitée.

- « Le DP n’étant pas un code Z, il ne doit pas être mentionné de DR dans le RUM. » « Le traitement médical peut être partagé entre deux unités médicales ou deux établissements de santé. Le DP de chacun est alors l’affection traitée. »
- Exemples : « hospitalisation en unité de soins intensifs cardiologiques (USIC) d’un patient victime d’un infarctus du myocarde ; diagnostic et thrombolyse effectués par le SMUR ; le DP de l’USIC est l’infarctus (prise en charge initiale) » ; « hospitalisation d’un patient atteint d’une pneumonie ; diagnostic établi lors du passage dans la structure d’accueil des urgences ; DP : la pneumonie » ; « infarctus cérébral ; hospitalisation initiale en soins intensifs neurovasculaires (DP : l’infarctus cérébral) ; mutation ou transfert au troisième jour dans une unité de médecine ; celle-ci poursuivant la prise en charge thérapeutique de l’infarctus cérébral récent, il reste le DP de son RUM » ; « hospitalisation pour suspicion d’endocardite infectieuse ; transfert au CHR ; confirmation de l’endocardite et début du traitement (DP : l’endocardite) ; transfert au 12e jour dans l’établissement d’origine pour la poursuite de l’antibiothérapie ; celui-ci poursuivant le traitement de l’endocardite, elle reste le DP de son RUM ».

#### T10 · Curiethérapie, irradiation en dose unique, fer en injection unique — traitement · 1.2.2.3

> - la curiethérapie et les irradiations en dose unique : le DP doit être codé Z51.01, comme dans les autres cas d’irradiation externe et interne ;
> - l’injection de fer (pour carence martiale) en injection unique : le DP doit être codé Z51.2

- DR : « Au terme des séjours pour curiethérapie à bas débit de dose, irradiation en dose unique, pour soins palliatifs ou injection de fer (pour carence martiale), le diagnostic relié est l’affection qui a motivé la prise en charge. »
- Exemples : « séjour pour curiethérapie à bas débit de dose pour cancer de la prostate : DP Z51.01, DR C61 » ; « séjours pour injection de fer pour anémie par carence martiale : DP Z51.2, l’anémie D50.– en DAS ou en DR dans le respect de la définition du DR ».

#### T11 · Soins palliatifs — traitement · 1.2.2.3

> les soins palliatifs : dès lors que leur définition est respectée le DP est codé Z51.5.

- Définition : instruction interministérielle N°DGOS/R4/DGS/DGSS/2023/76 du 21 juin 2023.
- DR : l’affection qui a motivé la prise en charge (voir T10).
- Exemples : « séjour de soins palliatifs pour cancer du corps utérin en phase terminale : DP Z51.5, DR C54.– » ; « séjours de soins palliatifs pour SIDA avec cachexie : DP Z51.5, DR B22.2 ».

#### 1.2.3 · Situations équivalentes au traitement unique

« On assimile à la situation de traitement unique les circonstances suivantes : »

#### 1.2.3 1° · Mise en route d’un traitement au long cours — traitement

> La mise en route du traitement d’une maladie chronique ou de longue durée, c’est-à-dire l’hospitalisation nécessitée par la première administration d’un traitement médicamenteux appelé à être ensuite poursuivi au long cours.

- 1.4 : « situation de traitement (1.2) lorsque la mise en route a lieu au cours d’un séjour particulier, postérieur à celui du diagnostic : traitement unique (le DP est alors la maladie, pas de DR) ou première administration d’un traitement répétitif (dans ce cas le DP est un code Z, le DR est la maladie traitée). »

#### 1.2.3 2° · Diabète : rupture de la prise en charge — traitement

> Chez les patients diabétiques non amélioré par une adaptation ambulatoire du traitement, la nécessité d’une rupture dans la prise en charge globale avec changement de la stratégie thérapeutique répondant au moins à l’un des critères suivants :
> - nécessité de recourir à un schéma insulinique avec plusieurs injections quotidiennes d’insuline ou une insulinothérapie par pompe,
> - nécessité de reconsidérer l’approche thérapeutique en cas d’échec d’un traitement insulinique multi injections,
> - nécessité de débuter ou modifier une insulinothérapie chez un patient à haut risque c’est-à-dire présentant au moins l’une des caractéristiques suivantes : syndrome coronaire aigu ou AVC il y a moins d’un an ; rétinopathie pré proliférative sévère ou proliférative non stabilisée ; insuffisance rénale avec un taux de filtration glomérulaire < 30 ml/mn (MDRD ou CKD-EPI) ; antécédent d’hypoglycémies sévères ou à répétition (plus de 4 par semaine) ou non perçues ; grossesse chez une patiente diabétique de type 1 ou 2 ; situation de précarité et d’isolement social.

- « Toute la prise en charge est réévaluée durant l’hospitalisation (règles hygiénodiététiques, autosurveillance glycémique, traitement oral ou injectable associé à l’insuline, traitement des comorbidités). Il ne peut pas s’agir seulement, au cours du séjour, de modifications posologiques progressives du traitement antérieur, ou de la mise en place progressive du traitement avec lequel le patient quittera l’unité. »
- DP : le diabète (1.4 : « chez les patients diabétiques, la nécessité d’une rupture dans la prise en charge globale avec changement de la stratégie thérapeutique et réévaluation de toute la prise en charge »).

#### T12 · Accouchement normal — traitement · 1.2.3 3°

> On désigne ainsi un accouchement en présentation du sommet sans complication chez une femme indemne de toute morbidité obstétricale. Le DP du séjour est codé O80.0 Accouchement spontané par présentation du sommet

- Accouchement non normal : hors chapitre VI.

#### T13 · Naissance en maternité — traitement · 1.2.3 4°

> La naissance d’un enfant séjournant en maternité avec sa mère : le DP du séjour du nouveau-né est codé avec la catégorie Z38 Enfants nés vivants, selon le lieu de naissance

- « Si un problème de santé est découvert à la naissance ou pendant le séjour en maternité, il est un diagnostic associé significatif du RUM du nouveau-né en maternité. »

#### 1.2.3 5° · Interruption volontaire de grossesse — traitement

> Le DP du séjour d’IVG est codé avec la catégorie O04 de la CIM–10 interruption médicale volontaire de grossesse en position de diagnostic principal (DP). Lorsqu’une complication survient au cours du séjour même de l’IVG, celle-ci est codée par le quatrième caractère du code O04.–.

#### 1.2.3 6° · Interruption médicale de grossesse — traitement

> Avant vingt-deux semaines révolues d’aménorrhée : le DP du séjour d’IMG est codé avec la catégorie O04 O04.-1 ; O04.-2 ou O04.-3 interruption médicale de grossesse ; à partir de vingt-deux semaines révolues d’aménorrhée le DP du séjour d’IMG est la cause fœtale ou maternelle de l’IMG

### 1.3 · Hospitalisation pour surveillance

« La situation est celle d’un patient atteint d’une affection connue, antérieurement diagnostiquée, éventuellement traitée (antérieurement traitée ou en cours de traitement), hospitalisé pour la surveillance de celle-ci. »

« Par séjour de surveillance on entend tout séjour visant au suivi médical d’une affection, à faire le point sur son évolution ou sur l’adéquation de son traitement, affection diagnostiquée antérieurement au séjour et déjà traitée (précédemment opérée, par exemple) ou en cours de traitement. La situation de surveillance est rencontrée pour l’essentiel dans deux types de circonstances : surveillance des maladies chroniques ou de longue durée : elle correspond en particulier à l’appellation courante de « bilan » ; elle concerne souvent — mais pas seulement — des prises en charge « à froid », programmées, de brève durée ; au cours ou au terme du séjour, des investigations ultérieures peuvent être programmées ou des décisions thérapeutiques prises : institution, poursuite ou modification d’un traitement, indication opératoire, etc. ; la surveillance d’un patient transféré d’un autre établissement de santé après un traitement (surveillance postopératoire ou postinterventionnelle, ou après traitement médical). »

« Il résulte de la définition de la situation de surveillance que la modification, l’adaptation, pendant ou au terme du séjour, du traitement d’une affection connue, antérieurement diagnostiquée, antérieurement traitée ou en cours de traitement, ne transforme pas une situation de surveillance négative en situation de traitement et n’autorise pas à coder l’affection comme DP. Les prescriptions (examens paracliniques, modification du traitement) conséquences des constatations ou investigations faites au cours d’un séjour pour surveillance font partie de la surveillance, à l’exception du cas particulier de la nécessité d’une rupture de la prise en charge globale avec changement thérapeutique chez les patients diabétiques (point 1.2.3 – 2° chapitre VI). »

#### S1 · Surveillance négative — surveillance négative · 1.3.1

> Lorsqu’il n’est pas découvert d’affection nouvelle la surveillance est dite négative, le DP est un « code Z ».

- « Le codage du DP dans les situations de surveillance négative utilise le plus souvent les rubriques suivantes de la CIM–10 : les catégories Z08 et Z09 ; les catégories Z34, Z35, Z39 pour l’antepartum, le postpartum ; les codes Z38.– et Z76.2 pour les nouveau-nés ; la catégorie Z48 pour les patients transférés après un traitement chirurgical — y compris une transplantation d’organe — ou « interventionnel » réalisé dans un autre établissement de santé ; Z71.3 pour les affections nutritionnelles ou métaboliques, Z71.4 et Z71.5 pour les addictions ; la catégorie Z94 pour les organes et tissus greffés ; les codes Z95.1 à Z95.8 pour les porteurs de pontage coronaire et de prothèse endoartérielle (stent)), de prothèse valvulaire cardiaque et « autres implants et greffes cardiaques et vasculaires ». »
- Convention de la skill : donne la catégorie ; le choix du code précis relève du chapitre V, sauf quand un exemple du guide le donne pour le même cas.
- DR : « Dans une situation de surveillance négative l’affection surveillée doit être enregistrée comme DR lorsqu’elle respecte sa définition. »
- DAS : « Si une affection sans rapport avec la maladie surveillée est découverte incidemment au cours du séjour, conformément à la définition du DP la situation est néanmoins de surveillance négative car l’affection découverte n’est pas « le problème de santé qui a motivé l’admission ». L’affection découverte est un diagnostic associé significatif (DAS). »
- Exemples : « bilan de synthèse annuel de l’infection par le VIH ; absence d’affection nouvelle ; DP : code Z de surveillance, DR : l’infection par le VIH (maladie chronique, présente lors du séjour, objet de la surveillance) » ; « hospitalisation pour surveillance après colectomie pour cancer ; « bilan » négatif ; découverte d’une diverticulose sigmoïdienne au cours de la coloscopie, ou de calculs biliaires ou de kystes rénaux lors de l’échographie abdominale. Le code du DP est Z08.0, le DR est le cancer colique (la situation est de surveillance négative à son égard) ; la diverticulose sigmoïdienne, les calculs biliaires ou les kystes rénaux sont un DAS » ; « surveillance d’un cancer du sein au cours ou au terme d’une chimiothérapie… […] pas d’affection nouvelle ; situation de surveillance négative (1.3.1) : DP : surveillance (ici code Z08.–) ; le cancer du sein est le DR ».

#### S2 · Surveillance d’un patient transplanté — surveillance négative · 1.3.1

> Les codes de la catégorie Z94 s’imposent en position de DP dans les situations de surveillance négative d’un patient transplanté, c’est-à-dire pour les séjours de surveillance après greffe d’organe ou de tissu au terme desquels il n’est pas diagnostiqué de complication.

#### S3 · Surveillance d’un porteur d’implant ou de greffe cardiovasculaire — surveillance négative · 1.3.1

> De même, les codes de la catégorie Z95 s’imposent en position de DP dans les situations de surveillance négative d’un patient porteur d’un implant ou d’une greffe cardiovasculaire compris dans la catégorie.

#### SD1 · Surveillance positive — surveillance positive · 1.3.2

> Lorsqu’une affection nouvelle respectant la définition du DP est découverte, la surveillance est dite positive. Le DP est l’affection diagnostiquée.

- « En effet, l’affection diagnostiquée est en général une complication de la maladie surveillée ou de son traitement, ou une récidive : la situation de surveillance positive équivaut ainsi à celle de diagnostic (se reporter au point 1.1.4). »
- « On considère comme une situation de surveillance positive : la découverte d’une nouvelle localisation secondaire tumorale, y compris lorsqu’elle siège dans un organe préalablement connu comme métastatique (os, foie, poumon, etc.) ; […] la découverte d’une sténose coronaire significative chez un patient déjà porteur d’une ou plusieurs sténoses coronaires traitées antérieurement ; la découverte d’une localisation viscérale nouvelle d’un lymphome connu. »
- « On rappelle qu’en revanche, si une affection sans rapport avec la maladie surveillée est découverte au cours du séjour, conformément à la définition du DP la situation n’est pas de surveillance positive. Elle est de surveillance négative » : voir S1.
- Exemples : « bilan de synthèse annuel de l’infection par le VIH ; découverte d’un sarcome de Kaposi ; DP : sarcome de Kaposi » ; « bilan après vésiculoprostatectomie pour cancer ; découverte d’une métastase fémorale ; DP : métastase osseuse » ; « bilan après vésiculoprostatectomie pour cancer ; métastase osseuse fémorale connue ; découverte d’une nouvelle métastase osseuse ; DP : la métastase découverte, qu’elle siège aussi sur le fémur ou sur un autre os » ; « surveillance d’un cancer du sein au cours ou au terme d’une chimiothérapie… découverte d’une métastase osseuse ; situation de surveillance positive (1.3.2) : le DP est la métastase ».

#### S4 · Post-partum après transfert — surveillance négative (situation assimilée) · 1.3.3

> Après accouchement dans un établissement de santé A, une mère et son nouveau-né sont transférés dans un établissement de santé B pour les soins du postpartum (soins standard, pas de complication, nouveau-né normal) ; en B : le DP du RUM de la mère est codé Z39.08 Soins et examens immédiatement après l’accouchement, autres et sans précision ; le DP du RUM du nouveau-né est codé Z76.2 Surveillance médicale et soins médicaux d’autres nourrissons et enfants en bonne santé.

#### SD2 · Récidive d’un cancer — surveillance positive (situation assimilée) · 1.3.3

> On assimile à la situation de surveillance positive les cas de séjours motivés par un antécédent de cancer, au cours desquels est découverte une récidive. La tumeur, récidivant est le DP

- Conditions : « La notion de récidive est réservée aux cas de cancer : non métastatique d’emblée ; dont les séquences thérapeutiques constituant le traitement initial sont terminées ; considéré comme étant en rémission complète avant la découverte de la récidive. »
- Décision réservée : « Il n’appartient pas au médecin responsable de l’information médicale ni au codeur de trancher entre cancer et antécédent de cancer. Ce diagnostic est de la compétence du médecin qui dispense les soins. »
- 1.3.4 : « Le cancer primitif n’est le DP qu’en cas de récidive (règle SD2). »

#### 1.3.4 · La notion de « bilan »

- « Le mot « bilan » est un faux ami aux sens multiples. […] En conséquence, devant le mot bilan, il faut se garder d’en déduire par réflexe un codage « en Z » du DP. La mention de ce mot dans la description d’un séjour hospitalier ne constitue jamais une aide au choix du DP et l’analyse doit toujours être faite en termes de situation clinique. Il faut déterminer quel était le but du « bilan ». Il est parfois diagnostique, et son codage alors n’emploie pas un code Z : situation de diagnostic (1.1). Il est souvent de surveillance : en cas de surveillance positive (situation 1.3.2) son codage n’emploie pas un code Z, il ne le fait qu’en cas de surveillance négative (situation 1.3.1). »
- « Le bilan d’un cancer peut être fait dans deux situations : dans les suites du diagnostic positif : c’est la situation de bilan initial d’extension d’un cancer, dite de stadification préthérapeutique, traitée dans le point 1.1.4 (4°) ; à distance du diagnostic positif et du bilan initial d’extension préthérapeutique : surveillance (habituellement programmée) au cours du traitement, à son terme ou ultérieurement en période de rémission ; il s’agit de la situation de surveillance décrite dans le point 1.3 ; les règles de choix du DP sont celles qui ont été énoncées. »
- Autres bilans d’un cancer : « le DP est un code Z (règle S1), une complication du cancer (telle une métastase) ou une complication de son traitement (règle SD1). Il n’est jamais le cancer primitif ; celui-ci est enregistré en position de DR lorsque la surveillance est négative puisque dans cette situation le DP est un code Z. »

### 1.4 · Maladies chroniques et de longue durée

> Il résulte de ce qui vient d’être exposé qu’une maladie chronique ou de longue durée ne peut être le DP d’un séjour que dans les circonstances suivantes : diagnostic positif de la maladie (règle D1) ; poussée aigüe (règle D5) ; bilan initial préthérapeutique de stadification (d’extension) du cancer (règle D9) ; chez les patients diabétiques, la nécessité d’une rupture dans la prise en charge globale avec changement de la stratégie thérapeutique et réévaluation de toute la prise en charge ; traitement unique (règles T–) ; récidive après rémission (règle SD2) ; décès éventuellement.

- Poussée aigüe : « Si elle correspond à une réalité médicale et s’il n’existe pas de code propre à l’état aigu. »
- Décès : « Hors complication terminale ou autre problème de santé ayant motivé l’admission, conformément à la définition du DP, et ayant son code propre — infection, par exemple ; se reporter à la règle D7 —, et hors soins palliatifs (règle T11). »

### 1.5 · Plusieurs diagnostics principaux possibles

« Le DP étant le problème de santé qui a motivé l’admission, une telle circonstance ne peut être que rare. » « L’affection qui n’est pas retenue comme DP est un DAS. »

#### M1 · Problème ayant mobilisé l’essentiel des soins — 1.5

> Le DP, déterminé à la sortie de l’UM, est alors celui des problèmes qui a mobilisé l’essentiel des efforts de soins.

#### M2 · Prises en charge équivalentes — 1.5

> Dans le cas où les deux problèmes auraient mobilisé des efforts d’importance comparable, c’est-à-dire dans le cas de prises en charge équivalentes, et dans ce cas seulement, le choix du DP parmi les ex æquo est laissé à l’établissement de santé.

- Note du guide : la réalité de prises en charge équivalentes « doit être contrôlable dans [l]e dossier du malade : le RUM doit être conforme au contenu du dossier médical du patient ».

### 1.6 · Prise en charge prévue non réalisée — prise en charge prévue non réalisée

> Le DP défini comme le problème de santé qui a motivé l’admission ne connaît qu’une exception. Elle concerne les situations dans lesquelles, alors qu’un patient est admis pour une prise en charge prévue à l’avance, celle-ci s’avère impossible à réaliser, en général du fait d’une contre-indication.

- « La règle s’applique à des hospitalisations motivées par des prises en charge (médicales, chirurgicales ou interventionnelles) prévues à l’avance (si une utilisation du plateau technique est nécessaire, ses moyens ont été réservés antérieurement à l’hospitalisation). »
- Aucun RUM : « hospitalisation programmée pour chimiothérapie antitumorale ; le médecin prend connaissance de la numération formule sanguine (NFS) qui montre une leucopénie et une thrombopénie contre-indiquant la chimiothérapie, et explique au patient pourquoi celle-ci ne peut pas être administrée ; le patient retourne à son domicile. Aucun RUM n’est produit car la lecture d’une NFS et l’explication donnée ne justifient pas une hospitalisation (une consultation externe peut-être facturée). » « Panne de matériel ou non disponibilité plateau technique, aucun RUM n’est produit. »
- « Dans le cas où la production d’un RUM est justifiée, il existe deux modalités de codage du diagnostic principal : l’affection cause de la contre-indication lorsqu’elle nécessite une prise en charge diagnostique ou thérapeutique. […] Un code de la catégorie Z53 Sujets ayant recours aux services de santé pour des actes médicaux spécifiques, non effectués est enregistré comme diagnostic associé. Le motif de non-réalisation ne justifie qu’une surveillance, sans qu’une affection ne soit mise en évidence ; cette circonstance ne peut être que rare car l’hospitalisation doit respecter les conditions exposées dans le point 1.5 du chapitre I ; DP : Z53.– »
- Exemples : « hospitalisation programmée pour chimiothérapie antitumorale ; une fièvre est constatée à l’entrée et la chimiothérapie annulée ; l’hospitalisation permet le diagnostic et le traitement d’une pneumonie ; DP : la pneumonie » ; « hospitalisation programmée pour intervention chirurgicale ; une fièvre est constatée quelques heures après l’admission et l’intervention annulée ; une hospitalisation de 48 heures ne permet pas d’identifier la cause de la fièvre ; retour à domicile ; DP : la fièvre ».
