---
name: map-usb
description: Use to inventory physical USB ports, create or review a per-controller USB port map, address the macOS 15-port limit, or troubleshoot USB sleep/wake and internal Bluetooth mapping.
---

# USB port mapping workflow

Read `AGENTS.md` and `docs/opencore-framework/safety-and-evidence.md`. First determine the exact board/laptop, USB controller(s), macOS/OpenCore target, and whether the user wants an inventory, a map plan, or an actual map artifact.

1. Identify each physical controller and its ports using system evidence (IORegistry/IOReg on macOS, USBToolBox-compatible inventory on Windows where appropriate, ACPI/PCI information, and user-performed plug/flip observations). ACPI names alone do not reveal which physical connector maps to which logical port.
2. Inventory external USB-A, USB-C orientations, hubs, internal Bluetooth, webcam, card readers, and other internal devices. Record each physical connector's HS/SS companion personalities where present and the controller to which it belongs.
3. Count logical ports separately for each controller against the target macOS limit (normally 15 per controller in the cited guide). A USB 3 physical connector may expose both USB 2 and USB 3 personalities; identify the companions empirically. Do not drop working ports without reporting the tradeoff.
4. Assign connector types only from observed behavior and the tool/schema used. Common Apple USB connector values include `0` USB 2 Type-A, `3` USB 3 Type-A, `8` USB-C USB-2-only, `9` USB-C with switch, `10` USB-C without switch, and `255` internal. Determine Type-C switch behavior by testing both orientations; do not guess between 9 and 10.
5. Choose a supported mapping method for this machine (for example USBToolBox/UTBMap or USBMap) and pin its version. If generating a kext, verify the output structure/Info.plist, controller match, bundle IDs, and release/source. Register it only in a working EFI copy and keep file entries synchronized with `Kernel -> Add`.
6. Avoid using `XhciPortLimit` as a permanent substitute for mapping; check current version/platform guidance before any temporary mapping procedure because this quirk's applicability changes. Remove temporary helpers only after confirming the final map works.
7. Deliver a port table, per-controller count, connector type and evidence, generated artifact path if any, config diff, validation performed, known limitations, and rollback steps. A static map artifact does not prove port behavior, sleep, or wake until tested on the machine.

Primary reference: [Dortania USB mapping guide](https://dortania.github.io/OpenCore-Post-Install/usb/) and [manual mapping details](https://dortania.github.io/OpenCore-Post-Install/usb/manual/manual.html). Use their current instructions and the selected mapping tool's upstream docs.
