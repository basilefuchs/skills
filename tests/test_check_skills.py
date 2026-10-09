"""Tests de check_skills.py, appelé comme en CI sur de petits dépôts d'exemple.

Les tests ne vérifient que le code de sortie, l'identifiant de règle et le nom
de la skill ou de l'entrée dans la sortie, jamais le libellé des messages.

Lancement : python3 -m unittest discover -s tests
"""

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

CHECK = Path(__file__).resolve().parent.parent / "check_skills.py"

FOLDED_DESCRIPTION = "description: >\n  Fait une chose précise,\n  sur plusieurs lignes.\n"


def frontmatter(name, description="description: Fait une chose précise.\n"):
    return f"---\nname: {name}\n{description}license: MIT\n---\n\n# {name}\n"


def entry(name, path=None):
    return {"name": name, "source": "./", "skills": [path or f"./skills/{name}"]}


class CheckSkillsTest(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)

    def tearDown(self):
        self._tmp.cleanup()

    def add_skill(self, folder, skill_md):
        (self.root / "skills" / folder).mkdir(parents=True)
        if skill_md is not None:
            (self.root / "skills" / folder / "SKILL.md").write_text(skill_md, encoding="utf-8")

    def write_marketplace(self, entries=None, raw=None):
        path = self.root / ".claude-plugin" / "marketplace.json"
        path.parent.mkdir(exist_ok=True)
        if raw is None:
            raw = json.dumps({"name": "test", "owner": {"name": "Test"}, "plugins": entries or []})
        path.write_text(raw, encoding="utf-8")

    def valid_repo(self):
        self.add_skill("alpha", frontmatter("alpha", FOLDED_DESCRIPTION))
        self.add_skill("beta", frontmatter("beta"))
        self.write_marketplace([entry("alpha"), entry("beta")])

    def run_check(self):
        result = subprocess.run([sys.executable, str(CHECK), str(self.root)],
                                capture_output=True, text=True, encoding="utf-8")
        return result.returncode, result.stdout

    def assertViolation(self, rule, subject):
        code, out = self.run_check()
        self.assertNotEqual(code, 0, out)
        lines = [line for line in out.splitlines() if line.startswith(rule + " ")]
        self.assertTrue(any(subject in line for line in lines), f"{rule} / {subject} absent de :\n{out}")

    def test_depot_valide(self):
        self.valid_repo()
        code, out = self.run_check()
        self.assertEqual(code, 0, out)

    def test_name_different_du_dossier(self):
        self.valid_repo()
        self.add_skill("gamma", frontmatter("autre"))
        self.write_marketplace([entry("alpha"), entry("beta"), entry("gamma")])
        self.assertViolation("name-dossier", "gamma")

    def test_name_format_invalide(self):
        self.add_skill("Gamma_Skill", frontmatter("Gamma_Skill"))
        self.write_marketplace([entry("Gamma_Skill")])
        self.assertViolation("name-format", "Gamma_Skill")

    def test_name_double_tiret(self):
        self.add_skill("ga--mma", frontmatter("ga--mma"))
        self.write_marketplace([entry("ga--mma")])
        self.assertViolation("name-format", "ga--mma")

    def test_description_trop_longue(self):
        self.add_skill("gamma", frontmatter("gamma", "description: " + "x" * 201 + "\n"))
        self.write_marketplace([entry("gamma")])
        self.assertViolation("description-200", "gamma")

    def test_description_trop_longue_en_bloc_plie(self):
        lines = "".join("  " + "x" * 50 + "\n" for _ in range(4))  # 4 x 50 + 3 espaces = 203
        self.add_skill("gamma", frontmatter("gamma", "description: >\n" + lines))
        self.write_marketplace([entry("gamma")])
        self.assertViolation("description-200", "gamma")

    def test_description_de_200_caracteres_acceptee(self):
        self.add_skill("gamma", frontmatter("gamma", "description: " + "x" * 200 + "\n"))
        self.write_marketplace([entry("gamma")])
        code, out = self.run_check()
        self.assertEqual(code, 0, out)

    def test_dossier_sans_skill_md(self):
        self.add_skill("gamma", None)
        self.write_marketplace([entry("gamma")])
        self.assertViolation("skill-md", "gamma")

    def test_skill_md_sans_frontmatter(self):
        self.add_skill("gamma", "# gamma\n\nPas de frontmatter.\n")
        self.write_marketplace([entry("gamma")])
        self.assertViolation("frontmatter", "gamma")

    def test_frontmatter_sans_name(self):
        self.add_skill("gamma", "---\ndescription: Fait une chose.\n---\n")
        self.write_marketplace([entry("gamma")])
        self.assertViolation("champs-requis", "gamma")

    def test_frontmatter_sans_description(self):
        self.add_skill("gamma", "---\nname: gamma\n---\n")
        self.write_marketplace([entry("gamma")])
        self.assertViolation("champs-requis", "gamma")

    def test_skill_sans_entree(self):
        self.valid_repo()
        self.write_marketplace([entry("alpha")])
        self.assertViolation("skill-sans-entree", "beta")

    def test_skill_listee_par_deux_entrees(self):
        self.valid_repo()
        self.write_marketplace([entry("alpha"), entry("beta"), {**entry("beta"), "name": "beta"}])
        self.assertViolation("skill-sans-entree", "beta")

    def test_entree_vers_dossier_absent(self):
        self.valid_repo()
        self.write_marketplace([entry("alpha"), entry("beta"), entry("fantome")])
        self.assertViolation("entree-sans-skill", "fantome")

    def test_entree_vers_dossier_sans_skill_md(self):
        self.valid_repo()
        (self.root / "skills" / "vide").mkdir()
        self.write_marketplace([entry("alpha"), entry("beta"), entry("vide")])
        self.assertViolation("entree-sans-skill", "vide")

    def test_entree_avec_deux_chemins(self):
        self.valid_repo()
        self.write_marketplace([{"name": "alpha", "source": "./", "skills": ["./skills/alpha", "./skills/beta"]}])
        self.assertViolation("entree-sans-skill", "alpha")

    def test_entree_nom_different_du_dossier(self):
        self.valid_repo()
        self.write_marketplace([entry("alpha"), {**entry("beta"), "name": "autre"}])
        self.assertViolation("entree-nom", "autre")

    def test_manifeste_json_invalide(self):
        self.valid_repo()
        self.write_marketplace(raw="{ pas du json")
        self.assertViolation("marketplace-json", "marketplace.json")

    def test_manifeste_absent(self):
        self.add_skill("alpha", frontmatter("alpha"))
        self.assertViolation("marketplace-json", "marketplace.json")

    def test_plusieurs_violations(self):
        self.valid_repo()
        self.add_skill("gamma", frontmatter("autre"))
        self.add_skill("delta", "# sans frontmatter\n")
        self.write_marketplace([entry("alpha"), entry("beta"), entry("gamma"), entry("delta")])
        code, out = self.run_check()
        self.assertNotEqual(code, 0, out)
        self.assertTrue(any(l.startswith("name-dossier ") and "gamma" in l for l in out.splitlines()), out)
        self.assertTrue(any(l.startswith("frontmatter ") and "delta" in l for l in out.splitlines()), out)


if __name__ == "__main__":
    unittest.main()
