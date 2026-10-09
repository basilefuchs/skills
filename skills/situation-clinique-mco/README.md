# situation-clinique-mco

Skill qui classe un compte rendu d’hospitalisation MCO dans sa situation clinique PMSI, selon le guide méthodologique MCO de l’ATIH, et argumente le choix du DP et du DR.

## Contenu

- `SKILL.md` : la skill (démarche, arbre de décision, gabarit de réponse, référentiel).

## Usage

Coller le CRH ou la lettre de liaison : la skill se déclenche d’elle-même sur sa description. On peut aussi l’invoquer explicitement :

- dans LibreChat, avec l’agent branché sur le vLLM local : `$situation-clinique-mco` ;
- copiée comme skill dans Claude Code (`~/.claude/skills/` ou `.claude/skills/`) : `/situation-clinique-mco`.

Installation : voir le [README du dépôt](https://github.com/basilefuchs/skills).

**Les CR réels passent uniquement par l’agent local** ; Claude sert à la mise au point sur des CR fictifs. La réponse est une aide au codage : la décision reste au codeur et au médecin DIM.

## Périmètre

- Entrée : un CRH ou une lettre de liaison d’un seul séjour MCO.
- Analyse : le RUM de l’UM émettrice du CR.
- Réponse : recevabilité, cheminement (chaque étape appuyée sur un extrait du CR), conclusion (situation, section, règle citée, DP, DR, diagnostics associés désignés par la règle), incertitudes.
- Hors champ : SMR, HAD, PSY ; vérification des conditions d’admission en hospitalisation ; codage CIM-10 libre ; règles des autres chapitres du guide, signalées « DP selon chapitre X ».

## Référentiel

Guide méthodologique de production des informations relatives à l’activité médicale et à sa facturation en médecine, chirurgie, obstétrique et odontologie, 2026, version définitive applicable au 1er janvier 2026 : chapitre VI (Guide des situations cliniques) et définitions du DP et du DR du chapitre IV (points 1.1 et 1.2). Énoncés et exemples repris mot pour mot ; les arbitrages propres à la skill sont marqués « Convention de la skill ».

À chaque nouveau guide : remplacer les extraits du référentiel et le millésime dans `SKILL.md`.
