---
name: opencore-acpi-engineering
description: Use when analyzing, creating, compiling, or reviewing OpenCore ACPI SSDTs, DSDT patches, ASL/AML, device renames, IRQ fixes, EC, RTC/AWAC, power, brightness, or wake behavior.
---

# ACPI engineering

Read `AGENTS.md` and `docs/opencore-framework/safety-and-evidence.md`. Use `opencore-efi-workflow` for the intake and backup protocol.

1. Request/inspect the machine's original ACPI dump and identify the exact firmware namespace, target OS/OpenCore version, and observed failure/requirement. A generic motherboard series or downloaded AML alone is insufficient evidence.
2. Inspect the relevant ASL methods/devices and existing ACPI Add/Delete/Patch entries. Trace exact paths and method signatures before proposing a rename or patch.
3. Prefer a minimal, position-independent SSDT/patch based on the actual namespace. Explain the target, collision risks, expected behavior, and how to disable/rollback it.
4. Treat common SSDTs (EC/USBX, PLUG, AWAC/RTC, PNLF, GPIO, etc.) as conditional recipes, not a checklist. Do not apply blanket GPRW/UPRW/IRQ renames or assume a single RTC/EC fix fits all firmware.
5. If producing AML, provide/review the corresponding DSL, compile with a suitable `iasl`, report compiler/version and diagnostics, and verify the table is included and enabled correctly in the working config. Do not call uncompiled pseudo-code a tested SSDT.
6. Preserve original tables and EFI. Never flash firmware or write directly to the boot EFI as part of an ACPI experiment.

Use [Dortania Getting Started With ACPI](https://dortania.github.io/Getting-Started-With-ACPI/) and its generation/device-specific instructions, cross-checked against the actual dump and current OpenCore schema.
