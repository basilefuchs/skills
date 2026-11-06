---
name: ght-gen
description: >
  Génère des candidats d'indicateurs de pilotage hospitalier GHT calculables
  depuis le PMSI ou le SNDS, en format compressé [i,d,c,u,l,t,s], pour
  explorer un domaine avant de développer une fiche.
license: MIT
---

Tu génères des candidats d'indicateurs de pilotage hospitalier pour un GHT,
calculables depuis le PMSI (MCO, SMR, HAD, psychiatrie) ou le SNDS, en
format compressé, pour une sélection rapide avant développement d'une fiche
complète.

## Entrée

Un domaine (`parcours`, `efficience`, `territoire`…), éventuellement précédé
d'une transformation (`entropy casemix`) et suivi d'options :

```
<domaine>                 5 candidats sur le domaine
<transform> <domaine>     ciblé par transformation
--n <nb>                  nombre de candidats (défaut 5)
--lvl <niveau>            granularité cible : rsa, ghm, cmd, um, finess, temps
--excl                    exclure les indicateurs déjà présents dans indicateurs_pmsi/
--no-web                  pas de veille (hors ligne)
--since <AAAA>            veille restreinte aux publications depuis cette année (défaut : année courante - 2)
```

Sans domaine, le demander en une question.

## Existant

Avec `--excl`, lire les titres des fiches `indicateurs_pmsi/**/*.md` du
répertoire courant, s'il existe, et écarter tout candidat qui en reformule
une. Sans ce répertoire, l'option est sans effet. Dans tous les cas, ne pas
proposer deux candidats qui se recouvrent.

## Veille préalable

Sauf `--no-web`, et si un outil de recherche web ou PubMed est disponible,
faire une veille ciblée sur le domaine avant de générer, et la restituer en
3 à 8 puces datées et sourcées (URL ou PMID) juste avant la liste. Sans
outil de recherche, écrire « Veille : outil de recherche indisponible » et
générer depuis les connaissances du modèle, avec `s:interne` partout.

Sources officielles à privilégier : ATIH (`atih.sante.fr`), HAS
(`has-sante.fr`), DGOS (`sante.gouv.fr`), IRDES (`irdes.fr`), DREES
(`drees.solidarites-sante.gouv.fr`), ScanSanté (`scansante.fr`). Côté
PubMed : mots-clés du domaine avec `"hospital indicator" OR "case-mix" OR
"PMSI" OR "DRG" OR "quality measure"`, fenêtre de 24 mois par défaut.

Si rien de pertinent n'émerge : « Veille : aucune nouveauté pertinente sur
<domaine> ». Ne pas relancer la veille pour un domaine déjà traité dans la
session. Beaucoup de sites institutionnels français refusent les robots
(403) : un 403 ou un délai dépassé ne signifie pas que la page est morte ;
chercher l'URL par la recherche web plutôt que par un téléchargement direct.

**Aucune URL, aucun PMID, aucune attribution `auteur année` de mémoire.**
Une citation vient d'un résultat obtenu dans la session, sinon elle n'est
pas écrite.

## Format de sortie

Un candidat par ligne numérotée :

```
N. [i:<nom_snake_case>] [d:<définition en une phrase>] [c:<formule compacte>] [u:<usage clé>] [l:<limite principale>] [t:<cadre théorique | auteur année>] [s:<URL courte | PMID:xxxxx | interne>]
```

- `t:` nomme par défaut le cadre théorique ou la discipline source
  (`t:théorie de l'information`, `t:files d'attente`). Un `auteur année`
  n'y figure que si l'article a été confirmé pendant la veille, et `s:`
  porte alors son PMID ou son URL.
- `s:interne` : candidat issu des connaissances du modèle, sans attribution
  à un article précis.

Ces champs sont provisoires : la skill qui développe la fiche revalide chaque
référence avant de l'inscrire.

## Règles de génération

- Un candidat = 1 type + 1 dimension + 1 niveau, plus une transformation
  facultative.
- Types : `rate(A/B)`, `flow(nb/t)`, `delay(t2-t1)`, `dur(sum(t)/n)`,
  `occ(used/cap)`.
- Transformations : `entropy`, `concentration`, `variance`, `distance`,
  `network`, `control`.
- Dimensions : activité, qualité, parcours, efficience, réadmissions,
  organisation, territoire, financement.
- Données PMSI ou SNDS uniquement : le candidat doit être calculable avec
  une formule opérationnelle. Une analogie sans formule est rejetée.
- Une adaptation d'un cadre scientifique d'une autre discipline est
  bienvenue si la formule tient sur les données.

## Rejets

Non calculable depuis le PMSI ou le SNDS ; formule vague ; doublon
conceptuel avec l'existant ; source non vérifiée ; `auteur année` non
confirmé par la veille ; veille omise sans `--no-web` alors qu'un outil de
recherche est disponible.

## Sortie

La veille, puis la liste numérotée, puis une ligne : « Sélectionner un ou
plusieurs numéros pour développer la fiche. » Rien n'est écrit sur disque.
