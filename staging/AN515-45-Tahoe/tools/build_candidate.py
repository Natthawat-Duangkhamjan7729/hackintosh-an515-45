"""Assemble candidate EFI (default candidate-v5) for AN515-45 / Sequoia 15.8.1 from pinned local artifacts.

Starts from OpenCore 1.0.8 Sample.plist. Every non-default value below is tied to
evidence recorded in CANDIDATE-v1.md and PROGRESS (v2 adds SSDT-CPUR, v3 adds NVMeFix, v4 SecureBootModel=Disabled, v5 backlight: SSDT-PNLF/ALS0 + SMCLightSensor + BrightnessKeys). Identity fields keep Sample.plist placeholders;
generate real values locally and never commit them.
Usage: py -3.12 -I tools/build_candidate.py <stage-dir> [candidate-name]
"""
import copy
import pathlib
import plistlib
import shutil
import sys

stage = pathlib.Path(sys.argv[1]).resolve()
pkg = stage / "packages"
oc_pkg = pkg / "OpenCore-1.0.8-DEBUG" / "X64" / "EFI"
out = stage / (sys.argv[2] if len(sys.argv) > 2 else "candidate-v5") / "EFI"
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
    (pkg / "VoodooPS2Controller-2.3.7-RELEASE" / "VoodooPS2Controller.kext", "VoodooPS2Controller.kext"),
    (pkg / "VoodooI2C-2.9.1-RELEASE" / "VoodooI2C.kext", "VoodooI2C.kext"),
    (pkg / "VoodooI2C-2.9.1-RELEASE" / "VoodooI2CHID.kext", "VoodooI2CHID.kext"),
    (pkg / "RealtekRTL8111-V3.0.0" / "RealtekRTL8111-V3.0.0" / "Release" / "RealtekRTL8111.kext", "RealtekRTL8111.kext"),
]
for src, name in bundles:
    shutil.copytree(src, out / "OC" / "Kexts" / name)

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

cfg["DeviceProperties"]["Add"] = {}
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
cfg["Kernel"]["Block"] = []
cfg["Kernel"]["Force"] = []
cfg["Kernel"]["Patch"] = plistlib.loads((stage / "components" / "AMD-Vanilla-5800H-8cores.plist").read_bytes())["Kernel"]["Patch"]
kq = cfg["Kernel"]["Quirks"]
kq.update(PanicNoKextDump=True, PowerTimeoutKernelPanic=True, ProvideCurrentCpuInfo=True, XhciPortLimit=False)

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
cfg["NVRAM"]["WriteFlash"] = True

# PlatformInfo: model only; serial/MLB/UUID/ROM stay as Sample.plist placeholders
cfg["PlatformInfo"]["Generic"]["SystemProductName"] = "MacBookPro16,2"
cfg["PlatformInfo"]["UpdateSMBIOSMode"] = "Create"

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
