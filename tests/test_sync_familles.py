"""Synchronisation des fichiers copiés entre les skills d'une même famille.

Les skills sont des dossiers autonomes : les références communes sont copiées,
jamais partagées. Une famille réunit les skills de même préfixe, le premier
segment du nom (`snds-`, `pdh-`). Deux skills d'une famille qui ont un fichier
au même chemin relatif sous `references/` ou `scripts/` l'ont identique octet
à octet. Le test échoue sur chaque divergence en nommant les deux fichiers et
en donnant la commande `cp` de la source vers la copie ; il n'y a aucune liste
à tenir.

Lancement : python3 -m unittest discover -s tests
"""

import os
import tempfile
import unittest
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
COPIED_DIRS = ("references", "scripts")


def divergences(root):
    """Un message par fichier copié qui diverge, sous `root/skills/`.

    Pour un chemin relatif donné, la source est le fichier de la famille
    modifié en dernier (à égalité, celui de la skill au nom le plus petit) ;
    chaque autre fichier de contenu différent est une copie à mettre à jour.
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
            source = max(paths, key=lambda path: path.stat().st_mtime_ns)
            for copy in paths:
                if copy.read_bytes() != source.read_bytes():
                    src, dst = (p.relative_to(root).as_posix() for p in (source, copy))
                    messages.append(f"{dst} diverge de {src} ; recopier : cp {src} {dst}")
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

    def write(self, relative, text, mtime=0):
        path = self.root / "skills" / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        os.utime(path, ns=(mtime, mtime))

    def test_copies_identiques(self):
        self.write("snds-alpha/references/a.md", "même contenu")
        self.write("snds-beta/references/a.md", "même contenu")
        self.write("snds-alpha/scripts/s.py", "print(1)")
        self.write("snds-beta/scripts/s.py", "print(1)")
        self.assertEqual([], divergences(self.root))

    def test_divergence_nomme_les_deux_chemins_et_la_commande_cp(self):
        self.write("snds-alpha/references/sous-dossier/a.md", "ancien", mtime=1)
        self.write("snds-beta/references/sous-dossier/a.md", "modifié", mtime=2)
        source = "skills/snds-beta/references/sous-dossier/a.md"
        copie = "skills/snds-alpha/references/sous-dossier/a.md"
        messages = divergences(self.root)
        self.assertEqual(1, len(messages))
        self.assertIn(source, messages[0])
        self.assertIn(copie, messages[0])
        self.assertIn(f"cp {source} {copie}", messages[0])

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
