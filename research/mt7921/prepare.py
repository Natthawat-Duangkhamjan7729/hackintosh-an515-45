"""Audit pinned upstream inputs; optionally prepare a fresh, local Xcode workspace.

No network access, EFI writes, firmware extraction to disk, or kext loading.
Python 3.10+. Invoke from any working directory.
"""
import argparse
import hashlib
import json
from pathlib import Path
import platform
import plistlib
import re
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parent


def git(repo, *args):
    return subprocess.check_output(
        ["git", "-C", str(repo), *args], text=True, encoding="utf-8"
    ).strip()


def inspect_inputs():
    lock = json.loads((ROOT / "sources.lock.json").read_text())
    for name, spec in lock.items():
        repo = ROOT / "upstream" / name
        if git(repo, "rev-parse", "HEAD") != spec["commit"]:
            raise ValueError(f"{name}: checkout does not match sources.lock.json")
        if git(repo, "status", "--porcelain", "--untracked-files=all", "--ignored"):
            raise ValueError(f"{name}: expected a clean checkout without extra files")
    source = ROOT / "upstream" / "SimpleMtkWlan"
    with (source / "SimpleMtkWlan/Info.plist").open("rb") as stream:
        info = plistlib.load(stream)
    personality = info["IOKitPersonalities"]["SimpleMtkWlan"]
    if "0x796114c3" not in personality["IOPCIPrimaryMatch"].split():
        raise ValueError("MT7921 PCI match missing")
    sdk = ROOT / "upstream" / "MacKernelSDK"
    for rel in ("Headers/IOKit/pci/IOPCIDevice.h", "Library/x86_64/libkmod.a"):
        if not (sdk / rel).is_file():
            raise ValueError(f"SDK file missing: {rel}")
    firmware_text = (source / "include/FwBinary.cpp").read_text(encoding="utf-8")
    firmware = {}
    for symbol in ("mwx_mt7961_patch_mcu_1_2_hdr", "mwx_mt7961_ram_code_1"):
        match = re.search(r"unsigned char " + symbol + r"\[\]\s*=\s*\{([^}]+)\};", firmware_text)
        length = re.search(r"unsigned int " + symbol + r"_len\s*=\s*(\d+);", firmware_text)
        if not match or not length:
            raise ValueError(f"Firmware array missing: {symbol}")
        data = bytes(int(x, 16) for x in re.findall(r"0x([0-9a-fA-F]{2})\b", match[1]))
        if len(data) != int(length[1]):
            raise ValueError(f"Firmware array length mismatch: {symbol}")
        firmware[symbol] = {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
    project = source / "SimpleMtkWlan.xcodeproj/project.pbxproj"
    project_text = project.read_text(encoding="utf-8")
    old = "/Users/laobamac/Desktop/MacKernelSDK/Headers"
    if project_text.count(old) != 4:
        raise ValueError("Unexpected upstream build settings; review before preparing")
    return {
        "sources": lock,
        "pci_match": personality["IOPCIPrimaryMatch"],
        "firmware": firmware,
        "absolute_header_paths_to_replace": 4,
        "validation": "static input checks only; no compilation or hardware test",
    }


def prepare(destination, evidence):
    # Only fresh directories beneath this package's work/; never an EFI path.
    work = (ROOT / "work").resolve()
    destination = destination.resolve()
    if work not in destination.parents:
        raise ValueError("Destination must be a new directory beneath research/mt7921/work/")
    if destination.exists():
        raise ValueError("Destination exists; choose a new name (no overwrite)")
    shutil.copytree(ROOT / "upstream/SimpleMtkWlan", destination,
                    ignore=shutil.ignore_patterns(".git"))
    shutil.copytree(ROOT / "upstream/MacKernelSDK", destination / "MacKernelSDK",
                    ignore=shutil.ignore_patterns(".git"))
    project = destination / "SimpleMtkWlan.xcodeproj/project.pbxproj"
    text = project.read_text(encoding="utf-8").replace(
        "/Users/laobamac/Desktop/MacKernelSDK/Headers",
        '"$(PROJECT_DIR)/MacKernelSDK/Headers"',
    )
    project.write_text(text, encoding="utf-8", newline="\n")
    (destination / "input-evidence.json").write_text(
        json.dumps(evidence, indent=2) + "\n", encoding="utf-8"
    )
    return destination


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prepare", type=Path, help="Fresh directory under this package's work/")
    parser.add_argument("--build", action="store_true", help="Also run Xcode on macOS; never install")
    args = parser.parse_args()
    if args.build and (platform.system() != "Darwin" or not shutil.which("xcodebuild")):
        parser.error("--build requires macOS and Xcode; no files were changed")
    if args.build and not args.prepare:
        parser.error("--build requires --prepare with a fresh destination")
    evidence = inspect_inputs()
    print(json.dumps(evidence, indent=2))
    if args.prepare:
        destination = prepare(args.prepare, evidence)
        print(f"Prepared: {destination}")
        if args.build:
            command = ["xcodebuild", "-project", "SimpleMtkWlan.xcodeproj",
                       "-scheme", "SimpleMtkWlan", "-configuration", "Debug",
                       "-derivedDataPath", str(destination / "DerivedData"),
                       "ARCHS=x86_64", "CODE_SIGNING_ALLOWED=NO",
                       "KERNEL_FRAMEWORK_HEADERS=$(PROJECT_DIR)/MacKernelSDK/Headers", "build"]
            with (destination / "build.log").open("w", encoding="utf-8") as log:
                result = subprocess.run(command, cwd=destination, stdout=log, stderr=subprocess.STDOUT)
            print(f"Xcode exit: {result.returncode}; log: {destination / 'build.log'}")
            return result.returncode
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f"STOP: {error}", file=sys.stderr)
        sys.exit(1)
