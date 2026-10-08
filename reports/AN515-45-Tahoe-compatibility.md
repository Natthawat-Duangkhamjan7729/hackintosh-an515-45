# Acer Nitro AN515-45: Tahoe compatibility audit

Date: 2026-10-09 (Asia/Bangkok)

Update: the user has selected **Sequoia 15.8.1** instead. This is a historical Tahoe audit, not the active configuration plan. See `D:/Hackintosh/staging/AN515-45-Tahoe/TARGET.json` and `PREPARATION.md`.
Correction: the original categorical NVIDIA claim below was outdated. NullMoth now provides an experimental NVIDIA Metal driver; upstream lists RTX 30 in its device coverage, with Ampere hardware qualification pending. Sequoia 15.8.1 tests on other hardware do not establish support for this laptop's RTX 3060 or AMD-connected internal panel. Sources: https://github.com/nullmoth/nvidia-macos-driver and https://github.com/nullmoth/nvidia-macos-driver/blob/main/docs/CARD-SUPPORT.md .
USB update: an experimental map has now been generated and structurally reviewed; see `D:/Hackintosh/staging/AN515-45-Tahoe/USB-MAP-REVIEW.md`.

## Outcome

An experimental Tahoe EFI is technically plausible. CPU kernel patch support exists; this is not a boot-tested configuration. The main uncertainty is accelerated graphics and stability on the Cezanne APU for the exact Tahoe build. Do not present the laptop as fully supported.

## Evidence

- Local HWiNFO report supplied by the user: actual component models and PCI IDs below.
- User screenshot: the internal display currently connects to AMD Radeon Graphics in Windows; external displays are outside the requested scope. macOS display operation remains untested.
- OEM ACPI dump: DSDT and 16 SSDTs. DSDT disassembled with SSDTs as external tables using ACPICA iasl 20260408. This is inspection, not compilation or semantic validation of modified ACPI.
- Firmware contains EC0 (PNP0C09), RTC (PNP0B00), and PEGP under PCI0.GPP0. Presence alone does not justify any rename, disablement or additional SSDT.

## Component matrix

| Component | Observed hardware | Tahoe assessment | Confidence / missing evidence |
| --- | --- | --- | --- |
| CPU | Ryzen 7 5800H, Cezanne, 8 physical cores / 16 threads | Conditional: AMD Vanilla explicitly lists Zen families and Tahoe support. Requires matched kernel patches; CPU patch support does not establish laptop power/sleep support. | High for patch availability; machine boot untested |
| iGPU | Cezanne Radeon Vega, 1002:1638 | Conditional: community NootedRed route; no native macOS support. Upstream still tracks rendering, compute, sleep and Tahoe brightness issues. | Medium for feasibility; exact Tahoe build and graphics behavior unverified |
| dGPU | RTX 3060 Laptop, 10DE:2520 | Experimental NullMoth driver now exists; initial EFI remains planned around AMD iGPU. A machine-specific power/display plan is required. | Ampere hardware, Tahoe, and laptop display path unverified |
| Internal panel | 1920x1080, 144 Hz; connected to AMD in Windows | Current Windows route supports investigating an iGPU-based candidate. Brightness, refresh rates and macOS output untested. | Windows evidence only |
| Analog audio | Realtek ALC295, 10EC:0295 | Conditional: Tahoe removes AppleHDA; ordinary AppleALC injection alone will not restore speakers/jack. Alternative audio or separately justified patches needed. | High for OS change; laptop implementation untested |
| Ethernet | Killer E2600, 10EC:2600 | Driver candidate to investigate; do not equate marketing name with a confirmed RTL8111 binary match. | Hardware identified; exact driver ID match and version pending |
| Wi-Fi | MediaTek MT7921, 14C3:7961 | No verified Tahoe driver selected. Plan initial recovery installation around verified wired networking. | Hardware high; support unresolved |
| Bluetooth | MediaTek USB device | Not yet assessed separately from Wi-Fi. | Exact USB ID / driver support pending |
| Existing storage | Apacer AS2280P4 512 GB NVMe; Toshiba MQ01ABD100 1 TB SATA HDD | Inventory only. User selected a separate spare SSD for macOS; installation postponed until fitted. | Spare SSD model and capacity pending |
| Keyboard / trackpad | PS/2 keyboard, AMD I2C / HID device | Requires device-specific planning. | Trackpad HID and ACPI interrupt details pending |
| USB | AMD xHCI controllers | Physical port mapping still required for a complete configuration. | USB map absent |
| Firmware | Insyde V1.14; board Scala_CAS | ACPI evidence available. Quirks require firmware-specific justification. | BIOS settings not yet fully inventoried |

## Sources checked

- [AMD Vanilla upstream](https://github.com/AMD-OSX/AMD_Vanilla): Zen families, Tahoe, physical core count and patch requirements.
- [NootedRed upstream changelog](https://github.com/ChefKissInc/NootedRed/blob/master/CHANGELOG.md): v0.8.10 dated 2026-05-15; do not assume this alone is the newest artifact or proves all Tahoe builds work.
- [NootedRed open issues](https://github.com/ChefKissInc/NootedRed/issues): rendering/compute, sleep and Tahoe brightness limitations. These are project-wide risks, not proof this Acer has those symptoms.
- [Dortania NVIDIA guide](https://dortania.github.io/GPU-Buyers-Guide/modern-gpus/nvidia-gpu.html): Ampere unsupported.
- [Dortania AMD guide](https://dortania.github.io/GPU-Buyers-Guide/modern-gpus/amd-gpu.html): Cezanne Vega APU community graphics route.
- [Dortania Tahoe guide](https://dortania.github.io/OpenCore-Install-Guide/extras/tahoe.html): audio and target OS caveats.
- [RealtekRTL8111 upstream](https://github.com/Mieze/RTL8111_driver_for_OS_X): investigate exact Ethernet match before selection; AMD-specific version guidance must be checked against the selected release.

## Next work

1. Pin exact Tahoe installer build, OpenCore release and upstream binary versions.
2. Resolve Ethernet driver matching, trackpad details, USB mapping and GPU power methods from the supplied evidence.
3. Assemble a separate candidate with a manifest and explain every ACPI/quirk choice. Keep unresolved identity fields private.
4. Validate using release-matched ocvalidate and compile any new ASL. These checks do not establish boot success.
5. Boot from a prepared USB first. Install to the spare SSD only once it is fitted and positively identified.

The OEM dump remains local and unmodified. MSDM tables may contain a Windows product key; do not publish the raw dump or include it in an EFI release.
