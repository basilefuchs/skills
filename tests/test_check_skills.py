"""Tests de check_skills.py, appelé comme en CI sur de petits dépôts d'exemple.

Les tests ne vérifient que le code de sortie, l'identifiant de règle et le nom
de la skill dans la sortie, jamais le libellé des messages.

Lancement : python3 -m unittest discover -s tests
"""

import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

CHECK = Path(__file__).resolve().parent.parent / "check_skills.py"

FOLDED_DESCRIPTION = "description: >\n  Fait une chose précise,\n  sur plusieurs lignes.\n"


def frontmatter(name, description="description: Fait une chose précise.\n"):
    return f"---\nname: {name}\n{description}license: MIT\n---\n\n# {name}\n"


class CheckSkillsTest(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)

    def add_skill(self, folder, skill_md):
        (self.root / "skills" / folder).mkdir(parents=True)
        if skill_md is not None:
            (self.root / "skills" / folder / "SKILL.md").write_text(skill_md, encoding="utf-8")

    def valid_repo(self):
        self.add_skill("alpha", frontmatter("alpha", FOLDED_DESCRIPTION))
        self.add_skill("beta", frontmatter("beta"))

    def run_check(self):
        result = subprocess.run([sys.executable, str(CHECK), str(self.root)],
                                capture_output=True, text=True, encoding="utf-8",
                                env={**os.environ, "PYTHONIOENCODING": "utf-8"})
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

    def test_depot_sans_skill(self):
        self.assertViolation("aucune-skill", "skills")
        with self.subTest("dossier skills vide"):
            (self.root / "skills").mkdir()
            self.assertViolation("aucune-skill", "skills")

    def test_name_different_du_dossier(self):
        self.valid_repo()
        self.add_skill("gamma", frontmatter("autre"))
        self.assertViolation("name-dossier", "gamma")

    def test_name_format_invalide(self):
        for name in ["a" * 65, "-gamma", "gamma-", "ga--mma", "Gamma", "gam_ma"]:
            with self.subTest(name=name):
                self.setUp()
                self.add_skill(name, frontmatter(name))
                self.assertViolation("name-format", name)

    def test_name_de_64_caracteres_accepte(self):
        name = "a" * 64
        self.add_skill(name, frontmatter(name))
        code, out = self.run_check()
        self.assertEqual(code, 0, out)

    def test_description_trop_longue(self):
        self.add_skill("gamma", frontmatter("gamma", "description: " + "x" * 201 + "\n"))
        self.assertViolation("description-200", "gamma")

    def test_description_trop_longue_en_bloc_plie(self):
        lines = "".join("  " + "x" * 50 + "\n" for _ in range(4))  # 4 x 50 + 3 espaces = 203
        self.add_skill("gamma", frontmatter("gamma", "description: >\n" + lines))
        self.assertViolation("description-200", "gamma")

    def test_description_trop_longue_sur_plusieurs_lignes_sans_bloc(self):
        description = "description: " + "x" * 150 + "\n  " + "y" * 60 + "\n"
        self.add_skill("gamma", frontmatter("gamma", description))
        self.assertViolation("description-200", "gamma")

    def test_description_trop_longue_variantes_de_bloc(self):
        lines = "  " + "x" * 150 + "\n  " + "y" * 60 + "\n"
        for indicator in [">-", ">+", "|", "> # commentaire"]:
            with self.subTest(indicator=indicator):
                self.setUp()
                self.add_skill("gamma", frontmatter("gamma", f"description: {indicator}\n" + lines))
                self.assertViolation("description-200", "gamma")

    def test_description_sur_la_ligne_suivante_acceptee(self):
        self.add_skill("gamma", frontmatter("gamma", "description:\n  Fait une chose précise.\n"))
        code, out = self.run_check()
        self.assertEqual(code, 0, out)

    def test_frontmatter_avec_bom_crlf_guillemets_et_metadata_accepte(self):
        skill_md = ('\ufeff---\r\nname: gamma\r\ndescription: "Fait ceci : une chose."\r\n'
                    "metadata:\r\n  auteur: Basile\r\n  version: 1\r\n---\r\n")
        self.add_skill("gamma", skill_md)
        code, out = self.run_check()
        self.assertEqual(code, 0, out)

    def test_description_de_200_caracteres_acceptee(self):
        self.add_skill("gamma", frontmatter("gamma", "description: " + "x" * 200 + "\n"))
        code, out = self.run_check()
        self.assertEqual(code, 0, out)

    def test_dossier_sans_skill_md(self):
        self.add_skill("gamma", None)
        self.assertViolation("skill-md", "gamma")

    def test_skill_md_sans_frontmatter(self):
        self.add_skill("gamma", "# gamma\n\nPas de frontmatter.\n")
        self.assertViolation("frontmatter", "gamma")

    def test_frontmatter_non_ferme(self):
        self.add_skill("gamma", "---\nname: gamma\ndescription: Fait une chose.\n")
        self.assertViolation("frontmatter", "gamma")

    def test_deux_points_non_cites(self):
        self.add_skill("gamma", frontmatter("gamma", "description: Statisticien : traduit une question.\n"))
        self.assertViolation("frontmatter", "gamma")

    def test_skill_md_pas_en_utf8(self):
        self.add_skill("gamma", None)
        (self.root / "skills" / "gamma" / "SKILL.md").write_bytes(
            "---\nname: gamma\ndescription: Requête PMSI.\n---\n".encode("cp1252"))
        self.add_skill("zeta", frontmatter("autre"))
        self.assertViolation("frontmatter", "gamma")
        self.assertViolation("name-dossier", "zeta")

    def test_frontmatter_sans_name(self):
        self.add_skill("gamma", "---\ndescription: Fait une chose.\n---\n")
        self.assertViolation("champs-requis", "gamma")

    def test_frontmatter_sans_description(self):
        self.add_skill("gamma", "---\nname: gamma\n---\n")
        self.assertViolation("champs-requis", "gamma")

    def test_plusieurs_violations_sur_une_meme_skill(self):
        self.add_skill("gamma", "---\nname: Autre\n---\n")
        for rule in ["champs-requis", "name-format", "name-dossier"]:
            self.assertViolation(rule, "gamma")

    def test_plusieurs_violations(self):
        self.valid_repo()
        self.add_skill("gamma", frontmatter("autre"))
        self.add_skill("delta", "# sans frontmatter\n")
        code, out = self.run_check()
        self.assertNotEqual(code, 0, out)
        self.assertTrue(any(l.startswith("name-dossier ") and "gamma" in l for l in out.splitlines()), out)
        self.assertTrue(any(l.startswith("frontmatter ") and "delta" in l for l in out.splitlines()), out)


if __name__ == "__main__":
    unittest.main()
