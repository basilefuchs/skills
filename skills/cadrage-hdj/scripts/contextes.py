"""Codes CIM-10 relevant du polyhandicap lourd (une des situations de « contexte patient »).

Usage: python scripts/contextes.py CODE [CODE ...]
Un code partiel (ex. G80) renvoie tous les codes de la liste qui commencent ainsi.
"""
import csv, json, sys
from pathlib import Path

REFERENTIEL = Path(__file__).resolve().parent.parent / "assets" / "contextes.csv"


def normaliser(code):
    return code.strip().upper().replace(".", "")


def chercher(codes):
    with open(REFERENTIEL, encoding="utf8") as f:
        lignes = list(csv.DictReader(f))
    resultat = {}
    for c in codes:
        n = normaliser(c)
        resultat[c] = [l for l in lignes if normaliser(l["code"]).startswith(n)]
    return resultat


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    print(json.dumps(chercher(sys.argv[1:]), ensure_ascii=False, indent=1))
