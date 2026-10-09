# Contribuer

Une skill est un dossier autonome placé directement sous `skills/`, sans
sous-dossier de catégorie : chaque dossier de `skills/` est une skill. Il est
distribué seul (zip claude.ai, `npx skills`).

`check_skills.py` vérifie une partie des conventions ci-dessous : le
frontmatter (`name`, `description`), le nom du dossier et la présence d'au
moins une skill. La CI le lance à chaque push et à chaque PR ; le reste se
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
     le dossier de la skill (exemple : `skills/snds-query/NOTICE`).

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
