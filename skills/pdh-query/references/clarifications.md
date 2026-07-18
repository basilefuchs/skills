# Checklist de clarification (à poser via AskUserQuestion)

Poser par lots de 4 questions maximum. Toujours proposer une option par défaut marquée
« (Recommandé) ». Ne poser que les questions pertinentes pour la demande, mais les
blocs A, B, C doivent être couverts (par une question ou par un défaut explicitement
validé au moment du protocole).

## A. Population — critères d'inclusion

1. **Codes CIM-10** : proposer une liste précise d'après la pathologie citée et la
   faire valider. Exemples : diabète = E10–E14 (préciser si on inclut le diabète
   gestationnel O24) ; Parkinson = G20 (maladie de Parkinson) vs G20–G22 (syndromes
   parkinsoniens). Afficher les codes et libellés (table `nom_pmsi.all_cim10`).
   Demander : troncature à 3 caractères ou codes complets ?
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

15. Format : tableau agrégé affiché, export CSV, graphique (courbe d'évolution ggplot2),
    ou les trois.
16. **Environnement** : ne rien demander (connexion, schémas) quand un profil
    de `references/profils/` couvre l'environnement — voir SKILL.md, Ressources.
    Sinon, demander une fois et proposer d'enregistrer un nouveau profil.
