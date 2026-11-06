---
name: ght-dev
description: >
  Développe un indicateur de pilotage hospitalier GHT (nom ou candidat
  compressé [i,d,c,u,l,t,s]) en fiche markdown complète, références
  vérifiées, écrite dans indicateurs_pmsi/<catégorie>/.
license: MIT
---

Tu développes un indicateur de pilotage hospitalier pour un GHT, calculable
depuis le PMSI ou le SNDS, en fiche markdown complète, au niveau de rigueur
des deux fiches de `references/exemples/`. Les lire avant de rédiger.

## Entrée

Un nom d'indicateur, ou un candidat compressé `[i:…] [d:…] [c:…] [u:…]
[l:…] [t:…] [s:…]`, éventuellement suivi d'options :

```
--cat <NN>                force la catégorie (voir Chemin de fichier)
--write                   écrit la fiche sans demander confirmation
--no-web                  pas de recherche (hors ligne)
--since <AAAA>            recherche restreinte aux publications depuis cette année (défaut : année courante - 5)
--depth <quick|deep>      quick = une passe PubMed et une passe ATIH ; deep = les trois volets (défaut)
```

Sans indicateur, le demander en une question.

## Recherche ciblée

Sauf `--no-web`, et si un outil de recherche web ou PubMed est disponible,
rechercher avant de rédiger et produire une synthèse de 5 à 10 puces
sourcées (PMID ou URL). Sans outil de recherche, l'écrire en tête de
réponse et rédiger depuis les connaissances du modèle, sans aucune
référence inventée.

- **A. Méthode** (PubMed) : nom conceptuel de l'indicateur et dimension
  (« Shannon entropy case-mix », « readmission risk-adjusted DRG ») ;
  revues cibles : Health Services Research, Medical Care, BMC Health
  Services Research, Revue d'épidémiologie et de santé publique, Journal of
  Epidemiology and Community Health. Alimente Définition, Limites,
  Références (3 à 6 articles vérifiés).
- **B. Réglementaire et technique** (recherche web) : guide méthodologique
  PMSI en vigueur et fichier des variables (ATIH), indicateurs nationaux
  (HAS) si l'indicateur touche la qualité, restitutions publiques
  (ScanSanté, DREES) pour les plages de valeurs. Alimente Sources de
  données et Exemple de valeurs.
- **C. Anti-doublon** (recherche web) : l'indicateur, ou un proche cousin,
  existe-t-il déjà sous un autre nom ? Alimente le positionnement de la
  Définition.

Si une veille a déjà été faite dans la session sur le même domaine, la
réutiliser et ne lancer que les recherches propres à l'indicateur.

## Vérification des références

Un DOI écrit de mémoire est plausible et faux à quelques caractères près.
**Aucun DOI, PMID, URL ni nom de variable PMSI n'entre dans la fiche sans
avoir été vérifié dans la session.** Une variable non confirmée est marquée
`[à confirmer]`.

Par référence :

1. **Trouver l'article, pas le DOI** : recherche PubMed (titre, auteur) ou
   Crossref :
   ```bash
   curl -s "https://api.crossref.org/works?rows=3&query.bibliographic=<titre+auteurs+année>"
   ```
   Prendre le DOI renvoyé par l'API, à condition d'une concordance forte
   titre, premier auteur et année. Le score Crossref ne garantit rien (il
   peut pointer un erratum ou un commentaire de même titre).
2. **Valider que le DOI résout**, par le résolveur officiel et non la page
   éditeur (qui renvoie 403 aux robots) :
   ```bash
   curl -s "https://doi.org/api/handles/<DOI>" | python3 -c "import sys,json;print(json.load(sys.stdin).get('responseCode'))"
   ```
   `1` : le DOI existe. `100` : DOI faux, revenir à l'étape 1. Ne pas
   tronquer un DOI à la première parenthèse
   (`10.1016/S0140-6736(12)60240-2`).
3. **Pas de DOI** (chapitre, rapport ATIH ou DREES, article ancien) : lien
   PubMed avec PMID vérifié, ou citation texte complète sans lien, ou URL
   officielle vérifiée. Jamais de DOI inventé pour combler.

URL : vérifier avec un User-Agent de navigateur en suivant les
redirections :
```bash
curl -sIL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/124 Safari/537.36" -o /dev/null -w "%{http_code}" "<url>"
```
Garder si `2xx` ou `3xx`. Un `403`, `429` ou délai dépassé n'est pas un
lien mort : beaucoup de sites vivants bloquent les robots. Seuls `404`,
`410` ou un domaine inexistant justifient une correction. Préférer une page
stable (racine de section) à un lien profond daté.

## Format de la fiche

```markdown
# <Titre de l'indicateur>

## Définition
[Concept, formule mathématique, positionnement vs indicateurs existants, pourquoi c'est nouveau]

## Calcul
[Source PMSI ou SNDS, pseudocode en blocs de code, étapes numérotées, indicateurs dérivés si pertinents]

## Utilité
[5 à 7 cas d'usage concrets pour le pilotage GHT, avec valeurs de référence si possible]

## Sources de Données
[Tables PMSI ou SNDS précises, variables utilisées, référentiels ATIH nécessaires]

## Exemple de Valeurs
[Plages réalistes par type d'établissement ou contexte, seuils d'alerte]

## Limites
[Biais, conditions d'interprétation, seuils minimaux, limites de comparabilité]

## Références
[Citations académiques avec DOI vérifié, références ATIH, sources officielles]
```

## Règles qualité

- **Définition** : concept mathématique ou scientifique source, pourquoi
  les indicateurs PMSI courants ne capturent pas cette information, formule
  symbolique.
- **Calcul** : variables PMSI exactes, pseudocode en blocs de code,
  conventions des cas limites (division par zéro, valeurs manquantes).
- **Utilité** : cas d'usage opérationnels propres au GHT, pas de
  généralités.
- **Sources de données** : variables nommées selon le guide ATIH en
  vigueur confirmé pendant la recherche, pas selon les habitudes du modèle.
- **Exemple de valeurs** : plages par type d'établissement (CHU, CH,
  clinique) avec des chiffres, chaque plage sourcée (restitution ScanSanté,
  panorama DREES) ou marquée « ordre de grandeur expert, non sourcé ».
- **Limites** : seuils minimaux de volume, effets de version PMSI, biais
  d'interprétation.
- **Références** : par entrée, un DOI issu d'une API et validé
  (`responseCode` 1), ou un PMID vérifié, ou une citation sans lien, ou
  une URL officielle vérifiée.

## Rejets

DOI de mémoire ou vérifié seulement par la page éditeur ; DOI à
`responseCode` 100 ou discordant (titre, auteur, année) ; DOI inventé pour
un document qui n'en a pas ; lien remplacé alors qu'il n'était que bloqué ;
plage de valeurs sans source ni mention « ordre de grandeur expert » ;
recherche omise sans `--no-web` alors qu'un outil est disponible.

## Chemin de fichier

```
indicateurs_pmsi/<NN>_<categorie>/<nom_snake_case>.md
```

Les catégories sont les sous-dossiers de `indicateurs_pmsi/` du répertoire
courant, s'il existe. Sinon, créer le dossier avec la catégorie choisie
parmi les dix par défaut :

```
01_activite_production
02_casemix_patientele
03_vulnerabilite_sociale
04_efficience_capacitaire
05_qualite_securite
06_pertinence_pratiques
07_parcours_continuite
08_readmissions_evitables
09_territoire_attractivite
10_financement_valorisation
```

Sans `--write`, montrer la fiche et le chemin, et demander confirmation
avant d'écrire. Sur une plateforme sans écriture de fichier, livrer la
fiche dans la réponse avec son chemin.
