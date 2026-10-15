# Acer AN515-45-R375 — Sequoia 15.8.1 preparation

Updated: 2026-10-09. Status: preparation bundle, not an assembled or boot-ready EFI.

Current progress: see `PROGRESS-2026-10-09.md`. Sequoia 15.8.1 build 24H32 is identified in Apple's catalog; partial downloads are paused for a firmware collection reboot. A separately schema-validated firmware-only diagnostic EFI is now on USB E:. The earlier preparation notes below are historical where superseded by that progress record.

## Evidence and scope

Hardware audit: `COMPATIBILITY-AUDIT.md` (this folder).
User confirmed target: macOS Sequoia 15.8.1, internal display, separate spare SSD (not fitted yet).
`TARGET.json` records the active target. The directory still contains Tahoe in its name to preserve existing tool/output paths; it is a historical label.
Initial boot will use the AMD Cezanne iGPU with NootedRed. Any NullMoth RTX 3060 Laptop experiment belongs in a later separate candidate after preserving a working initial EFI. Neither graphics path is boot-tested on this Acer.
Host: Windows only; no Ethernet cable. Offline installation path remains experimental.
Original OEM ACPI files are preserved. No writes to E:, system EFI partitions, or firmware settings were performed.

## Downloaded upstream artifacts

| Artifact | Pinned version | Source | Intended purpose/status |
| --- | --- | --- | --- |
| OpenCore DEBUG | 1.0.8 | https://github.com/acidanthera/OpenCorePkg/releases/tag/1.0.8 | Matching binaries, Sample.plist, Configuration.pdf and Windows ocvalidate; not installed |
| Lilu RELEASE | 1.7.2 | https://github.com/acidanthera/Lilu/releases/tag/1.7.2 | Dependency for selected plugins; not injected |
| VirtualSMC RELEASE | 1.3.8 | https://github.com/acidanthera/VirtualSMC/releases/tag/1.3.8 | SMC emulation; plugins not selected yet |
| NootedRed RELEASE | 0.8.10 | https://github.com/ChefKissInc/NootedRed/releases/tag/v0.8.10 | Conditional Cezanne graphics path; exact Tahoe build compatibility and boot behavior unverified |
| AMD Vanilla patches | eaf52ef292abf4ebec899df6d48626569ba50cc6 | https://github.com/AMD-OSX/AMD_Vanilla/tree/eaf52ef292abf4ebec899df6d48626569ba50cc6 | Untouched upstream patches.plist; physical-core replacements still to be applied to a future candidate |
| USBToolBox Windows tool | 0.2 | https://github.com/USBToolBox/tool/releases/tag/0.2 | Physical port discovery; downloaded, not executed |
| UnPlugged | e7e0696dcb6dee23d25422678a8bc90ac2597ef5 | https://github.com/corpnewt/UnPlugged/tree/e7e0696dcb6dee23d25422678a8bc90ac2597ef5 | Recovery-side offline installer helper; downloaded, not executed |

`checksums.json` records local SHA256 and byte sizes. These checksums record the downloaded bytes; they are not an independent upstream signature verification.
Archives are retained in `downloads/`, unpacked releases in `packages/`, user tools in `tools/`.

## Checks performed

- Read extracted kext Info.plist: Lilu 1.7.2, VirtualSMC 1.3.8, NootedRed 0.8.10.
- NootedRed declares Lilu >=1.7.0; VirtualSMC declares Lilu >=1.2.0. Downloaded Lilu meets these declared dependencies. Future Kernel/Add must load Lilu before either plugin.
- OpenCore archive includes its matching Windows ocvalidate.exe. No candidate config exists, so ocvalidate was not run.
- User generated an experimental USB map; reviewed and staged with USBToolBox 1.2.0. See `USB-MAP-REVIEW.md` for ports, checks and remaining uncertainties.
- No boot test, ACPI patch compilation, or storage installation performed.

## macOS and offline installer gate

Active target changed to **Sequoia 15.8.1** by explicit user request. Its exact Apple installer build/product and download availability remain unverified. No full installer has been downloaded. Reassess OS-dependent ACPI/kext/config choices against Sequoia before assembling a candidate; do not reuse Tahoe-specific audio conclusions.

NullMoth's upstream documents tests on Sequoia 15.8.1, but Ampere/laptop display routing remain unverified for this machine:
https://github.com/nullmoth/nvidia-macos-driver
https://github.com/nullmoth/nvidia-macos-driver/blob/main/docs/CARD-SUPPORT.md

The following Tahoe catalog notes are historical, not the current installer selection:

Apple's Tahoe update page lists 26.7.1 as of this review:
https://support.apple.com/en-us/122868

Do not treat this as a verified installer build selection. Exact Intel-compatible full-installer product/build and NootedRed/AMD patch applicability still require confirmation. The attempted public catalog URL returned HTTP 404; no InstallAssistant.pkg was downloaded and no third-party image was substituted.

UnPlugged's upstream instructions describe FAT32 boot/recovery plus ExFAT package storage. Sonoma and later Recovery require additional mounting steps or an older Recovery bootstrap. Tahoe on this laptop has not been verified with that procedure. A Monterey bootstrap would also require configuration and AMD patch compatibility for Monterey; do not assume Tahoe-only configuration is sufficient.
https://github.com/corpnewt/UnPlugged#notes-for-sonoma-and-later

The existing 55.90 GiB FAT32 media cannot store an individual file larger than 4 GiB. Repartitioning remains a later, explicitly scoped operation after installer selection and disk identity confirmation.

## USB discovery procedure (completed; remaining observations in USB-MAP-REVIEW.md)

1. Run `tools/USBToolBox-Windows-0.2.exe` from this folder.
2. Select **Discover Ports**, wait until the controller/port list populates, and send a screenshot of that screen.
3. Next, observe a known USB device in each physical port, waiting for detection before moving it. A USB 3 device is useful for companion port discovery on Windows. Confirm USB 2 behavior where possible. Test both orientations of USB-C if suitable hardware is available; otherwise mark that connector untested.
4. Preserve internal webcam/Bluetooth observations and controller identity. Do not disable internal ports or accept guessed connector types without review.
5. After reviewing the discoveries, select ports and build the map. A USBToolBox-based map also requires its separately pinned companion USBToolBox.kext.

Source: https://github.com/USBToolBox/tool#usage

## Remaining configuration work

- Review resolved ACPI namespace and GPU power methods; no generic dGPU-off SSDT has been selected.
- Confirm remaining USB-C/USB 3 observations and collect relevant trackpad HID/interrupt evidence.
- Exact Sequoia 15.8.1 installer build and offline Recovery plan.
- Firmware memory-map/Resize BAR evidence before choosing related quirks.
- SMBIOS selection and local private identity generation.
- Spare SSD model/capacity before installation.
- Assemble candidate only after compatibility gates, then check enabled references, plist types and release-matched ocvalidate. Schema checks do not prove boot.

## Rollback

This folder is preparation only. Leaving it unused restores the prior state; no original boot configuration was changed. Keep raw OEM dumps local, especially MSDM, which may contain a Windows license key.
