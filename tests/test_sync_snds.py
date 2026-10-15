"""Synchronisation des fichiers que snds-copilot copie depuis snds-query.

Les deux skills sont des dossiers autonomes : les références communes sont
copiées, jamais partagées. Ce test échoue au premier fichier absent ou
divergent, en le nommant ; mise à jour par `cp` depuis snds-query.

Lancement : python3 -m unittest discover -s tests
"""

import unittest
from pathlib import Path

SKILLS = Path(__file__).resolve().parent.parent / "skills"
SOURCE = SKILLS / "snds-query"
COPY = SKILLS / "snds-copilot"

COPIED = [
    "references/dictionnaire/LICENSE-MPL-2.0.txt",
    "references/dictionnaire/README.md",
    "references/dictionnaire/SOURCE.txt",
    "references/dictionnaire/jointures.tsv",
    "references/dictionnaire/nomenclatures.tsv",
    "references/dictionnaire/tables.tsv",
    "references/dictionnaire/valeurs.tsv",
    "references/dictionnaire/variables.tsv",
    "references/modele-donnees.md",
    "references/profils/hdh_oracle.md",
    "references/template/00_setup.R",
    "references/template/01_inclusion.R",
    "references/template/02_exclusion.R",
    "references/template/03_critere_jugement.R",
    "references/template/04_covariables.R",
    "references/template/05_flowchart.R",
    "references/template/06_sorties.R",
    "references/template/main.R",
    "references/template/note_methodologique.md",
    "scripts/build-dictionary.py",
]


class SyncSndsTest(unittest.TestCase):
    def test_fichiers_copies_identiques(self):
        for relative in COPIED:
            with self.subTest(fichier=relative):
                source, copy = SOURCE / relative, COPY / relative
                self.assertTrue(source.is_file(), f"absent de snds-query : {relative}")
                self.assertTrue(copy.is_file(), f"absent de snds-copilot : {relative}")
                self.assertTrue(source.read_bytes() == copy.read_bytes(),
                                f"divergent : {relative} (recopier depuis snds-query)")


if __name__ == "__main__":
    unittest.main()
