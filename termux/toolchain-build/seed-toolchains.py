#!/usr/bin/env python3
"""Seed a DECOMPNET_TOOLCHAINS root from locally built aarch64 toolchain tarballs, so the
decompnet test suite (pytest) and CLI treat them as installed (checksum-verified manifests included).

Usage: seed-toolchains.py <tarball-dir> <seed-root>
"""
import hashlib
import json
import sys
import tarfile
import time
import zipfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "src"))
from decompnet import toolchains  # noqa: E402

TARBALLS = Path(sys.argv[1])
ROOT = Path(sys.argv[2])


def extract(archive: Path, dest: Path, subdir: str | None) -> None:
    tmp = dest.parent / f".tmp-{dest.name}"
    tmp.mkdir(parents=True, exist_ok=True)
    if archive.name.endswith(".zip"):
        with zipfile.ZipFile(archive) as z:
            z.extractall(tmp)
        src = tmp
    else:
        with tarfile.open(archive) as t:
            t.extractall(tmp, filter="data")
        src = tmp / subdir if subdir else tmp
    for item in src.iterdir():
        target = dest / item.name
        if item.is_file():
            target.write_bytes(item.read_bytes())
        else:
            (dest / item.name).mkdir(exist_ok=True)
            for f in item.rglob("*"):
                rel = f.relative_to(item)
                (dest / item.name / rel).parent.mkdir(parents=True, exist_ok=True)
                (dest / item.name / rel).write_bytes(f.read_bytes())
    for f in dest.rglob("*"):
        if f.is_file() and not f.name.endswith(".i"):
            f.chmod(0o755)


def sha256(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


# which registry toolchain gets which artifact parts (same pairing as toolchains.toml)
COMBOS = {
    "gcc-2.7.2-kmc": ["gcc-2.7.2-kmc-aarch64.tar.gz", "binutils-2.6-aarch64.tar.gz"],
    "gcc-2.7.2-psx": ["gcc-2.7.2-psx-aarch64.tar.gz", "binutils-2.6-aarch64.tar.gz"],
    "gcc-2.8.1-psx": ["gcc-2.8.1-psx-aarch64.tar.gz", "binutils-2.6-aarch64.tar.gz"],
    "ido-7.1": ["ido-7.1-recomp-aarch64.tar.gz"],
    "ido-5.3": ["ido-5.3-recomp-aarch64.tar.gz"],
    "agbcc": ["agbcc-aarch64.tar.gz"],
    "arm-gnu": ["arm-gnu-aarch64.tar.gz"],
    "gc-wii-binutils": ["gc-wii-binutils-aarch64.zip"],
    "binutils-mips": ["binutils-mips-aarch64.tar.gz"],
}
SUBDIRS = {"arm-gnu": "arm-gnu-aarch64"}

reg = toolchains.registry()
for tid, parts in COMBOS.items():
    tc = reg[tid]
    dest = ROOT / tid
    dest.mkdir(parents=True, exist_ok=True)
    pinned = []
    for name in parts:
        archive = TARBALLS / name
        digest = sha256(archive)
        extract(archive, dest, SUBDIRS.get(tid))
        pinned.append({"url": name, "sha256": digest})
    if tid == "arm-gnu":  # validation host isn't Termux: render the cpp shim for /bin/sh
        shim = dest / "bin" / "arm-none-eabi-cpp"
        if shim.exists():
            text = shim.read_text().splitlines()
            text[0] = "#!/bin/sh"
            shim.write_text("\n".join(text) + "\n")
    (dest / ".decompnet-toolchain.json").write_text(json.dumps({
        "id": tid, "name": tc.name, "license": tc.license, "source": tc.source,
        "parts": pinned, "commit": None, "installed_at": time.time(),
        "license_accepted": tc.proprietary, "wsl": False,
    }, indent=2), encoding="utf-8")
    print(f"seeded {tid} at {dest}")

# proprietary IDO must look accepted for the tests that use it after --accept-license
print("done")
