#!/usr/bin/env python3

import sys
import unicodedata
from pathlib import Path


UNICODE_VERSION = "16.0.0"
ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "lib/src/core/unicode-data.valk"


def ranges_for(values):
    ranges = []
    for value in values:
        if ranges and value == ranges[-1][1] + 1:
            ranges[-1] = (ranges[-1][0], value)
        else:
            ranges.append((value, value))
    return ranges


def mapping_for(mode):
    singles = []
    expansions = []
    for code in range(sys.maxunicode + 1):
        source = chr(code)
        mapped = getattr(source, mode)()
        if mapped == source:
            continue
        points = tuple(ord(char) for char in mapped)
        if len(points) == 1:
            singles.append((code, points[0]))
        else:
            expansions.append((code, points))

    lookup = dict(singles)
    used = set()
    runs = []
    for step in (1, 2):
        for code, target in singles:
            if code in used:
                continue
            delta = target - code
            run = []
            current = code
            while current in lookup and current not in used and lookup[current] - current == delta:
                run.append(current)
                current += step
            if len(run) >= 3:
                runs.append((run[0], run[-1], step, target))
                used.update(run)

    return sorted(runs), [item for item in singles if item[0] not in used], expansions


def emit_table(name, values):
    # Six hexadecimal digits cover every Unicode scalar and every table offset.
    # A string literal keeps the bootstrap compiler from recursively lowering
    # thousands of Array initializer calls.
    encoded = "".join(f"{value:06x}" for value in values)
    return f'global {name}: String ("{encoded}")'


def flatten(items):
    return [value for item in items for value in item]


def emit_mapping(prefix, mode):
    runs, singles, expansions = mapping_for(mode)
    expansion_records = []
    expansion_values = []
    for code, points in expansions:
        expansion_records.append((code, len(expansion_values), len(points)))
        expansion_values.extend(points)
    return "\n\n".join((
        emit_table(f"unicode_{prefix}_ranges", flatten(runs)),
        emit_table(f"unicode_{prefix}_singles", flatten(singles)),
        emit_table(f"unicode_{prefix}_expansions", flatten(expansion_records)),
        emit_table(f"unicode_{prefix}_expansion_values", expansion_values),
    ))


def validate_mapping(mode):
    runs, singles, expansions = mapping_for(mode)
    decoded = dict(singles)
    decoded.update((code, points) for code, points in expansions)
    for first, last, step, target in runs:
        for code in range(first, last + 1, step):
            decoded[code] = target + code - first
    for code in range(sys.maxunicode + 1):
        source = chr(code)
        expected = tuple(ord(char) for char in getattr(source, mode)())
        actual = decoded.get(code, code)
        if not isinstance(actual, tuple):
            actual = (actual,)
        if actual != expected:
            raise AssertionError(f"bad {mode} mapping for U+{code:04X}: {actual} != {expected}")


def is_cased(char):
    return char.islower() or char.isupper() or char.istitle()


def caseless_pairs():
    # Every code point grouped by its full case fold: the members of one group are the
    # caseless equivalents of each other. This is symmetric where the simple upper and
    # lower mappings are not: sharp s has no simple uppercase, but both s and U+1E9E
    # fold to "ss", and KELVIN SIGN folds to "k" while 'k' maps to 'K' (U+004B).
    groups = {}
    for code in range(sys.maxunicode + 1):
        groups.setdefault(chr(code).casefold(), []).append(code)
    pairs = []
    for members in groups.values():
        if len(members) < 2:
            continue
        for code in members:
            for other in members:
                if other != code:
                    pairs.append((code, other))
    pairs.sort()
    return pairs


def is_case_ignorable(code):
    char = chr(code)
    # Python applies Unicode's Final_Sigma rule. A character that is skipped by
    # both context scans has Case_Ignorable=True; one that ends either scan has
    # it False. A cased character is skipped too — the probes disagree about the
    # ones that are cased but not ignorable, so do not test `is_cased` first.
    before = ("A" + char + "\u03a3").lower().endswith("\u03c2")
    after = ("A\u03a3" + char).lower()[1] == "\u03c2"
    return before == after


def main():
    if unicodedata.unidata_version != UNICODE_VERSION:
        raise SystemExit(
            f"expected Unicode {UNICODE_VERSION}, found {unicodedata.unidata_version}"
        )

    validate_mapping("lower")
    validate_mapping("upper")

    alpha = ranges_for(code for code in range(sys.maxunicode + 1) if chr(code).isalpha())
    alnum = ranges_for(code for code in range(sys.maxunicode + 1) if chr(code).isalnum())
    cased = ranges_for(code for code in range(sys.maxunicode + 1) if is_cased(chr(code)))
    ignorable = ranges_for(code for code in range(sys.maxunicode + 1) if is_case_ignorable(code))

    contents = "\n\n".join((
        "// Generated by misc/generate-unicode.py from Unicode 16.0.0.\n"
        "// Each property table stores inclusive start/end pairs. Mapping range\n"
        "// records store start, end, step and the mapped value for start.",
        emit_table("unicode_alpha_ranges", flatten(alpha)),
        emit_table("unicode_alnum_ranges", flatten(alnum)),
        emit_table("unicode_cased_ranges", flatten(cased)),
        emit_table("unicode_case_ignorable_ranges", flatten(ignorable)),
        emit_table("unicode_caseless_pairs", flatten(caseless_pairs())),
        emit_mapping("lower", "lower"),
        emit_mapping("upper", "upper"),
    )) + "\n"
    OUTPUT.write_text(contents)


if __name__ == "__main__":
    main()
