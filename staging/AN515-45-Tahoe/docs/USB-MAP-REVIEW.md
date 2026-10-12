# USB map review — 2026-10-09

Status: structurally reviewed experimental map; not boot-tested.

Original: `tools/UTBMap.kext`. Preserved copy: `components/Kexts/UTBMap.kext`.
Companion: `components/Kexts/USBToolBox.kext`, version 1.2.0.
Source: https://github.com/USBToolBox/kext/releases/tag/1.2.0

The XML parses successfully. Both IONameMatch values (XHC0 and XHC1) occur as devices in the resolved OEM DSDT. Runtime matching still requires macOS confirmation. Each controller contains five unique logical port numbers, below the 15-port limit. `port-count` is 6, the highest port number, and is not the count of retained entries.

| Controller | Generated name | Logical port | Connector value | Evidence |
| --- | --- | --- | --- | --- |
| XHC0 | HS01 | 1 | 9 | iPhone/mouse observed; USB-C switch behavior remains guessed |
| XHC0 | HS02 | 2 | 3 | Mouse observed on USB-A |
| XHC0 | HS03 | 4 | 255 | Wireless_Device observed internally |
| XHC0 | SS01 | 5 | 9 | Companion to port 1; USB 3 and both orientations unverified |
| XHC0 | SS02 | 6 | 3 | Ugreen observed operating at USB 3.0 |
| XHC1 | HS01 | 1 | 3 | Mouse and Ugreen USB 2 observed |
| XHC1 | HS02 | 2 | 3 | Mouse, Ugreen USB 2, and headset observed |
| XHC1 | HS03 | 3 | 255 | HD User Facing camera observed |
| XHC1 | SS01 | 5 | 3 | Ugreen observed operating at USB 3.0 |
| XHC1 | SS02 | 6 | 3 | Tool-reported companion to port 2; USB 3 connection unverified |

XHC0 logical port 3 and XHC1 logical port 4 are omitted because no attached device was observed. Physical left/right connector labels were not supplied. Generated names such as HS03 do not necessarily equal the original logical port number; the binary `port` value is authoritative.

USB-C connector value 9 is retained from the user's generated map as an explicitly unverified draft value. It is not a verified final choice between type 9 and type 10. Confirm both orientations with a USB 3 capable device before finalizing that connector. Retaining XHC1 port 6 preserves the reported companion while awaiting its physical verification.

UTBMap declares dependency `com.dhinakg.USBToolBox.kext` >=1.0.0; downloaded USBToolBox is 1.2.0. Future Kernel/Add order: USBToolBox first, UTBMap second. UTBMap is codeless: ExecutablePath must be empty, PlistPath `Contents/Info.plist`. Do not include UTBDefault with this map. No config entries have been created yet, and no EFI partition has been modified.

SHA256 of original and copied map Info.plist (identical):
`C4D68E4351A44E59C8A81FA7179F3648C2B751293D1D5953CC363D5FF470FA15`

SHA256 of upstream USBToolBox-1.2.0-RELEASE.zip:
`C315A3A5ACFD496DD97D0D19B4FBD1D487103D2FD541C5651583D4C9CEBCFE07`

These are local integrity records, not independently verified signatures. Upstream general OS support does not constitute a Tahoe boot test on this Acer. To roll back preparation, leave the components unused; original map remains in tools.

## 2026-10-13: macOS 26 keys

macOS 26 (Tahoe) reads `usb-port-number`/`usb-port-type` per port (corpnewt/USBMap 4689a1a, d6eaa0a). `tools/build_candidate.py` now emits USBMap 1.2 with both the old and the new keys, with unchanged port numbers and connector values. Untested on Tahoe hardware at the time of writing.
