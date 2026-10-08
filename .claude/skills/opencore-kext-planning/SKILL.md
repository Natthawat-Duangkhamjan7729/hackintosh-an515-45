---
name: opencore-kext-planning
description: Use to select OpenCore kernel extensions for specific hardware and macOS versions, check compatibility, resolve dependencies, and build a correct Kernel Add order.
---

# Kext planning

Read `AGENTS.md` and the OpenCore workflow skill. Establish exact hardware, macOS target, OpenCore release, and current kext bundle/version before making a plan.

1. Map each supported device to the relevant upstream kext and check its own release notes, supported OS range, architecture, known conflicts, and maintenance status. Do not infer support solely from another EFI or a similar PCI ID.
2. Build a dependency graph from current kext documentation and bundle metadata (including `OSBundleLibraries` and plugins). Put dependencies before dependents; Lilu must precede its Lilu plugins such as WhateverGreen/AppleALC. Account for plugin kexts that must be listed separately.
3. Check `MinKernel`/`MaxKernel`, duplicate bundles/plugins, disabled entries, executable/plist paths, architecture, and consistency between `EFI/OC/Kexts` and `Kernel -> Add`.
4. Treat Intel Wi-Fi/Bluetooth suite choice, VoodooI2C satellites, hybrid CPU scheduling, and AMD kernel patches as version- and hardware-specific. Do not include both conflicting alternatives without a verified reason.
5. Report a table of kext, purpose/device, source/version, dependencies/order, OS bounds, and uncertainty. Do not download, replace, or inject binaries without user authorization and a verified upstream source.

Primary starting points: [Dortania kext collection](https://dortania.github.io/OpenCore-Install-Guide/ktext.html), [official OpenCore configuration reference](https://dortania.github.io/docs/latest/Configuration.html), and the upstream repository for each kext.
