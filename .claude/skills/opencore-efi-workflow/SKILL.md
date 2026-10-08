---
name: opencore-efi-workflow
description: Use for any OpenCore EFI build, review, repair, migration, or Hackintosh boot issue. Orchestrates evidence gathering, specialized skills, reversible edits, and release-matched validation.
---

# OpenCore EFI workflow

1. Read the repository `AGENTS.md`, `README.md`, and `docs/opencore-framework/safety-and-evidence.md` before working. Route to the relevant `opencore-*` domain skill(s); read their instructions.
2. Establish the exact goal, CPU/platform, board/OEM, GPU IDs and wiring, target macOS, OpenCore version, present EFI state, and relevant logs. Inspect the repository and user-provided files. Separate facts, inferences, and unknowns.
3. Verify every version-sensitive recommendation against the matching OpenCore docs, Dortania page, or upstream project release notes. Use current sources where browsing is available; cite URLs and versions in findings.
4. Audit compatibility before editing. If critical machine/version details are missing, report what can be concluded and ask only for the missing information that changes the recommendation.
5. Preserve the original EFI and make a separate working copy. Make the smallest justified change, explain each non-obvious setting, and provide a focused diff plus rollback steps.
6. Keep EFI files synchronized with `config.plist`. Use `ocvalidate` matching the exact OpenCore release when available; validation is not proof of a successful boot. Never claim boot success without an actual user-reported test on the target system.
7. Redact SystemSerialNumber, MLB, UUID, ROM/MAC, account data, and private paths/log details from output.

## Route by domain

- Hardware inventory and compatibility: `opencore-hardware-audit`.
- DSDT/SSDT/ASL/AML and ACPI patches: `opencore-acpi-engineering`.
- Kext selection, versions, dependencies, and order: `opencore-kext-planning`.
- `config.plist`, quirks, schema, and validator: `opencore-config-validation`.
- SMBIOS and PlatformInfo identity: `opencore-platform-identity`.
- Boot logs, kernel panics, and recovery: `opencore-boot-diagnostics`.
- Reference corpus or future evaluation design: `opencore-knowledge-curation`.

## Result format

Return: summary; hardware/version assumptions; evidence and sources; exact file/key changes (or proposed changes); validation and its limits; unresolved risks/unknowns; rollback steps. If no edit is justified, explain why and give the next evidence needed.
