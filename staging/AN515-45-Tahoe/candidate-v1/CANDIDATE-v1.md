# candidate-v1 — AN515-45-R375 / macOS Sequoia 15.8.1

Status: **candidate, schema-validated** (ocvalidate 1.0.8: no issues, see `ocvalidate.txt`). **Not boot-tested.** Rebuild with `py -3.12 -I tools/build_candidate.py .` from the stage folder. The build starts from OpenCore 1.0.8 `Docs/Sample.plist`.

## Identity (must do before use)

`PlatformInfo -> Generic` has `SystemProductName = MacBookPro16,2`. Serial, MLB, SystemUUID and ROM are still Sample.plist placeholders. Generate unique values locally (for example with GenSMBIOS), enter them on your own copy, and never share them. Placeholder values are enough for installing; Apple services will not work with them.

## Artifacts

| Item | Version | Source | Why |
| --- | --- | --- | --- |
| OpenCore DEBUG (BOOTx64, OpenCore.efi, OpenRuntime, OpenHfsPlus, ResetNvramEntry) | 1.0.8 | acidanthera/OpenCorePkg release 1.0.8 | Matching binaries and schema. OpenHfsPlus is needed for HFS+ Recovery/BaseSystem. |
| SSDT-EC-USBX.aml | local, iasl 20260408 | Dortania SSDT-EC-USBX-LAPTOP reference | macOS needs an EC device and USB power properties. Real EC0 is left intact. |
| SSDT-XOSI.aml + DSDT `_OSI`→`XOSI` | local, iasl 20260408 | Dortania SSDT-XOSI.dsl | Under Darwin, OSYS stays 0x07D9. At that value `\_SB.I2CD.TPAD._CRS` returns `SBFI`, an interrupt with no I2CSerialBus. VoodooI2C needs OSYS ≥0x07DC, which returns `SBFB+SBFG`. The rename is limited to DSDT (`TableSignature=DSDT`); SSDT13's own `_OSI` calls are unchanged. TSOS stays ≥0x70, so I2CD `_STA` remains enabled. ChefKiss lists XOSI for AMD laptops. |
| Lilu | 1.7.2 | acidanthera | Dependency of the plugins below |
| VirtualSMC + SMCBatteryManager | 1.3.8 | acidanthera | SMC emulation and laptop battery. SMCSuperIO is not used (ChefKiss: not for AMD). |
| ECEnabler | 1.0.6 | averycblack/ECEnabler | Battery EC fields wider than 8 bits (ChefKiss: needed on laptops) |
| ForgedInvariant | 1.5.0 | ChefKissInc | TSC sync (ChefKiss: necessary for laptops) |
| NootedRed | 0.8.10 | ChefKissInc | Cezanne iGPU 1002:1638. NootedRed lists MacBookPro16,2 as a supported SMBIOS. WhateverGreen is not included (conflicts). |
| VoodooPS2Controller + Keyboard plugin | 2.3.7 | acidanthera | KBC0 `_CID PNP0303` matches the controller's IONameMatch. PS2 Mouse/Trackpad and the PS2 copy of VoodooInput are not loaded because the touchpad is I2C. |
| VoodooGPIO, VoodooI2CServices, VoodooInput 1.1.6, VoodooI2C, VoodooI2CHID | 2.9.1 | VoodooI2C release | AMDI0010 (I2CD) and AMDI0030 (GPIO) are in DSDT and in the kext personalities. Touchpad ELAN050A uses `_CID PNP0C50`, so HID is the satellite. |
| RealtekRTL8111 | 3.0.0 (bundle 3.0.4) | Mieze release v3.0.0 | IOPCIMatch includes `0x260010ec`, which matches the Killer E2600 seen in PCI. AppleVTD does not apply to AMD. |
| USBMap.kext (codeless) | local | Converted from the reviewed UTBMap | Same ports and connector types as `USB-MAP-REVIEW.md`. Uses native `AppleUSBHostMergeProperties` with `model=MacBookPro16,2` (ChefKiss USBToolBox guidance), so USBToolBox.kext is not used. The USB-C type and the unverified companions remain open. |
| AMD Vanilla patches | eaf52ef, 8-core edit | AMD-OSX/AMD_Vanilla | 25 entries, 22 enabled as upstream (the AM5 and alternate PAT entries stay disabled). Darwin 24 is within each enabled entry's range. |

Kernel → Add order: Lilu → VirtualSMC → SMCBatteryManager → ECEnabler → ForgedInvariant → NootedRed → VoodooPS2Controller → PS2Keyboard → VoodooGPIO → VoodooI2CServices → VoodooInput → VoodooI2C → VoodooI2CHID → RealtekRTL8111 → USBMap. Every dependency (from OSBundleLibraries) loads before its dependent.

## Non-default settings

| Key | Value | Evidence |
| --- | --- | --- |
| Booter EnableWriteUnprotector / RebuildAppleMemoryMap / SyncRuntimePermissions | false / true / true | The firmware publishes a MAT (`firmware-evidence/FIRMWARE-FINDINGS.md`). OpenCore 1.0.8 RebuildAppleMemoryMap Note 2 and the Dortania Zen guide agree. Fallback if boot stops at an early stage: RebuildAppleMemoryMap=false and EnableWriteUnprotector=true. |
| Other Booter quirks | Sample defaults (AvoidRuntimeDefrag, EnableSafeModeSlide, ProvideCustomSlide, SetupVirtualMap = true) | Matches Dortania Zen. The firmware log showed nothing that requires a change. |
| Kernel ProvideCurrentCpuInfo, PanicNoKextDump, PowerTimeoutKernelPanic | true | Dortania Zen; required for AMD CPU info |
| Kernel XhciPortLimit | false | Dortania: not functional on 11.3+; a USB map is provided instead |
| Misc Security | ScanPolicy 0, Vault Optional, SecureBootModel Default, AllowSetDefault true | Dortania Zen. If installation fails with a Security Violation, try SecureBootModel=Disabled. |
| Misc Debug | AppleDebug, ApplePanic, DisableWatchDog true, Target 67 | Logs from the first boot |
| Misc Boot | HideAuxiliary false, Timeout 5 | Shows Recovery/installer entries |
| NVRAM boot-args | `-v keepsyms=1 debug=0x100` | Diagnostic first boot. `npci` is not used because the GOP framebuffer above 4 GiB indicates Above 4G decoding. |
| PlatformInfo | MacBookPro16,2, UpdateSMBIOSMode Create | Recommended by NootedRed, supported by Sequoia; Acer is not a Dell, so Custom mode is not needed |
| UEFI | RequestBootVarRouting true, ConnectDrivers true | Dortania Zen |

## Not included / open

- The RTX 3060 (10DE:2520) has no macOS driver and is left untouched. It will probably stay powered and drain the battery. No dGPU-off SSDT has been chosen yet (see GPU power notes in PROGRESS).
- Audio (ALC295, AppleALC), Wi-Fi/Bluetooth (MT7921), backlight (NootedRed SSDT-PNLF/ALS0 + SMCLightSensor + BrightnessKeys) and NVMeFix (spare SSD unknown) are deferred until after the first boot.
- AppleMCEReporterDisabler is not included. Dortania lists it for MacPro6,1, MacPro7,1 and iMacPro1,1. Add it if a panic names AppleIntelMCEReporter.
- UMA is still 512 MiB; NootedRed asks for 1 GiB or more. This is a BIOS setting for the user to check.

## Rollback

This candidate is separate from `firmware-diagnostics/` and from E:. Nothing was written to any EFI partition or USB.
