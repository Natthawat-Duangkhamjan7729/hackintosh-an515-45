---
name: opencore-config-validation
description: Use to create, review, edit, or validate OpenCore config.plist, schema keys, quirks, drivers, DeviceProperties, NVRAM, Booter, Kernel, UEFI, or EFI file/config consistency.
---

# Configuration and schema validation

Read `AGENTS.md` and `docs/opencore-framework/safety-and-evidence.md`. Establish the exact OpenCore package version and target hardware/macOS before interpreting any setting.

1. Compare the existing config to the `Sample.plist` and Configuration reference shipped with the same OpenCore release. Do not mix schemas or rely on memory for quirk names, types, allowed values, or deprecations.
2. Parse plist data without losing types (Boolean, integer, string, data, array, dictionary). Preserve unrelated values and comments where practical; produce a focused diff.
3. Derive each quirk/property from matching hardware and firmware evidence. Explain relevant Booter/Kernel/UEFI choices; never recommend toggling memory-map, write-protection, CFG-Lock, or Resize BAR settings as a universal panic fix.
4. Cross-check every ACPI, kext, driver, tool, and path entry against files actually present in the working EFI. Check duplicate entries and correct `Kernel -> Add` dependency order.
5. Run `ocvalidate` from the exact OpenCore release if available; first confirm its supported version. Report all output. A pass is only a basic schema check and does not prove semantic correctness or bootability.
6. Save edits only to a copy. Before completion, inspect the diff and give restore instructions. Never write to an EFI System Partition unless the user explicitly requested installation.

References: [OpenCore Configuration Reference](https://dortania.github.io/docs/latest/Configuration.html), [Acidanthera OpenCorePkg](https://github.com/acidanthera/OpenCorePkg), and [ocvalidate README](https://github.com/acidanthera/OpenCorePkg/blob/master/Utilities/ocvalidate/README.md).
