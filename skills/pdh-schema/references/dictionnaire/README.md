# Dictionnaire des variables du portail ATIH

`variables.csv` : export du dictionnaire des variables du portail ATIH, des
métadonnées sans aucune donnée patient. Date et provenance : `SOURCE.txt`.

CSV UTF-8 séparé par `;`, champs texte entre guillemets, en-tête :

```
librairie;table;var;libelle;andeb;anfin;jointure;commentaire;type;longueur;droits
```

- `librairie` : le champ et un millésime générique, `xx` pour l'année
  (`mcoxxbd`, `ssrxxbd`, `hadxxbd`, `psyxxbd`, `rpuxx`) ; en base, le schéma
  annuel du profil (`prd_vue_mcobl_2023`).
- `andeb`, `anfin` : première et dernière année de présence de la variable,
  sur deux chiffres (`16` = 2016) ; `NA` pour un référentiel non millésimé
  (`nom_pmsi`, `nom_gen`).
- Des `libelle` et des `commentaire` contiennent des retours à la ligne : un
  enregistrement peut occuper jusqu'à huit lignes. Une ligne d'enregistrement
  commence par `"` ; une ligne de continuation, non. Quand `andeb` manque sur
  la ligne trouvée, lire les lignes suivantes jusqu'à la prochaine qui
  commence par `"`.
- Le fichier fait 1 Mo, les champs se suivent par librairie (HAD, MCO, PSY,
  SSR, RPU) : filtrer par `grep`, jamais de lecture intégrale ni tronquée.

```bash
grep '^"mcoxxbd";"fixe"' variables.csv | cut -d';' -f3,4                  # variables d'une table
grep -i 'diagnostic principal' variables.csv | cut -d';' -f1-4            # une notion dans les libellés
grep '^"mcoxxbd";"fixe";"date_entree"' variables.csv | cut -d';' -f3,5,6  # années d'une variable
grep '^"ssrxxbd";' variables.csv | cut -d';' -f2 | sort -u               # tables d'un champ
```

Mise à jour : exporter le dictionnaire des variables depuis le portail ATIH
(export natif en Windows-1252), le convertir, puis mettre la date dans
`SOURCE.txt` :

```
iconv -f WINDOWS-1252 -t UTF-8 export.csv > variables.csv
```
