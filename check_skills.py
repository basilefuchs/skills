#!/usr/bin/env python3
"""Vérifie qu'un dépôt de skills respecte les conventions de CONTRIBUTING.md.

Usage : python3 check_skills.py [racine du dépôt]   (par défaut : répertoire courant)

Affiche une ligne par violation, « <règle> <sujet> : <détail> », et sort avec
le code 1 s'il y en a au moins une, 0 sinon. Bibliothèque standard uniquement.
"""

import json
import re
import sys
from pathlib import Path

MARKETPLACE = Path(".claude-plugin") / "marketplace.json"
SKILLS_DIR = "skills"
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
NESTED_RE = re.compile(r"^(- |[\w-]+:)")


def parse_frontmatter(text):
    """Renvoie le dict des clés de premier niveau, ou None sans frontmatter.

    Sous-ensemble YAML : `clé: valeur`, éventuellement prolongée par des lignes
    indentées (dépliées), blocs `>` (dépliés) et `|` (lignes conservées),
    valeurs entre guillemets, et clés suivies d'une liste ou d'un dictionnaire
    imbriqué (valeur ignorée). Lève ValueError pour une valeur non citée
    contenant « : », que YAML refuse.
    """
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    end = next((i for i in range(1, len(lines)) if lines[i].strip() == "---"), None)
    if end is None:
        return None

    fields = {}
    body = lines[1:end]
    i = 0
    while i < len(body):
        line = body[i]
        i += 1
        if not line.strip() or line[0] in " \t#" or ":" not in line:
            continue
        key, value = (part.strip() for part in line.split(":", 1))
        block = []
        while i < len(body) and (not body[i].strip() or body[i][0] in " \t"):
            block.append(body[i].strip())
            i += 1
        first = next((part for part in block if part), "")
        if value.startswith("|"):
            value = "\n".join(block).strip("\n")
        elif value.startswith(">"):
            value = " ".join(part for part in block if part)
        elif not value and NESTED_RE.match(first):
            value = ""
        else:
            value = " ".join(part for part in [value, *block] if part)
            if value[:1] in "'\"":
                value = value[1:-1] if len(value) >= 2 and value[-1] == value[0] else value[1:]
            elif ": " in value or value.endswith(":"):
                raise ValueError(f"« {key} » : valeur non citée contenant « : », YAML invalide")
        fields[key] = value
    return fields


def check_skill(skill_dir):
    """Violations propres à un dossier de skill."""
    subject = f"{SKILLS_DIR}/{skill_dir.name}"
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        return [("skill-md", subject, "SKILL.md absent")]

    try:
        fields = parse_frontmatter(skill_md.read_text(encoding="utf-8-sig"))
    except UnicodeDecodeError:
        return [("frontmatter", subject, "SKILL.md n'est pas en UTF-8")]
    except ValueError as error:
        return [("frontmatter", subject, str(error))]
    if fields is None:
        return [("frontmatter", subject, "SKILL.md ne commence pas par un frontmatter délimité par ---")]

    violations = []
    missing = [key for key in ("name", "description") if not fields.get(key)]
    if missing:
        violations.append(("champs-requis", subject, f"champ(s) manquant(s) : {', '.join(missing)}"))
    name, description = fields.get("name", ""), fields.get("description", "")
    if name and (len(name) > 64 or not NAME_RE.match(name)):
        violations.append(("name-format", subject,
                           f"name « {name} » : 1 à 64 caractères, minuscules, chiffres et tirets simples"))
    if name and name != skill_dir.name:
        violations.append(("name-dossier", subject, f"name « {name} » différent du dossier « {skill_dir.name} »"))
    if len(description) > 200:
        violations.append(("description-200", subject, f"description de {len(description)} caractères (200 au plus)"))
    return violations


def load_entries(root):
    """Entrées de plugin du manifeste, ou une violation s'il est absent ou invalide."""
    path = root / MARKETPLACE
    if not path.is_file():
        return None, [("marketplace-json", str(MARKETPLACE), "manifeste absent")]
    try:
        manifest = json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, UnicodeDecodeError) as error:
        return None, [("marketplace-json", str(MARKETPLACE), f"JSON invalide : {error}")]
    plugins = manifest.get("plugins") if isinstance(manifest, dict) else None
    if not isinstance(plugins, list) or not all(isinstance(p, dict) for p in plugins):
        return None, [("marketplace-json", str(MARKETPLACE), "« plugins » doit être une liste d'objets")]
    return plugins, []


def check_entries(root, entries, skill_names):
    """Violations entre les entrées du manifeste et les dossiers de skills."""
    violations = []
    listed = {name: 0 for name in skill_names}
    for entry in entries:
        subject = f"entrée « {entry.get('name', '?')} »"
        paths = entry.get("skills")
        paths = [paths] if isinstance(paths, str) else paths
        if not isinstance(paths, list) or len(paths) != 1 or not isinstance(paths[0], str):
            violations.append(("entree-sans-skill", subject, "« skills » doit lister exactement un chemin"))
            continue
        match = re.fullmatch(r"\./skills/([^/]+)/?", paths[0])
        if not match:
            violations.append(("entree-sans-skill", subject, f"chemin « {paths[0]} » hors de ./skills/<nom>"))
            continue
        folder = match.group(1)
        if not (root / SKILLS_DIR / folder / "SKILL.md").is_file():
            violations.append(("entree-sans-skill", subject, f"{paths[0]} n'existe pas ou n'a pas de SKILL.md"))
        if entry.get("name") != folder:
            violations.append(("entree-nom", subject, f"nom différent du dossier « {folder} »"))
        if folder in listed:
            listed[folder] += 1

    for name, count in listed.items():
        if count != 1:
            violations.append(("skill-sans-entree", f"{SKILLS_DIR}/{name}",
                               f"listée par {count} entrée(s) de marketplace au lieu d'une"))
    return violations


def check_repo(root):
    skill_dirs = sorted(p for p in (root / SKILLS_DIR).glob("*") if p.is_dir()) if (root / SKILLS_DIR).is_dir() else []
    violations = [v for skill_dir in skill_dirs for v in check_skill(skill_dir)]
    entries, manifest_violations = load_entries(root)
    violations += manifest_violations
    if entries is not None:
        violations += check_entries(root, entries, [p.name for p in skill_dirs])
    return violations


def main(argv):
    root = Path(argv[1]) if len(argv) > 1 else Path.cwd()
    violations = check_repo(root)
    for rule, subject, detail in violations:
        print(f"{rule} {subject} : {detail}")
    if not violations:
        print("OK : toutes les skills respectent les conventions.")
    return 1 if violations else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
