"""Pure ingredient matching. No database, no HTTP.

The interesting problem is units: a recipe asks for 2 cups of flour, the
pantry has 500 grams. These must compare.
"""

# Everything normalises to grams or millilitres.
TO_GRAMS = {
    "g": 1.0, "gram": 1.0, "grams": 1.0,
    "kg": 1000.0, "kilogram": 1000.0,
    "cup": 120.0,        # cup of flour, the usual kitchen approximation
    "tbsp": 15.0, "tablespoon": 15.0,
    "tsp": 5.0, "teaspoon": 5.0,
    "piece": 50.0, "pc": 50.0, "no": 50.0,
}
TO_ML = {
    "ml": 1.0, "millilitre": 1.0, "milliliter": 1.0,
    "l": 1000.0, "litre": 1000.0, "liter": 1000.0,
    "cup": 240.0,        # a cup of LIQUID is 240ml, not 120g - this is the trap
    "tbsp": 15.0, "tsp": 5.0,
}

SUBSTITUTES = {
    "butter": {"oil", "ghee"},
    "oil": {"butter", "ghee"},
    "milk": {"curd", "yoghurt"},
}


class UnitError(ValueError):
    pass


def normalise(name):
    return str(name).strip().lower().rstrip("s") if name else ""


def to_base(qty, unit, liquid=False):
    """Convert a quantity to grams (or millilitres for liquids)."""
    try:
        q = float(qty)
    except (TypeError, ValueError):
        raise UnitError(f"{qty!r} is not a quantity")
    if q < 0:
        raise UnitError("a quantity cannot be negative")
    table = TO_ML if liquid else TO_GRAMS
    u = str(unit).strip().lower()
    if u not in table:
        raise UnitError(f"unknown unit {unit!r}")
    return q * table[u]


def have_enough(pantry, needed, allow_substitutes=True):
    """Is every ingredient available in sufficient quantity?

    pantry / needed are {ingredient: base_quantity}.
    Returns (bool, {ingredient: shortfall}).
    """
    missing = {}
    for item, want in needed.items():
        key = normalise(item)
        got = pantry.get(key, 0.0)
        if got < want and allow_substitutes:
            for alt in SUBSTITUTES.get(key, ()):
                got += pantry.get(normalise(alt), 0.0)
        if got < want:
            missing[key] = round(want - got, 2)
    return (not missing), missing


def classify_recipes(pantry, recipes):
    """Sort recipes into what you can cook now, and what needs one more item."""
    now, nearly, far = [], [], []
    for r in recipes:
        ok, missing = have_enough(pantry, r["needs"])
        entry = {"id": r["id"], "name": r["name"], "missing": missing}
        if ok:
            now.append(entry)
        elif len(missing) == 1:
            nearly.append(entry)
        else:
            far.append(entry)
    def key(entry):
        return (len(entry["missing"]), entry["name"])

    return {"can_cook_now": sorted(now, key=key),
            "need_one_more": sorted(nearly, key=key),
            "need_more": sorted(far, key=key)}
