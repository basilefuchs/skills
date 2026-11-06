# Contribuer

Une skill est un dossier autonome placé directement sous `skills/`, sans
sous-dossier de catégorie : chaque dossier de `skills/` est une skill. Il est
distribué seul (zip claude.ai, `npx skills`).

`check_skills.py` vérifie une partie des conventions ci-dessous : le
frontmatter (`name`, `description`), le nom du dossier, la présence d'au
moins une skill et la ligne au catalogue du README racine.
`tests/test_sync_familles.py` vérifie la règle de copie des références
communes, `tests/test_contrat_sorties.py` le contrat
`sorties/` dans les squelettes de scripts des deux bases. La CI lance le
vérificateur et tous les tests à chaque push et à chaque PR ; le reste se
relit à la main.

## Ajouter une skill

1. **Créer `skills/<nom>/SKILL.md`**, qui commence par ce frontmatter :

   ```
   ---
   name: <nom>
   description: >
     <ce que fait la skill et quand l'utiliser>
   license: MIT
   ---
   ```

   - `<nom>` est identique au nom du dossier : minuscules, chiffres et tirets,
     sans tiret au début, à la fin ni deux tirets de suite, 64 caractères au
     plus (format du standard Agent Skills).
   - La `description` fait 200 caractères au plus (limite de claude.ai). Elle
     reste en bloc `>` : un « : » de la typographie française dans une valeur
     sur une ligne, sans guillemets, rend le frontmatter invalide.
   - Les ressources de la skill vont dans son dossier (`references/`,
     `scripts/`, `assets/`), et la skill y fait référence par des chemins
     relatifs à ce dossier.
   - Un contenu tiers sous une autre licence est signalé par un `NOTICE` dans
     le dossier de la skill (exemple : `skills/snds-schema/NOTICE`).

2. **Écrire `skills/<nom>/README.md`** : à quoi sert la skill, ses prérequis,
   et son utilisation (`/<nom>` en skill copiée, déclenchement par la
   description sur claude.ai). Les liens vers le reste du dépôt sont des URL
   complètes, puisque le README voyage avec la skill.

3. **Ajouter la skill au `README.md` racine** : une ligne au catalogue.

4. **Vérifier**, depuis la racine du dépôt (Python 3, rien à installer) :

   ```
   python3 check_skills.py
   python3 -m unittest discover -s tests
   ```

   La skill est prête quand les étapes 1 à 3 sont faites, que
   `check_skills.py` affiche « OK » et que les tests passent ; la CI de la PR
   doit être verte.

## Références communes à une famille

Une skill est distribuée seule : une référence utile à plusieurs skills est
copiée dans chacune, jamais partagée par un chemin vers une autre skill.

Une famille réunit les skills de même préfixe, le premier segment du nom
(`snds-`, `pdh-`). Deux skills d'une famille qui ont un fichier au même chemin
relatif sous `references/` ou `scripts/` l'ont identique octet à octet.

Pour modifier un fichier copié, l'éditer dans sa source, puis le recopier dans
les skills de la famille qui en portent une copie. Le README de la skill qui
porte des copies nomme leur source (`snds-copilot` : `snds-schema` et
`snds-query`).

```
cp skills/snds-query/references/profils/hdh_oracle.md skills/snds-copilot/references/profils/hdh_oracle.md
```

`tests/test_sync_familles.py` lit le dépôt et échoue sur chaque divergence :
il nomme les deux fichiers et donne la commande `cp` dans les deux sens, sans
désigner la source ; appliquer celle qui va de la source, nommée dans le README,
vers la copie. Aucune liste à tenir : un fichier copié sous le même chemin
relatif entre dans le test de lui-même.

## Chaîne de skills

Les skills du parcours (`to-protocole`, skills schema, skills query) se
relaient par un fichier unique, `protocole.md`, à la racine du répertoire de
l'étude. Une skill de la chaîne suit ces conventions.

**Sections de `protocole.md`.** Un titre exact par section, un seul
propriétaire par section, pas de gabarit partagé : chaque SKILL.md nomme les
sections qu'il écrit.

| Propriétaire | Sections écrites |
| --- | --- |
| `to-protocole` | `# Introduction`, `# Matériels & Méthode`, `# Limites` |
| skills schema (`snds-schema`, `pdh-schema`) | `# Données`, remplacée si elle existe |
| skills query (`snds-query`, `pdh-query`) | aucune : les scripts sont le livrable |

Le fichier ne contient jamais un effectif : les chiffres vivent dans
`sorties/`.

**Découverte sans argument.** Le protocole est `protocole.md` dans le
répertoire courant, ou le fichier fourni (téléversé sur claude.ai). Sans
accès au fichier, la skill livre dans sa réponse ce qu'elle aurait écrit.

**Câblage.** Les skills ne nomment pas l'étape suivante : le parcours du
README racine et les README des skills le font. Le ticket qui crée une skill
de la chaîne l'y ajoute, avec sa ligne au catalogue.

**Contrat `sorties/`.** Les scripts générés n'écrivent de fichier que par
`exporter()`, définie dans `00_setup.R` des deux squelettes (chunk `setup`
du `.Rmd`), sous des noms et des colonnes fixes, les mêmes pour les deux
bases : `flowchart.csv`, `resultat_annuel.csv`, `nb_patients_periode.csv`,
`strate_<variable>.csv`, `figure_resultat_annuel.png` et `manifeste.md`.
`tests/test_contrat_sorties.py` vérifie les squelettes : `exporter()`
définie une seule fois, appelée par le flowchart et les sorties, aucune
autre écriture de fichier, noms du contrat présents.

## Modifier le script de vérification

Toute nouvelle règle reçoit un identifiant stable, repris en tête de chaque
message, et au moins un test dans `tests/test_check_skills.py` qui attend cet
identifiant et le nom de la skill, jamais le libellé exact du message.

## Publier une release

Depuis `main` à jour, poser un tag `vX.Y.Z` et le pousser :

```
git tag v0.2.0
git push origin v0.2.0
```

Le workflow de release crée la release GitHub du tag, avec un zip par skill
prêt à téléverser sur claude.ai.
