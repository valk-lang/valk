#!/usr/bin/env python3

# Builds lib/data/tzdata.bin, the time zone database that `time.zone` uses where the system
# has none (Windows). Every zone is compiled with `zic -b slim` from the tzdata source, so a
# zone is a TZif file whose POSIX rule covers the times after its last transition.
#
# Layout, big endian:
#   "VTZ1"
#   u8 version length, version text
#   u32 name count, then per name: u8 name length, name, u32 offset, u32 length
#   the TZif files; names sharing a file share its bytes
#
# Usage: generate-tzdata.py [path to tzdata.zi]

import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "lib/data/tzdata.bin"
SOURCE = Path(sys.argv[1] if len(sys.argv) > 1 else "/usr/share/zoneinfo/tzdata.zi")


def version_of(source):
    first = source.read_text().splitlines()[0]
    if not first.startswith("# version "):
        sys.exit("No version line in " + str(source))
    return first[len("# version "):].split("-")[0]


def main():
    version = version_of(SOURCE)
    with tempfile.TemporaryDirectory() as out:
        subprocess.run(["zic", "-b", "slim", "-d", out, str(SOURCE)], check=True)
        zones = {}
        for path in sorted(Path(out).rglob("*")):
            if not path.is_file():
                continue
            data = path.read_bytes()
            if data.startswith(b"TZif"):
                zones[str(path.relative_to(out))] = data

    blob = bytearray()
    offsets = {}
    for data in zones.values():
        if data not in offsets:
            offsets[data] = len(blob)
            blob += data

    out = bytearray(b"VTZ1")
    out += bytes([len(version)]) + version.encode()
    out += len(zones).to_bytes(4, "big")
    for name, data in zones.items():
        encoded = name.encode()
        out += bytes([len(encoded)]) + encoded
        out += offsets[data].to_bytes(4, "big") + len(data).to_bytes(4, "big")
    out += blob

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_bytes(out)
    print(f"{OUTPUT}: tzdata {version}, {len(zones)} zones, {len(offsets)} unique, {len(out)} bytes")


main()
