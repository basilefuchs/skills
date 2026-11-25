"""Remplit assets/fiche.dotx avec un JSON et écrit un .docx.

Usage:
  python scripts/fiche.py donnees.json [--sortie sorties]
  python scripts/fiche.py --champs
"""
import json, re, sys, unicodedata, zipfile
from pathlib import Path
from xml.sax.saxutils import escape

GABARIT = Path(__file__).resolve().parent.parent / "assets" / "fiche.dotx"
BALISE = re.compile(r"\{\{([a-z0-9_.]+)\}\}")
LIGNE_REPETEE = re.compile(r"<w:tr[ >](?:(?!</w:tr>).)*\{\{i\.(?:(?!</w:tr>).)*</w:tr>", re.S)
TYPE_DOTX = "wordprocessingml.template.main+xml"
TYPE_DOCX = "wordprocessingml.document.main+xml"


def lire_document():
    with zipfile.ZipFile(GABARIT) as z:
        return z.read("word/document.xml").decode("utf8")


def texte(valeur, cle):
    if valeur is True:
        return "☒" if cle.startswith("cb_") else "X"
    if valeur in (None, False, ""):
        return "☐" if cle.startswith("cb_") else ""
    lignes = [escape(l) for l in str(valeur).split("\n")]
    return '</w:t><w:br/><w:t xml:space="preserve">'.join(lignes)


def remplacer(xml, valeurs, prefixe=""):
    def sub(m):
        cle = m.group(1)
        return texte(valeurs.get(cle[len(prefixe):]), cle)
    return BALISE.sub(sub, xml)


def remplir(xml, donnees):
    m = LIGNE_REPETEE.search(xml)
    if m:
        lignes = [remplacer(m.group(0), i, "i.") for i in donnees.get("interventions", [])]
        xml = xml.replace(m.group(0), "".join(lignes) or remplacer(m.group(0), {}, "i."))
    return remplacer(xml, donnees)


def slug(s):
    s = unicodedata.normalize("NFKD", s or "").encode("ascii", "ignore").decode()
    return re.sub(r"[^A-Za-z0-9]+", "-", s).strip("-")[:40] or "sans-nom"


def ecrire(donnees, sortie):
    nom = f"Cadrage_HJ_{slug(donnees.get('projet_court') or donnees.get('projet_intitule'))}_{slug(donnees.get('parcours_nom'))}.docx"
    chemin = Path(sortie) / nom
    chemin.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(GABARIT) as src, zipfile.ZipFile(chemin, "w", zipfile.ZIP_DEFLATED) as dst:
        for item in src.infolist():
            data = src.read(item.filename)
            if item.filename == "word/document.xml":
                data = remplir(data.decode("utf8"), donnees).encode("utf8")
            elif item.filename == "[Content_Types].xml":
                data = data.replace(TYPE_DOTX.encode(), TYPE_DOCX.encode())
            dst.writestr(item, data)
    return chemin


def main(args):
    champs = sorted(set(BALISE.findall(lire_document())))
    if args[:1] == ["--champs"]:
        print(json.dumps(champs, ensure_ascii=False, indent=1))
        return
    if not args:
        sys.exit(__doc__)
    donnees = json.loads(Path(args[0]).read_text(encoding="utf8"))
    sortie = args[args.index("--sortie") + 1] if "--sortie" in args else "sorties"
    chemin = ecrire(donnees, sortie)
    vides = [c for c in champs if not c.startswith("i.") and donnees.get(c) in (None, "")]
    print(json.dumps({"fichier": str(chemin), "champs_vides": vides}, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main(sys.argv[1:])
