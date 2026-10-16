"""Contrat d'export `sorties/`, vérifié dans le texte des squelettes de scripts.

Les scripts générés n'écrivent de fichier que par `exporter()`, définie dans
le script de mise en place (`00_setup.R`, chunk `setup` du `.Rmd`) et appelée
par le flowchart, les sorties et le chunk d'export du `.Rmd`. Les noms de
fichiers du contrat figurent dans les deux squelettes. Le test lit le texte,
commentaires compris, sauf pour l'appel d'`exporter()`, cherché hors
commentaires : il n'exige ni R ni réseau.

Lancement : python3 -m unittest discover -s tests
"""

import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SQUELETTES = ("snds-query", "pdh-query")

DEFINITION = "exporter <- function("
APPEL = re.compile(r"\bexporter\(")
COMMENTAIRE = re.compile(r"#.*")
ECRITURE = re.compile(
    r"\b(?:write\.csv2?|write\.table|write_(?:csv2?|delim|tsv|rds|xlsx)|write\.xlsx"
    r"|fwrite|writeLines|saveRDS|save|ggsave|sink|file\.copy|file\.create"
    r"|png|pdf|jpeg|svg|cat)\s*\("
)
FICHIERS_CONTRAT = ("flowchart.csv", "resultat_annuel.csv", "nb_patients_periode.csv", "manifeste.md")
STRATE = re.compile(r"strate_\w+\.csv")


def sans_exporter(texte):
    """Le texte privé de la définition d'`exporter()`, accolades comprises."""
    debut = texte.find(DEFINITION)
    if debut < 0:
        return texte
    fin = texte.index("{", debut)
    profondeur = 0
    for i in range(fin, len(texte)):
        profondeur += {"{": 1, "}": -1}.get(texte[i], 0)
        if profondeur == 0:
            return texte[:debut] + texte[i + 1:]
    raise ValueError("définition d'exporter() sans accolade fermante")


def sans_commentaires(texte):
    """Le code R privé de ses commentaires, de `#` à la fin de la ligne."""
    return COMMENTAIRE.sub("", texte)


def chunks(rmd):
    """Corps des chunks R d'un `.Rmd`, par nom de chunk."""
    return {m.group(1): m.group(2)
            for m in re.finditer(r"^```\{r (\w+)[^}]*\}\n(.*?)^```", rmd, re.M | re.S)}


class ContratSortiesTest(unittest.TestCase):
    def squelettes(self):
        for skill in SQUELETTES:
            references = ROOT / "skills" / skill / "references"
            dossier = {p.name: p.read_text(encoding="utf-8")
                       for p in sorted((references / "template").glob("*.R"))}
            rmd = (references / "template.Rmd").read_text(encoding="utf-8")
            yield skill, dossier, rmd

    def test_exporter_definie_dans_la_mise_en_place(self):
        for skill, dossier, rmd in self.squelettes():
            with self.subTest(skill):
                definitions = [nom for nom, texte in dossier.items() if DEFINITION in texte]
                self.assertEqual(["00_setup.R"], definitions)
                self.assertEqual(1, dossier["00_setup.R"].count(DEFINITION))
                self.assertEqual(1, rmd.count(DEFINITION))
                self.assertIn(DEFINITION, chunks(rmd)["setup"])

    def test_exporter_appelee_par_flowchart_sorties_et_rmd(self):
        for skill, dossier, rmd in self.squelettes():
            appelants = {"05_flowchart.R": dossier["05_flowchart.R"],
                         "06_sorties.R": dossier["06_sorties.R"],
                         "template.Rmd": chunks(rmd)["06_sorties_export"]}
            for nom, texte in appelants.items():
                with self.subTest(skill=skill, fichier=nom):
                    self.assertRegex(sans_commentaires(texte), APPEL)

    def test_aucune_ecriture_hors_exporter(self):
        for skill, dossier, rmd in self.squelettes():
            for nom, texte in {**dossier, "template.Rmd": rmd}.items():
                with self.subTest(skill=skill, fichier=nom):
                    self.assertEqual([], ECRITURE.findall(sans_exporter(texte)))

    def test_noms_du_contrat_presents(self):
        for skill, dossier, rmd in self.squelettes():
            for nom, texte in {"dossier de scripts": "\n".join(dossier.values()),
                               "template.Rmd": rmd}.items():
                with self.subTest(skill=skill, squelette=nom):
                    for fichier in FICHIERS_CONTRAT:
                        self.assertIn(fichier, texte)
                    self.assertRegex(texte, STRATE)


if __name__ == "__main__":
    unittest.main()
