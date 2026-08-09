#!/usr/bin/env python3
"""Check for new Blender releases and update versions.json.

Looks up the newest release tag of every series >= 4.2 on the GitHub
mirror, detects the bundled Python and required GCC for new/updated
entries from the tag's own build files, and rewrites versions.json.

Prints a JSON list of the added or updated versions to stdout — an
empty list means versions.json was already current.
"""
import json
import re
import subprocess
import urllib.request

MIN_SERIES = (4, 2)  # older releases relied on the decommissioned svn.blender.org
MIN_GCC = 13         # Ubuntu 24.04 default compiler; lower requirements clamp to this
RAW = "https://raw.githubusercontent.com/blender/blender/{ref}/{path}"


def fetch(ref: str, path: str) -> str:
    with urllib.request.urlopen(RAW.format(ref=ref, path=path), timeout=30) as r:
        return r.read().decode()


def latest_release_per_series() -> list:
    out = subprocess.run(
        ["git", "ls-remote", "--tags",
         "https://github.com/blender/blender.git", "refs/tags/v*"],
        check=True, capture_output=True, text=True).stdout
    latest = {}
    for line in out.splitlines():
        m = re.search(r"refs/tags/v(\d+)\.(\d+)\.(\d+)$", line)
        if not m:
            continue
        v = tuple(map(int, m.groups()))
        if v[:2] < MIN_SERIES:
            continue
        if v[:2] not in latest or v > latest[v[:2]]:
            latest[v[:2]] = v
    return sorted(latest.values())


def detect_toolchain(version: str) -> tuple:
    ref = "v" + version
    python = re.search(
        r"set\(PYTHON_SHORT_VERSION (\S+)\)",
        fetch(ref, "build_files/build_environment/cmake/versions.cmake")).group(1)
    m = re.search(r"minimum supported version of GCC is (\d+)",
                  fetch(ref, "CMakeLists.txt"))
    gcc = max(MIN_GCC, int(m.group(1)) if m else MIN_GCC)
    return python, str(gcc)


def main() -> None:
    with open("versions.json") as f:
        data = json.load(f)
    by_series = {tuple(map(int, e["version"].split(".")))[:2]: e
                 for e in data["versions"]}

    changed, entries = [], []
    for v in latest_release_per_series():
        version = ".".join(map(str, v))
        existing = by_series.get(v[:2])
        if existing and existing["version"] == version:
            entries.append(existing)
            continue
        python, gcc = detect_toolchain(version)
        entry = {"version": version, "python": python}
        if gcc != str(MIN_GCC):
            entry["gcc"] = gcc
        entries.append(entry)
        changed.append(version)

    if changed:
        data["versions"] = entries
        with open("versions.json", "w") as f:
            json.dump(data, f, indent=2)
            f.write("\n")
    print(json.dumps(changed))


if __name__ == "__main__":
    main()
