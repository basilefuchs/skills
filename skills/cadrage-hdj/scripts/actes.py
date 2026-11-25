"""Caractéristiques CCAM utiles à la gradation, et décompte CCAM d'une venue.

Usage: python scripts/actes.py CODE [CODE ...]
"""
import csv, json, sys
from pathlib import Path

REFERENTIEL = Path(__file__).resolve().parent.parent / "assets" / "actes.csv"
NON_DECOMPTABLES = {"DEQP003"}  # ECG 12 dérivations


def charger():
    with open(REFERENTIEL, encoding="utf8") as f:
        return {r["code"]: r for r in csv.DictReader(f)}


def fiche(r):
    return {
        "code": r["code"],
        "libelle": r["libelle"],
        "sous_paragraphe": r["sous_paragraphe"],
        "technique": r["technique"],
        "classant": r["classant"] == "1",
        "activite_4": r["activite_4"] == "1",
        "ffm": [x for x in r["ffm"].split("|") if x],
        "se": [x for x in r["se"].split("|") if x],
    }


def analyser(codes):
    ref = charger()
    actes = [fiche(ref[c]) for c in codes if c in ref]
    groupes = {}
    for a in actes:
        if a["code"] not in NON_DECOMPTABLES:
            groupes.setdefault((a["sous_paragraphe"], a["technique"]), []).append(a["code"])
    return {
        "actes": actes,
        "inconnus": [c for c in codes if c not in ref],
        "acte_classant": any(a["classant"] for a in actes),
        "decompte_ccam": len(groupes),
        "groupes_meme_technique": [g for g in groupes.values()],
        "exclus_du_decompte": [a["code"] for a in actes if a["code"] in NON_DECOMPTABLES],
    }


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    codes = [c.strip().upper() for c in sys.argv[1:]]
    print(json.dumps(analyser(codes), ensure_ascii=False, indent=1))
