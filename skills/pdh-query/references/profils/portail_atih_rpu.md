# Profil — Portail ATIH / RPU (urgences)

> **Profil partiel** : le schéma réel n'a pas encore été vérifié sur le portail.
> Avant toute génération, confirmer le nom du schéma avec l'utilisateur (ou via le
> dictionnaire) et compléter ce profil.

| Méta              | Valeur                                      |
|-------------------|---------------------------------------------|
| Base              | Portail ATIH (Plateforme données hospit.)   |
| SGBD              | Teradata (via dbplyr)                       |
| Connexion         | `pRatihque::connection_database()`          |
| Schéma annuel     | `prd_vue_rpu_AAAA` [à confirmer]            |
| Librairie dico    | `rpuxx`                                     |
| Unité de compte   | Passage aux urgences (pas de chaînage patient) |

## `passage` — 1 ligne / passage

| Concept                    | Colonne       |
|----------------------------|---------------|
| Diagnostic principal       | `dp`          |
| Motif de recours           | `motif`       |
| Âge                        | `age`         |
| Sexe                       | `sexe`        |
| Gravité (CCMU)             | `gravite`     |
| Orientation en sortie      | `orientation` |

## Pièges

| Piège                                   | Traitement                                  |
|-----------------------------------------|---------------------------------------------|
| Pas de clé de chaînage patient          | Comptage en **passages** uniquement         |
| Couverture non exhaustive selon années  | Le signaler dans la note méthodologique     |

## Défauts recommandés

| Paramètre                 | Valeur                          |
|---------------------------|---------------------------------|
| Géographie                | France entière (couverture partielle : interpréter avec prudence) |
