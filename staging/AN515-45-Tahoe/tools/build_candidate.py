"""Assemble candidate EFI (default candidate-v10) for AN515-45 / Sequoia 15.8.1 from pinned local artifacts.

Starts from OpenCore 1.0.8 Sample.plist. Every non-default value below is tied to
evidence recorded in candidates/candidate-v1/CANDIDATE-v1.md and docs/PROGRESS (v2 adds SSDT-CPUR, v3 adds NVMeFix, v4 SecureBootModel=Disabled, v5 backlight: SSDT-PNLF/ALS0 + SMCLightSensor + BrightnessKeys, v6 AppleALC alcid test, v7 layout-id 21, v8 SimpleMtkBtFw BT test, v9 PciRoot(0x1) fix, v10 UpdateSMBIOSMode=Custom + CustomSMBIOSGuid so Windows keeps the Acer SMBIOS, USBMap 1.2 adds the macOS 26 usb-port-number/usb-port-type keys; --voodoohda adds VoodooHDA 3.7.0-alpha for Tahoe audio; --nodgpu adds SSDT-Acer-NoHybGfx (RTX 3060 off in Darwin); pass --bt for experimental BT kexts (SimpleMtkBtFw + Patcher; tahoe4 adds BlueToolFixup 2.7.2 and the bluetoothExternalDongleFailed/bluetoothInternalControllerInfo NVRAM keys). Identity fields keep Sample.plist placeholders;
generate real values locally and never commit them.
Usage: py -3.12 -I tools/build_candidate.py <stage-dir> [candidate-name] [--private] [--bt] [--tahoe] [--install] [--voodoohda] [--nodgpu]
Output: <stage-dir>/candidates/<name>/EFI (or <stage-dir>/private-build/<name>/EFI with --private).
"""
import copy
import pathlib
import plistlib
import shutil
import sys

EXPERIMENTAL_BT = "--bt" in sys.argv
PRIVATE = "--private" in sys.argv  # apply private/PlatformInfo.json and write to the gitignored private-build/ folder
TAHOE = "--tahoe" in sys.argv  # macOS 26: AppleHDA was removed, so AppleALC has nothing to patch; disable it
INSTALL = "--install" in sys.argv  # install stage: NootedRed off, firmware framebuffer only (as for the Sequoia install)
VOODOOHDA = "--voodoohda" in sys.argv  # macOS 26 audio: VoodooHDA 3.7.0-alpha (IOAudioFamily embedded, OpenCore-injectable); needs --tahoe
NODGPU = "--nodgpu" in sys.argv  # SSDT-Acer-NoHybGfx: power off the RTX 3060 in Darwin (its IONDRVFramebuffer disables clamshell sleep)
sys.argv = [a for a in sys.argv if a not in ("--bt", "--private", "--tahoe", "--install", "--voodoohda", "--nodgpu")]
assert not VOODOOHDA or TAHOE, "--voodoohda requires --tahoe (AppleALC must be disabled)"
stage = pathlib.Path(sys.argv[1]).resolve()
pkg = stage / "packages"
oc_pkg = pkg / "OpenCore-1.0.8-DEBUG" / "X64" / "EFI"
out = stage / ("private-build" if PRIVATE else "candidates") / (sys.argv[2] if len(sys.argv) > 2 else "candidate-v10") / "EFI"
if out.parent.exists():
    shutil.rmtree(out.parent)
(out / "OC").mkdir(parents=True)

# Binaries from the same OpenCore release
shutil.copytree(oc_pkg / "BOOT", out / "BOOT")
shutil.copy2(oc_pkg / "OC" / "OpenCore.efi", out / "OC")
for d in ("ACPI", "Drivers", "Kexts", "Tools", "Resources"):
    (out / "OC" / d).mkdir()
drivers = ["OpenRuntime.efi", "OpenHfsPlus.efi", "ResetNvramEntry.efi"]
for drv in drivers:
    shutil.copy2(oc_pkg / "OC" / "Drivers" / drv, out / "OC" / "Drivers")

acpi = ["SSDT-EC-USBX.aml", "SSDT-XOSI.aml", "SSDT-CPUR.aml", "SSDT-PNLF.aml", "SSDT-ALS0.aml"]
if NODGPU:
    acpi.append("SSDT-Acer-NoHybGfx.aml")
for a in acpi:
    shutil.copy2(stage / "components" / "ACPI" / a, out / "OC" / "ACPI")

# Kext bundles to copy: (source, bundle name)
bundles = [
    (pkg / "Lilu-1.7.2-RELEASE" / "Lilu.kext", "Lilu.kext"),
    (pkg / "VirtualSMC-1.3.8-RELEASE" / "Kexts" / "VirtualSMC.kext", "VirtualSMC.kext"),
    (pkg / "VirtualSMC-1.3.8-RELEASE" / "Kexts" / "SMCBatteryManager.kext", "SMCBatteryManager.kext"),
    (pkg / "VirtualSMC-1.3.8-RELEASE" / "Kexts" / "SMCLightSensor.kext", "SMCLightSensor.kext"),
    (pkg / "ECEnabler-1.0.6-RELEASE" / "ECEnabler.kext", "ECEnabler.kext"),
    (pkg / "ForgedInvariant-1.5.0-RELEASE" / "ForgedInvariant.kext", "ForgedInvariant.kext"),
    (pkg / "NVMeFix-1.1.3-RELEASE" / "NVMeFix.kext", "NVMeFix.kext"),
    (pkg / "NootedRed-0.8.10-RELEASE" / "NootedRed.kext", "NootedRed.kext"),
    (pkg / "BrightnessKeys-1.0.3-RELEASE" / "BrightnessKeys.kext", "BrightnessKeys.kext"),
    (pkg / "AppleALC-1.9.8-RELEASE" / "AppleALC.kext", "AppleALC.kext"),
    (pkg / "VoodooPS2Controller-2.3.7-RELEASE" / "VoodooPS2Controller.kext", "VoodooPS2Controller.kext"),
    (pkg / "VoodooI2C-2.9.1-RELEASE" / "VoodooI2C.kext", "VoodooI2C.kext"),
    (pkg / "VoodooI2C-2.9.1-RELEASE" / "VoodooI2CHID.kext", "VoodooI2CHID.kext"),
    (pkg / "RealtekRTL8111-V3.0.0" / "RealtekRTL8111-V3.0.0" / "Release" / "RealtekRTL8111.kext", "RealtekRTL8111.kext"),
]
if EXPERIMENTAL_BT:
    bundles += [
    (pkg / "SimpleMtkBtFw-1.0.0-RELEASE" / "SimpleMtkBtFw-1.0.0-RELEASE" / "SimpleMtkBtFw.kext", "SimpleMtkBtFw.kext"),
    (pkg / "SimpleMtkBtFw-1.0.0-RELEASE" / "SimpleMtkBtFw-1.0.0-RELEASE" / "SimpleMtkBtPatcher.kext", "SimpleMtkBtPatcher.kext"),
    (pkg / "BrcmPatchRAM-2.7.2-RELEASE" / "BlueToolFixup.kext", "BlueToolFixup.kext"),
    ]
if VOODOOHDA:
    bundles.append((pkg / "VoodooHDA-3.7.0-alpha-560847a" / "VoodooHDA_BL.kext", "VoodooHDA.kext"))
for src, name in bundles:
    shutil.copytree(src, out / "OC" / "Kexts" / name)
if VOODOOHDA:
    # Upstream matches only IONameMatch "HDAS"; this controller is ACPI AZAL (compatible pci1025,151e / pci1022,15e3 / AZAL).
    # Add the AMD HDA controller ID only, so the RTX 3060 HDMI audio function (10DE) is not claimed.
    vplist = out / "OC" / "Kexts" / "VoodooHDA.kext" / "Contents" / "Info.plist"
    vinfo = plistlib.loads(vplist.read_bytes())
    assert vinfo["IOKitPersonalities"]["VoodooHDA"]["IONameMatch"] == "HDAS"
    vinfo["IOKitPersonalities"]["VoodooHDA"]["IONameMatch"] = ["HDAS", "pci1022,15e3"]
    vplist.write_bytes(plistlib.dumps(vinfo, sort_keys=False))

# Native-class USB map derived from the reviewed UTBMap (same ports/types), per ChefKiss guidance
utb = plistlib.loads((stage / "components" / "Kexts" / "UTBMap.kext" / "Contents" / "Info.plist").read_bytes())
usbmap = {k: v for k, v in utb.items() if k not in ("IOKitPersonalities", "OSBundleLibraries")}
usbmap["CFBundleIdentifier"] = "local.an515-45.USBMap"
usbmap["CFBundleName"] = "USBMap"
usbmap["IOKitPersonalities"] = {}
for name, pers in utb["IOKitPersonalities"].items():
    usbmap["IOKitPersonalities"][name] = {
        "CFBundleIdentifier": "com.apple.driver.AppleUSBHostMergeProperties",
        "IOClass": "AppleUSBHostMergeProperties",
        "IOProviderClass": "AppleUSBHostController",
        "IOParentMatch": {"IONameMatch": pers["IONameMatch"]},
        "IOProviderMergeProperties": copy.deepcopy(pers["IOProviderMergeProperties"]),
        "model": "MacBookPro16,2",
    }
    # macOS 26 reads usb-port-number/usb-port-type instead of port/UsbConnector; keep both
    # (corpnewt/USBMap 4689a1a "Update keys for macOS 26")
    for port in usbmap["IOKitPersonalities"][name]["IOProviderMergeProperties"]["ports"].values():
        port["usb-port-number"] = port["port"]
        port["usb-port-type"] = port["UsbConnector"]
usbmap["CFBundleShortVersionString"] = usbmap["CFBundleVersion"] = "1.2"
usbmap["CFBundleGetInfoString"] = "v1.2"
usb_dir = out / "OC" / "Kexts" / "USBMap.kext" / "Contents"
usb_dir.mkdir(parents=True)
(usb_dir / "Info.plist").write_bytes(plistlib.dumps(usbmap, sort_keys=True))

cfg = plistlib.loads((stage / "packages" / "OpenCore-1.0.8-DEBUG" / "Docs" / "Sample.plist").read_bytes())
for k in [k for k in cfg if k.startswith("#")]:
    del cfg[k]

# ACPI
cfg["ACPI"]["Add"] = [{"Comment": a, "Enabled": True, "Path": a} for a in acpi]
cfg["ACPI"]["Delete"] = []
cfg["ACPI"]["Patch"] = [{
    "Base": "", "BaseSkip": 0,
    "Comment": "Rename _OSI to XOSI in DSDT only (TPAD _CRS needs OSYS>=0x07DC; pairs with SSDT-XOSI)",
    "Count": 0, "Enabled": True,
    "Find": bytes.fromhex("5F4F5349"), "Limit": 0, "Mask": b"",
    "OemTableId": b"", "Replace": bytes.fromhex("584F5349"), "ReplaceMask": b"",
    "Skip": 0, "TableLength": 0, "TableSignature": b"DSDT",
}]

# Booter: firmware publishes a MAT (firmware-evidence/FIRMWARE-FINDINGS.md)
cfg["Booter"]["MmioWhitelist"] = []
cfg["Booter"]["Patch"] = []
bq = cfg["Booter"]["Quirks"]
bq["EnableWriteUnprotector"] = False
bq["RebuildAppleMemoryMap"] = True
bq["SyncRuntimePermissions"] = True

# DeviceProperties paths must use PciRoot(0x1): macOS matches by ACPI _UID and \_SB.PCI0 has _UID 1 (PciRoot(0x0) silently failed in v7)
# AppleALC: ALC295 layout 21 (Acer Nitro 5 Spin) verified on this machine via alcid=21 (speakers/mic/headset switching)
cfg["DeviceProperties"]["Add"] = {"PciRoot(0x1)/Pci(0x8,0x1)/Pci(0x0,0x6)": {"layout-id": (21).to_bytes(4, "little")}}
cfg["DeviceProperties"]["Delete"] = {}

# Kernel
def kext(bundle, exe, plist="Contents/Info.plist", comment=""):
    return {"Arch": "x86_64", "BundlePath": bundle, "Comment": comment or bundle, "Enabled": True,
            "ExecutablePath": exe, "MaxKernel": "", "MinKernel": "", "PlistPath": plist}

cfg["Kernel"]["Add"] = [
    kext("Lilu.kext", "Contents/MacOS/Lilu"),
    kext("VirtualSMC.kext", "Contents/MacOS/VirtualSMC"),
    kext("SMCBatteryManager.kext", "Contents/MacOS/SMCBatteryManager"),
    kext("SMCLightSensor.kext", "Contents/MacOS/SMCLightSensor"),
    kext("ECEnabler.kext", "Contents/MacOS/ECEnabler"),
    kext("ForgedInvariant.kext", "Contents/MacOS/ForgedInvariant"),
    kext("NVMeFix.kext", "Contents/MacOS/NVMeFix"),
    kext("NootedRed.kext", "Contents/MacOS/NootedRed"),
    kext("BrightnessKeys.kext", "Contents/MacOS/BrightnessKeys"),
    kext("AppleALC.kext", "Contents/MacOS/AppleALC"),
    kext("VoodooPS2Controller.kext", "Contents/MacOS/VoodooPS2Controller"),
    kext("VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Keyboard.kext", "Contents/MacOS/VoodooPS2Keyboard"),
    kext("VoodooI2C.kext/Contents/PlugIns/VoodooGPIO.kext", "Contents/MacOS/VoodooGPIO"),
    kext("VoodooI2C.kext/Contents/PlugIns/VoodooI2CServices.kext", "Contents/MacOS/VoodooI2CServices"),
    kext("VoodooI2C.kext/Contents/PlugIns/VoodooInput.kext", "Contents/MacOS/VoodooInput"),
    kext("VoodooI2C.kext", "Contents/MacOS/VoodooI2C"),
    kext("VoodooI2CHID.kext", "Contents/MacOS/VoodooI2CHID"),
    kext("RealtekRTL8111.kext", "Contents/MacOS/RealtekRTL8111"),
    kext("USBMap.kext", ""),
]
if EXPERIMENTAL_BT:  # insert right after AppleALC
    i = [e["BundlePath"] for e in cfg["Kernel"]["Add"]].index("AppleALC.kext") + 1
    cfg["Kernel"]["Add"][i:i] = [
        kext("SimpleMtkBtFw.kext", "Contents/MacOS/SimpleMtkBtFw", comment="EXPERIMENTAL: MediaTek BT firmware loader (04CA:3802)"),
        kext("SimpleMtkBtPatcher.kext", "Contents/MacOS/SimpleMtkBtPatcher", comment="EXPERIMENTAL: Lilu patcher for SimpleMtkBtFw"),
        kext("BlueToolFixup.kext", "Contents/MacOS/BlueToolFixup", comment="BrcmPatchRAM 2.7.2 BlueToolFixup: bluetoothd patches, required on macOS 12+ (2.7.2 adds macOS 26)"),
    ]
if VOODOOHDA:  # insert right after AppleALC (disabled by --tahoe)
    i = [e["BundlePath"] for e in cfg["Kernel"]["Add"]].index("AppleALC.kext") + 1
    cfg["Kernel"]["Add"].insert(i, kext("VoodooHDA.kext", "Contents/MacOS/VoodooHDA_BL", comment="VoodooHDA 3.7.0-alpha 560847a: Tahoe audio (ALC295 on AMD 1022:15E3); IONameMatch += pci1022,15e3"))
for e in cfg["Kernel"]["Add"]:
    if TAHOE and e["BundlePath"] == "AppleALC.kext":
        e.update(Enabled=False, Comment="AppleALC.kext (disabled: macOS 26 has no AppleHDA)")
    if INSTALL and e["BundlePath"] == "NootedRed.kext":
        e.update(Enabled=False, Comment="NootedRed.kext (disabled for the install stage)")
cfg["Kernel"]["Block"] = []
cfg["Kernel"]["Force"] = []
cfg["Kernel"]["Patch"] = plistlib.loads((stage / "components" / "AMD-Vanilla-5800H-8cores.plist").read_bytes())["Kernel"]["Patch"]
kq = cfg["Kernel"]["Quirks"]
kq.update(CustomSMBIOSGuid=True, PanicNoKextDump=True, PowerTimeoutKernelPanic=True, ProvideCurrentCpuInfo=True, XhciPortLimit=False)

# Misc
mb = cfg["Misc"]["Boot"]
mb.update(HideAuxiliary=False, PickerMode="Builtin", ShowPicker=True, Timeout=5)
md = cfg["Misc"]["Debug"]
md.update(AppleDebug=True, ApplePanic=True, DisableWatchDog=True, Target=67)
ms = cfg["Misc"]["Security"]
ms.update(AllowSetDefault=True, ScanPolicy=0, SecureBootModel="Disabled", Vault="Optional")  # Default (j214k) failed system-volume sealing (BORD, MSU 1130)
cfg["Misc"]["Entries"] = []
cfg["Misc"]["Tools"] = []

# NVRAM
guid = "7C436110-AB2A-4BBB-A880-FE41995C9F82"
add = cfg["NVRAM"]["Add"][guid]
add["boot-args"] = "-v keepsyms=1 debug=0x100"
add["csr-active-config"] = bytes(4)
add["prev-lang:kbd"] = b"en-US:0"
if EXPERIMENTAL_BT:  # BrcmPatchRAM README: required with BlueToolFixup for non-Broadcom (Intel) BT; same values macOS writes itself
    add["bluetoothExternalDongleFailed"] = b"\x00"
    add["bluetoothInternalControllerInfo"] = bytes(14)
    cfg["NVRAM"]["Delete"][guid] += ["bluetoothExternalDongleFailed", "bluetoothInternalControllerInfo"]
cfg["NVRAM"]["WriteFlash"] = True

# PlatformInfo: model only; serial/MLB/UUID/ROM stay as Sample.plist placeholders
cfg["PlatformInfo"]["Generic"]["SystemProductName"] = "MacBookPro16,2"
# Custom keeps the Mac SMBIOS macOS-only (OC 1.0.8 Configuration: "avoiding a collision with ... custom OEM software");
# with Create, Windows saw Acidanthera/MacBookPro16,2 next to Acer NitroSense/Quick Access, suspected for the intermittent dead internal keyboard
cfg["PlatformInfo"]["UpdateSMBIOSMode"] = "Custom"
if PRIVATE:
    import json
    ident = json.loads((stage / "private" / "PlatformInfo.json").read_text(encoding="utf-8-sig"))
    assert ident["SystemProductName"] == cfg["PlatformInfo"]["Generic"]["SystemProductName"]
    g = cfg["PlatformInfo"]["Generic"]
    g["SystemSerialNumber"] = ident["SystemSerialNumber"]
    g["MLB"] = ident["MLB"]
    g["SystemUUID"] = ident["SystemUUID"]
    g["ROM"] = bytes.fromhex(ident["ROM"])
    assert len(g["ROM"]) == 6

# UEFI
def drv(path, comment):
    return {"Arguments": "", "Comment": comment, "Enabled": True, "HideVerbose": False, "LoadEarly": False, "Path": path}

cfg["UEFI"]["Drivers"] = [
    drv("OpenRuntime.efi", "Required for Booter quirks"),
    drv("OpenHfsPlus.efi", "HFS+ for macOS Recovery/installer"),
    drv("ResetNvramEntry.efi", "Reset NVRAM picker entry"),
]
cfg["UEFI"]["ConnectDrivers"] = True
cfg["UEFI"]["Quirks"]["RequestBootVarRouting"] = True
cfg["UEFI"]["ReservedMemory"] = []

(out / "OC" / "config.plist").write_bytes(plistlib.dumps(cfg, sort_keys=False))
print("candidate written to", out)
