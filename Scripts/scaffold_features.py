#!/usr/bin/env python3
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
INTERFACE_FOLDER = re.compile(r"^Modules/Features/(?P<name>[^/]+)/Interface/Sources$")


def declared_features(tuist):
    dump = subprocess.run(
        tuist + ["dump", "project"],
        cwd=ROOT,
        check=True,
        capture_output=True,
        text=True,
    )
    project = json.loads(dump.stdout)
    names = []
    for target in project["targets"]:
        for folder in target.get("buildableFolders", []):
            match = INTERFACE_FOLDER.match(folder["path"]["pathString"])
            if match:
                names.append(match.group("name"))
    return names


def main():
    tuist = sys.argv[1:] or ["tuist"]
    missing = [name for name in declared_features(tuist) if not (ROOT / "Modules/Features" / name).exists()]
    if not missing:
        print("Every declared feature already exists")
        return
    for name in missing:
        print(f"Scaffolding feature {name}")
        subprocess.run(tuist + ["scaffold", "feature", "--name", name], cwd=ROOT, check=True)


if __name__ == "__main__":
    main()
