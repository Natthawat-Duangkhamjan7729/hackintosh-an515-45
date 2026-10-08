# EFI change and evidence policy

## Minimum intake

Before a machine-specific recommendation, establish as much of this as possible:

- exact CPU and platform generation; laptop/desktop; motherboard or OEM model and BIOS version;
- iGPU and dGPU PCI vendor/device IDs, display wiring/outputs, and target macOS release;
- storage, Ethernet, Wi-Fi/Bluetooth, audio, USB/controller details;
- OpenCore version and matching EFI tree/config; relevant ACPI dump, logs, and what changed immediately before the issue;
- desired result and constraints (dual boot, FileVault, sleep, external displays, etc.).

A product name alone may not identify the silicon, subsystem ID, mux/wiring, or firmware behavior. Separate observed facts from inference and state confidence.

## Change handling

- Preserve the supplied EFI byte-for-byte as an untouched backup; create a separate working copy and show a diff.
- Never overwrite a boot partition or alter BIOS/UEFI settings as part of a speculative fix. Provide instructions only for the requested scope and clearly identify user-operated steps.
- Prefer one evidence-backed change at a time. For risky or hard-to-reverse changes, describe a rollback path first.
- Keep `EFI/OC` files and plist entries in sync. Do not leave entries for absent files or silently omit files referenced by the config.
- Explain what a validator checks and does not check. A clean validator result does not prove compatibility, correct ACPI behavior, or a successful boot.

## Version and privacy

- Pin the OpenCore schema, macOS target, and each relevant kext/driver version before proposing version-sensitive values.
- Use only the schema/docs for that release. Do not combine a current Sample.plist with old quirk advice without verification.
- Do not reproduce real serials, MLBs, UUIDs, ROMs, MAC addresses, credentials, or private logs in output, examples, or a public knowledge corpus. Use explicit placeholders when illustrating fields.
- Never promise iServices activation or freedom from account issues based on an SMBIOS recipe.

## Reporting

For each proposed change, record: observed evidence, source URL/version, reasoning, exact files/keys affected, expected effect, uncertainty, validation performed, and rollback step. Distinguish `not checked`, `schema validated`, and `boot tested`.
