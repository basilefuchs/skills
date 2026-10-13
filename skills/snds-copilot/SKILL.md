---
name: snds-copilot
description: >
  Copilote d'une requête SNDS que l'utilisateur écrit lui-même (SQL Oracle,
  R dbplyr) sur le Health Data Hub : relecture d'une requête collée, table ou
  variable à trouver, fragment à écrire.
license: MIT
---

# Copilote de requête SNDS

L'utilisateur tient le clavier : il écrit sa requête SNDS (SQL Oracle ou R
dbplyr) sur le Health Data Hub et vient avec une requête à relire, une
question sur le dictionnaire ou une étape à écrire. Répondre directement,
sans protocole ni question de cadrage préalable ; une ambiguïté se signale en
une ligne dans la réponse, avec le choix retenu.

Une question de recherche en langage naturel (« combien de patients
diabétiques hospitalisés en 2023 ? ») relève de la skill `snds-query`, qui
clarifie le protocole avant d'écrire le script : le dire en une ligne et
s'arrêter là.

## Ressources

Ordre d'autorité : **filtres et méthodologie** — documentation officielle du
Health Data Hub > profil > autres références ; **environnement** (connexion,
schéma, nommage des tables) — profil seul. Les chemins sont relatifs au
répertoire de base de la skill.

1. **`references/profils/hdh_oracle.md`** — environnement réel : connexion,
   mapping concept → colonne validé, pièges, filtres qualité par défaut.
   Fait foi sur l'environnement. Autre environnement (export local, autre
   entrepôt) : demander une fois les équivalents à l'utilisateur et lui
   proposer d'écrire un nouveau profil dans ce répertoire.
2. **Documentation officielle du Health Data Hub**
   (https://documentation-snds.health-data-hub.fr/) — fait foi sur les
   filtres recommandés et la méthodologie, y compris contre le profil. La
   consulter via WebFetch, quand l'outil existe, en cas de doute sur un
   filtre ou pour un sujet absent des références locales (fiches
   `snds/fiches/`, schéma `snds/tables/`, liste des FINESS APHP/APHM/HCL de
   la fiche `2023-12-11_synthese_filtres_snds_v1`). Ses requêtes sont en
   MySQL : traduire pour Oracle (voir le profil). Sans accès web, le dire
   dans la réponse.
3. **Dictionnaire** `references/dictionnaire/` (TSV générés depuis le dépôt
   schema-snds du Health Data Hub, licence MPL-2.0) — tables, variables et
   millésimes, jointures déclarées, nomenclatures et leurs valeurs. Colonnes
   décrites dans son `README.md`. Version fraîche à chaque usage si le
   réseau le permet (voir « Dictionnaire »), sinon copie embarquée.
4. `references/modele-donnees.md` — modèle de données : produits, tables
   clés, chaînage patient, raccourcis de classification, pièges classiques.
5. `references/template.R` — patterns dbplyr/Oracle validés (étapes par
   millésime, patients uniques pluriannuels, jointure DCIR à 9 colonnes,
   batch sur `FLX_DIS_DTD`).

Les fichiers 1, 3, 4 et 5 sont copiés tels quels depuis `snds-query` : leurs
renvois à `clarifications.md`, `points-de-vigilance.md`, `template.Rmd` ou
aux étapes de `SKILL.md` visent cette autre skill et sont sans objet ici.

## Dictionnaire

Au premier besoin du dictionnaire dans la conversation, tenter un clone
partiel de schema-snds (environ 7 Mo) et régénérer les TSV dans un
répertoire temporaire, depuis le répertoire de base de la skill :

```bash
TMP=$(mktemp -d)
git clone -q --depth 1 --filter=blob:none --sparse \
  https://gitlab.com/healthdatahub/applications-du-hdh/schema-snds.git "$TMP/schema-snds" &&
git -C "$TMP/schema-snds" sparse-checkout set --no-cone '/schemas/' '/nomenclatures/*/*.json' '/LICENSE' &&
python3 scripts/build-dictionary.py "$TMP/schema-snds" --out "$TMP/dico" &&
D="$TMP/dico" || D=references/dictionnaire
echo "Dictionnaire utilisé : $D"; cat "$D/SOURCE.txt"
```

- Succès : `$D` pour `tables.tsv`, `variables.tsv`, `jointures.tsv`,
  `nomenclatures.tsv`. Les valeurs des nomenclatures restent dans
  `references/dictionnaire/valeurs.tsv` (le clone partiel ne les récupère
  pas).
- Échec : copie embarquée, et le dire dans la réponse avec la date de
  `references/dictionnaire/SOURCE.txt`.

Les TSV font jusqu'à 2 Mo : filtrer par `grep` ou `awk -F'\t'`, jamais de
lecture intégrale.

```bash
grep -i "ccam" $D/tables.tsv                                 # une table par notion ou par nom
awk -F'\t' '$1=="DCIR"' $D/tables.tsv                        # toutes les tables d'un produit
awk -F'\t' '$1=="T_MCOaaB" && $2=="DGN_PAL"' $D/variables.tsv   # une variable : type, nomenclature, millésimes
awk -F'\t' '$1=="ER_CAM_F"' $D/variables.tsv | cut -f2-10    # toutes les variables d'une table
awk -F'\t' '$2=="BEN_NIR_ANO"{print $1}' $D/variables.tsv    # toutes les tables portant une colonne
awk -F'\t' '$1=="ER_PRS_F" || $3=="ER_PRS_F"' $D/jointures.tsv   # jointures déclarées d'une table
awk -F'\t' '$1=="IR_SPE_V"' references/dictionnaire/valeurs.tsv  # codes et libellés d'une nomenclature
```

Lecture des millésimes : une variable existe de `debut` à `fin` (vide =
toujours présente) sauf les années de `absente`. Les tables PMSI portent un
nom générique en `aa` (`T_MCOaaB`) ; en base, l'année sur deux chiffres
(`T_MCO23B`). Nomenclature non embarquée (`valeurs_embarquees = non`, ex.
`IR_PHA_R`, CCAM, CIM-10) : interroger la table en base, ou le CSV source
`https://gitlab.com/healthdatahub/applications-du-hdh/schema-snds/-/raw/master/nomenclatures/<ORAVAL|ORAREF>/<NOM>.csv`.
Table absente de schema-snds (`ER_GEO_LOC_R`, archives `*_ARC`, `T_SUP*`) :
le profil quand il la décrit, sinon la documentation officielle, en
signalant « non vérifié dans le dictionnaire ».

## Mode consultation

L'utilisateur cherche une table, une variable, un millésime, une
nomenclature, une jointure ou un filtre. Répondre avec le fait demandé et sa
source (dictionnaire, profil ou documentation officielle), puis ce que
l'utilisateur en fera : la colonne à filtrer, la jointure à écrire, le piège
attaché. Exemples :

- « Quelle table pour les actes CCAM en ville ? » → `ER_CAM_F`, code CCAM
  dans `CAM_PRS_IDE` (`CAM_ACT_COD` est le code activité), jointure à
  `ER_PRS_F` sur la clé technique à 9 colonnes, un acte = triplet
  `CAM_PRS_IDE` + `CAM_ACT_COD` + `CAM_TRT_PHA`.
- « `FP_PEC` existe-t-il en 2023 ? » → millésimes de `variables.tsv`, et la
  rupture SMR du profil : plus codé après le 01/03/2023.
- « Que vaut `DPN_QLF = 71` ? » → libellé dans `valeurs.tsv` si la
  nomenclature est embarquée, sinon la requête Oracle sur la table de
  valeurs.

Réponse courte : le fait, la source, la conséquence pour la requête. La
réponse est complète quand chaque table, colonne et millésime cités ont été
lus dans le dictionnaire ou le profil, pas de mémoire.

## Règles communes

- **Vérification** : chaque table, colonne et millésime nommés dans une
  réponse sont lus dans le dictionnaire ou le profil ; citer la source du
  dictionnaire utilisée (schema-snds frais ou copie embarquée datée).
- **Langage** : la réponse est dans le langage de l'entrée (SQL Oracle ou
  R dbplyr). SAS se lit (un script existant collé) et se traduit en R dbplyr
  sur demande ; la skill n'écrit jamais de SAS. Le style historique
  `glue()` + chaîne SQL brute se lit et se relit tel quel.
- **Données individuelles collées** (résultats, extraits de table) :
  traiter la requête normalement et rappeler en une ligne que les données
  individuelles du SNDS ne se collent pas hors de l'environnement.
- **Confidentialité des sorties** : secret statistique (aucune cellule de 1
  à 10, seuil 11) dès que l'utilisateur annonce une diffusion ; jamais
  d'écriture locale d'identifiants, de dates ou de localisations
  individuelles.
