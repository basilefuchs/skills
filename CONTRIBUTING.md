# Contribuer

Une skill est un dossier `skills/<nom>/` autonome : il est distribué seul (zip
claude.ai, `npx skills`) aussi bien qu'à travers la marketplace Claude Code.
`check_skills.py` vérifie les conventions ci-dessous ; la CI le lance à chaque
push et à chaque PR.

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

   - `<nom>` est identique au nom du dossier : minuscules, chiffres et tirets
     simples, 64 caractères au plus.
   - La `description` fait 200 caractères au plus (limite de claude.ai). Elle
     reste en bloc `>` : un « : » de la typographie française dans une valeur
     sur une ligne, sans guillemets, rend le frontmatter invalide.
   - Les ressources de la skill vont dans son dossier (`references/`,
     `scripts/`, `assets/`), et la skill y fait référence par des chemins
     relatifs à ce dossier.
   - Un contenu tiers sous une autre licence est signalé par un `NOTICE` dans
     le dossier de la skill (exemple : `skills/snds-query/NOTICE`).

2. **Écrire `skills/<nom>/README.md`** : à quoi sert la skill, ses prérequis,
   et son utilisation (`/<nom>:<nom>` en plugin Claude Code, `/<nom>` en skill
   copiée, déclenchement par la description sur claude.ai). Les liens vers le
   reste du dépôt sont des URL complètes, puisque le README voyage avec la
   skill.

3. **Déclarer le plugin** dans `.claude-plugin/marketplace.json`, une entrée
   par skill, sans champ `version` (chaque commit sur `main` est une version) :

   ```json
   {
     "name": "<nom>",
     "source": "./",
     "description": "<la description du SKILL.md, à l'identique>",
     "skills": ["./skills/<nom>"],
     "keywords": ["<mot-clé>", "<mot-clé>"]
   }
   ```

4. **Ajouter la skill au catalogue** du `README.md` racine.

5. **Vérifier**, depuis la racine du dépôt (Python 3, rien à installer) :

   ```
   python3 check_skills.py
   python3 -m unittest discover -s tests
   ```

   La skill est prête quand `check_skills.py` affiche « OK » et que les tests
   passent ; la CI de la PR doit être verte. Avec Claude Code installé,
   `claude plugin validate .` contrôle aussi le manifeste.

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
