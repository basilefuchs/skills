"""Synchronisation des fichiers copiés entre les skills d'une même famille.

Les skills sont des dossiers autonomes : les références communes sont copiées,
jamais partagées. Une famille réunit les skills de même préfixe, le premier
segment du nom (`snds-`, `pdh-`). Deux skills d'une famille qui ont un fichier
au même chemin relatif sous `references/` ou `scripts/` l'ont identique octet
à octet. Le test échoue sur chaque divergence en nommant les deux fichiers et
en donnant la commande `cp` dans les deux sens, le mainteneur choisissant la
source ; il n'y a aucune liste à tenir.

Lancement : python3 -m unittest discover -s tests
"""

import tempfile
import unittest
from collections import defaultdict
from itertools import combinations
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
COPIED_DIRS = ("references", "scripts")


def divergences(root):
    """Un message par paire de fichiers copiés qui divergent, sous `root/skills/`.

    Le message nomme les deux fichiers et propose `cp` dans les deux sens : la
    source n'est pas devinée, le mainteneur choisit.
    """
    families = defaultdict(list)
    for skill in sorted((root / "skills").iterdir()):
        if skill.is_dir():
            families[skill.name.split("-")[0]].append(skill)

    messages = []
    for skills in families.values():
        files = defaultdict(list)
        for skill in skills:
            for folder in COPIED_DIRS:
                for path in sorted((skill / folder).rglob("*")):
                    if path.is_file():
                        files[path.relative_to(skill)].append(path)
        for paths in files.values():
            for one, other in combinations(paths, 2):
                if one.read_bytes() != other.read_bytes():
                    a, b = (p.relative_to(root).as_posix() for p in (one, other))
                    messages.append(
                        f"{a} et {b} divergent ; recopier dans le sens de la "
                        f"source : cp {a} {b} ou cp {b} {a}"
                    )
    return messages


class SyncFamillesTest(unittest.TestCase):
    def test_depot_reel(self):
        for message in divergences(ROOT):
            with self.subTest(message):
                self.fail(message)


class DivergencesTest(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name)

    def write(self, relative, text):
        path = self.root / "skills" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")

    def test_copies_identiques(self):
        self.write("snds-alpha/references/a.md", "même contenu")
        self.write("snds-beta/references/a.md", "même contenu")
        self.write("snds-alpha/scripts/s.py", "print(1)")
        self.write("snds-beta/scripts/s.py", "print(1)")
        self.assertEqual([], divergences(self.root))

    def test_divergence_nomme_les_deux_chemins_et_les_deux_commandes_cp(self):
        self.write("snds-alpha/references/sous-dossier/a.md", "ancien")
        self.write("snds-beta/references/sous-dossier/a.md", "modifié")
        alpha = "skills/snds-alpha/references/sous-dossier/a.md"
        beta = "skills/snds-beta/references/sous-dossier/a.md"
        messages = divergences(self.root)
        self.assertEqual(1, len(messages))
        self.assertIn(f"cp {alpha} {beta}", messages[0])
        self.assertIn(f"cp {beta} {alpha}", messages[0])

    def test_une_copie_divergente_sur_trois(self):
        self.write("snds-alpha/references/a.md", "commun")
        self.write("snds-beta/references/a.md", "commun")
        self.write("snds-gamma/references/a.md", "modifié")
        messages = divergences(self.root)
        self.assertEqual(2, len(messages))
        for message in messages:
            self.assertIn("skills/snds-gamma/references/a.md", message)

    def test_hors_famille_ou_hors_references_ignore(self):
        self.write("snds-alpha/references/a.md", "un")
        self.write("pdh-alpha/references/a.md", "deux")
        self.write("snds-alpha/references/seul.md", "présent d'un seul côté")
        self.write("snds-beta/references/autre.md", "autre")
        self.write("snds-alpha/SKILL.md", "un")
        self.write("snds-beta/SKILL.md", "deux")
        self.write("snds-alpha/README.md", "un")
        self.write("snds-beta/README.md", "deux")
        self.assertEqual([], divergences(self.root))


if __name__ == "__main__":
    unittest.main()
