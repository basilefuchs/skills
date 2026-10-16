# snds-copilot — copilote de requête SNDS pour Claude

Skill pour [Claude Code](https://claude.com/claude-code), [claude.ai](https://claude.ai)
et les autres agents compatibles [Agent Skills](https://agentskills.io),
destinée aux statisticiens de DIM qui **écrivent eux-mêmes** leurs requêtes
sur le **SNDS via le Health Data Hub** (Oracle), en SQL ou en R dbplyr. Elle
répond directement, sans protocole : vous tenez le clavier, elle relit,
renseigne ou complète.

Elle est hors du parcours question → protocole → scripts, avec un point de
contact : après une erreur d'exécution d'un dossier généré par
[`snds-query`](https://github.com/basilefuchs/skills/tree/main/skills/snds-query),
la relecture du fichier en cause est le chemin de correction, sans toucher au
protocole.

Pour partir d'une question en langage naturel (« combien de patients
diabétiques hospitalisés en 2023 ? »), utiliser plutôt
[`question-recherche-pico`](https://github.com/basilefuchs/skills/tree/main/skills/question-recherche-pico) :
la skill y renvoie d'elle-même (`/question-recherche-pico <question>`).

## Trois usages

- **Relecture** : collez une requête SQL Oracle, R dbplyr (ou SAS, lu mais
  jamais produit). La skill rend les constats classés **bloquant / à
  vérifier / suggestion** — ligne visée, raison en une phrase, correctif —
  puis la requête corrigée entière, dans le langage de votre entrée. Grille
  de relecture : existence des tables et colonnes et noms réels des tables
  PMSI, millésimes, jointures et chaînage inter-sources, filtres qualité
  recommandés, pièges Oracle (`NULL`, listes `IN` de plus de 1000 valeurs,
  dates, fuseau), volumétrie (`collect()` prématuré, `ER_PRS_F` sans batch
  de flux), sorties (secret statistique, écriture locale d'identifiants).
- **Consultation** : « quelle table pour les actes CCAM en ville ? »,
  « `FP_PEC` existe-t-il en 2023 ? », « que vaut `DPN_QLF = 71` ? ». La
  réponse est lue dans le dictionnaire embarqué et le profil
  d'environnement, avec sa source et la conséquence pour votre requête.
- **Complétion** : décrivez l'étape à écrire (boucle par millésime, jointure
  DCIR à 9 colonnes, batch sur `FLX_DIS_DTD`). La skill rend le fragment
  prêt à insérer, en dbplyr par défaut ou en SQL Oracle sur demande, d'après
  les patterns validés.

## Après une erreur d'exécution

Un script généré par `snds-query` échoue sur la plateforme : collez le
fichier en cause (un fichier de `scripts/`, ou le chunk de `analyse.Rmd`) et
le message d'erreur. La skill le relit et rend le fichier corrigé entier ;
`protocole.md` et les autres fichiers du dossier restent intacts. Une
correction n'est pas mémorisée : relancer `/snds-query` régénère les scripts
depuis le protocole et l'écrase. Un critère à changer passe par
[`snds-schema`](https://github.com/basilefuchs/skills/tree/main/skills/snds-schema),
puis `snds-query`.

## Ce que la skill sait

Des copies, identiques à leur source, de références d'autres skills du
dépôt :

- de `snds-schema` : le dictionnaire des tables, variables, millésimes,
  jointures et nomenclatures du SNDS, généré depuis le dépôt open source
  [schema-snds](https://gitlab.com/healthdatahub/applications-du-hdh/schema-snds)
  du Health Data Hub (licence MPL-2.0, voir
  [NOTICE](https://github.com/basilefuchs/skills/blob/main/skills/snds-copilot/NOTICE)),
  son script de construction, et le modèle de données (DCIR, PMSI, causes de
  décès, chaînage patient) ; à chaque usage, la skill tire une version
  fraîche du dictionnaire si le réseau le permet, la copie embarquée servant
  de secours ;
- de `snds-query` : le profil de l'environnement Health Data Hub (connexion,
  mapping concept → colonne, filtres qualité recommandés, pièges Oracle), qui
  fait foi sur l'environnement, et le squelette de scripts avec les patterns
  dbplyr validés.

S'y ajoute la
[documentation officielle du Health Data Hub](https://documentation-snds.health-data-hub.fr/),
consultée en cas de doute quand l'accès web existe : elle fait foi sur les
filtres et la méthodologie.

## Prérequis

- [Claude Code](https://claude.com/claude-code) (CLI ou application), **ou**
  un compte [claude.ai](https://claude.ai) avec la capacité Skills et
  l'exécution de code activée (la skill pèse environ 3 Mo décompressés,
  dictionnaire compris), **ou** un autre agent compatible Agent Skills.
  Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).
- Un accès à l'environnement du Health Data Hub pour exécuter vos requêtes ;
  la skill n'en a pas besoin.

## Utilisation

- copiée comme **skill** dans Claude Code (`~/.claude/skills/` ou
  `.claude/skills/`) : `/snds-copilot` suivi de la requête collée ou de la
  question ; sans argument, la skill demande quoi relire ;
- sur **claude.ai** : pas de commande, coller la requête ou poser la
  question technique ; la skill se déclenche sur sa description.

Exemples :

- « Relis cette requête : `SELECT ... FROM T_MCOaaB WHERE DPN_QLF != 71 ...` »
- « Quelle table pour les actes CCAM en ville, et sur quelle clé la joindre ? »
- « Écris-moi la boucle par millésime sur `T_MCO{aa}B` 2019-2023 en dbplyr »
- « Ce script de `snds-query` échoue avec `ORA-00904` : voici le fichier et
  l'erreur »

## Confidentialité

Claude ne voit jamais de données individuelles : il reçoit des agrégats sous
seuil, sortis par la procédure d'export de la plateforme, seule juge de ce
qui sort. Un téléversement sur claude.ai est un transfert à un tiers,
acceptable pour ces agrégats seulement. Ici, Claude ne reçoit que la requête
ou le script collé, son message d'erreur et vos questions. Des données
individuelles collées (extrait de table, résultat à une ligne par séjour,
prestation ou décès) arrêtent la skill : elle ne cite rien, demande de les
retirer et rappelle que seule la procédure d'export de la plateforme fait
sortir des données.

## Adapter à un autre environnement que le Health Data Hub

Comme pour `snds-query` : la connaissance propre à l'environnement vit dans
`references/profils/`. Dupliquer `hdh_oracle.md`, adapter les valeurs, et la
skill l'utilise. Les patterns de `references/template/` contiennent des éléments
propres à Oracle (`REGEXP_LIKE`, `ora_date()`, limite des listes `IN`) à
adapter pour un autre SGBD.

## Mise à jour des références

Les références communes sont des copies, jamais partagées. Leur source est à
modifier là-bas avant de recopier ici :
[`snds-schema`](https://github.com/basilefuchs/skills/tree/main/skills/snds-schema)
pour le dictionnaire, `scripts/build-dictionary.py` et
`references/modele-donnees.md`,
[`snds-query`](https://github.com/basilefuchs/skills/tree/main/skills/snds-query)
pour le profil et le squelette de scripts. Voir la
[règle de copie](https://github.com/basilefuchs/skills/blob/main/CONTRIBUTING.md#références-communes-à-une-famille).
