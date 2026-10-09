# Checklist de clarification

Poser par lots de 4 questions maximum, via l'outil de choix multiple si disponible
(ex. AskUserQuestion), sinon à l'écrit. Toujours proposer une option par défaut
marquée « (Recommandé) ». Ne poser que les questions pertinentes pour la demande,
mais le bloc 0 et les blocs A, B, C doivent être couverts (par une question ou par
un défaut explicitement validé au moment du protocole).

## Dépendances entre questions (à signaler explicitement)

Une réponse peut contraindre ou éclairer une question à venir (ou l'inverse) — le
dire au moment de poser la question, plutôt que de laisser l'utilisateur le
découvrir après coup :

- **Q0 → Q15** : diffusion externe/publication impose le secret statistique
  (aucune cellule < seuil) dans le format de sortie.
- **Q1a → Q11/Q12** : troncature CIM-10 à 3 caractères (sur-inclusion) vs codes
  complets (sous-inclusion) modifie la sensibilité du critère de jugement.
- **Q1b → Q11/Q12** : même logique côté CCAM — motif partiel (ex. lettre de
  technique en position 4) vs codes complets (7 caractères).
- **Q1a ↔ Q1b** : si la question mêle pathologie ET acte (ex. « AVC traité par
  thrombectomie »), lever explicitement l'opérateur logique — intersection
  (DP AVC **et** acte thrombectomie) ou union (DP AVC **ou** acte thrombectomie,
  périmètre bien plus large) ne donnent pas le même effectif.
- **Q2 ↔ Q3** : le nom des variables de position diagnostique change selon le
  champ (`dp` en MCO ; `finalp`/`morbidp`/`etiolp` en SSR) — champ multiple =
  vérifier la cohérence de la question posée pour chacun.
- **Q3 → Q9** : plusieurs champs PMSI = le chaînage inter-champs doit être
  vérifié séparément du chaînage intra-champ.
- **Q4 → Q13** : le nombre d'années demandé doit être cohérent avec la lecture
  choisie pour une « évolution » (patients uniques par année vs cohorte
  pluriannuelle dédupliquée).
- **Q9 → Q11** : patients uniques comme unité de compte impose le chaînage
  fiable (`ano_retour == '000000000'`) en critère d'exclusion, pas en option.

## 0. Finalité de l'analyse (à poser en premier)

0. **Usage des résultats** : dénombrement interne rapide, rapport ou dialogue de
   gestion, diffusion externe (ARS, tutelle), publication scientifique, projet
   capacitaire ? Conditionne le niveau de rigueur (standardisation, analyses de
   sensibilité), les seuils de robustesse du profil, le secret statistique des
   sorties (aucune cellule < 11 en diffusion externe) et le format de livraison.

## A. Population — critères d'inclusion

1a. et 1b. sont deux variantes du même critère (axe pathologie vs axe acte) : pour
toute variante future du même type (ex. un critère FINESS/établissement), continuer
ce schéma `1c`, `1d`… plutôt que « bis »/« ter », pour rester lisible dans les
dépendances ci-dessus.

1a. **Codes CIM-10** : proposer une liste précise et la faire valider. Si WebSearch
   est disponible, chercher d'abord une définition publiée (Santé publique France,
   cartographie CNAM, fiches ATIH, littérature) et la proposer **source citée** ;
   sinon proposer d'après connaissances en le signalant. La liste reste amendable :
   les critères font souvent débat entre médecins DIM. Exemples : diabète = E10–E14
   (préciser si on inclut le diabète gestationnel O24) ; Parkinson = G20 (maladie de
   Parkinson) vs G20–G22 (syndromes parkinsoniens). Afficher les codes et libellés
   (table `nom_pmsi.all_cim10`).
   Demander : troncature à 3 caractères ou codes complets ?
1b. **Codes CCAM/CSARR** (si le phénomène est un acte — cf. étape 1 du workflow,
   ou si la question mêle pathologie et acte) : même exigence qu'en Q1a — liste
   précise validée, source citée si WebSearch disponible (nomenclature ATIH
   `nom_pmsi.all_ccam`, sociétés savantes, guides de bon usage), sinon proposer
   d'après connaissances en le signalant. Un code CCAM fait 7 caractères (4
   lettres + 3 chiffres) ; certains périmètres se définissent par un **motif**
   plutôt qu'une liste (ex. médecine nucléaire = 4ᵉ lettre du code = « L »,
   technique utilisant des radioéléments — il n'existe pas de liste dédiée par
   ailleurs). En SSR, structure équivalente côté CSARR.
   Demander : codes complets ou motif partiel (préfixe, lettre de position) ?
   Préciser aussi acte principal ou associé, et le périmètre (séjours MCO
   seulement, ou aussi consultations/actes externes — RSF) : voir le profil du
   champ pour les colonnes exactes (variable selon le champ).
2. **Position du diagnostic** :
   - DP seul (« hospitalisé POUR ») — recommandé pour un motif d'hospitalisation ;
   - DP ou DR — capte les séances et prises en charge où la maladie est en diagnostic relié ;
   - DP, DR ou DAS (« hospitalisé AVEC ») — prévalence hospitalière, effectifs bien plus larges ;
   - niveau RUM (`um.dpdurum`) en plus du niveau séjour ?
   En SSR adapter : `finalp` / `morbidp` / `etiolp`.
3. **Champ(s) PMSI** : MCO seul (recommandé pour « hospitalisation ») ou MCO+SSR+HAD+PSY ;
   urgences (RPU) séparément.
4. **Période** : années de la base (= année de sortie). Bornes incluses. Si « évolution » :
   nombre d'années souhaité.
5. **Géographie** : France entière ; sinon filtre par **résidence du patient**
   (`codegeo`) ou par **localisation de l'établissement** (`finess`) — les deux ne
   donnent pas le même résultat.
6. **Population** : tous âges ou restriction (ex. ≥ 18 ans) ; les deux sexes.

## B. Critères d'exclusion

7. **Séances** (MCO, GHM `28*`) : exclues (recommandé quand on compte des
   hospitalisations) ou incluses ?
8. **Séjours en erreur** : GHM `90*` — exclus par défaut.
9. **Chaînage en erreur** (`ano_retour != '000000000'`) : à exclure si comptage de
   patients uniques ; signaler la perte.
10. Autres selon contexte : séjours de la même journée (`duree == 0`), nouveau-nés,
    IVG, prestations inter-établissements, décès (`modesortie == '9'`)…

## C. Critère de jugement (indicateur principal)

11. **Unité de compte** : patients uniques (`n_distinct(anonyme)`) / séjours / journées
    (`sum(duree)`) / passages (RPU).
12. **Type d'indicateur** : effectif brut ; taux pour 100 000 habitants (dénominateur
    `nom_gen.pop_com_sex_ag`) ; taux standardisé (âge/sexe) ; évolution (série annuelle,
    % d'évolution, éventuellement taux de croissance annuel moyen).
13. Pour une « évolution » : patients uniques **par année** (un patient peut apparaître
    plusieurs années) ou cohorte dédupliquée sur toute la période ? Les deux lectures
    sont valides — faire choisir.

## D. Stratification / croisements

14. Par année, sexe, classe d'âge (préciser les bornes), région/département (résidence
    ou établissement), statut de l'établissement, GHM… Aucune stratification = total simple.

## E. Sortie attendue

15. Format : script `.R` (tableau agrégé affiché, export CSV, graphique ggplot2) ou
    **rapport `.Rmd`** (narratif méthodologique, tables interactives, figures,
    flowchart d'attrition intégré) — recommandé dès que le résultat est destiné à
    être partagé tel quel (rapport, dialogue de gestion, diffusion externe).
16. **Environnement** : ne rien demander (connexion, schémas) quand un profil
    de `references/profils/` couvre l'environnement — voir SKILL.md, Ressources.
    Sinon, demander une fois et proposer d'enregistrer un nouveau profil.
