"""The text the robot types: a ranked word list (weighted 1/rank) and a letter-frequency table."""
import os

DATA = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data")
WORDS = os.path.join(DATA, "words.txt")
LETTERS = os.path.join(DATA, "letters.tsv")


def _lines(path):
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#"):
                yield line


def load_words(path=WORDS):
    """[(word, weight)], most frequent first. A line may be "word" (weighted 1/rank) or
    "word<TAB>count"."""
    out = []
    for rank, line in enumerate(_lines(path), 1):
        parts = line.split("\t")
        w = parts[0]   # case kept: capitals are typed with Shift when the robot knows the Fn layers
        weight = float(parts[1]) if len(parts) > 1 else 1.0 / rank
        out.append((w, weight))
    return out


def load_letters(path=LETTERS):
    """{letter: percent}."""
    out = {}
    for line in _lines(path):
        c, v = line.split("\t")
        out[c.lower()] = float(v)
    return out
