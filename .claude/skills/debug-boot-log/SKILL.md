---
name: debug-boot-log
description: Use when an OpenCore system fails to boot, hangs, shows a kernel panic, loses display, or has sleep/wake trouble and logs need evidence-based diagnosis.
---

# Boot log diagnosis

Read `AGENTS.md`, `docs/opencore-framework/safety-and-evidence.md`, and the relevant EFI workflow/diagnostic skills before making changes.

1. Inspect the log or panic supplied by the user. Ask for the complete relevant log, the earliest failure context, hardware inventory, macOS/OpenCore/kext versions, current EFI/config, and the last change if needed. Redact serials, UUIDs, MAC/ROM, account data, and private paths.
2. Identify the boot stage (firmware/UEFI, OpenCore, installer, kernel, graphics handoff, post-install) and locate the earliest meaningful error. Explain where evidence ends; the final log line may be a symptom rather than the cause.
3. Treat strings such as `EXITBS:START`, RTC warnings, MSR 0xE2, AppleFSCompression, or a black screen as clues, not one-to-one diagnoses. Check the version-matched OpenCore/Dortania docs and compare against this machine's config and topology.
4. Return ranked hypotheses with supporting evidence, a reversible experiment for each, expected confirmation/disconfirmation, and rollback. Prefer one targeted change per trial. Do not flip multiple memory-map/CFG/RTC/framebuffer/USB settings based only on a signature.
5. Do not edit the EFI automatically just because the log suggests a fix. Apply a change only when the user has asked for the repair and a separate working copy can be preserved. Never overwrite the only bootable EFI or write to the ESP without explicit request.
6. Run release-matched `ocvalidate` for any changed config when available, but distinguish schema validation from a real boot test. If the evidence is insufficient, request the smallest missing artifact instead of claiming a fix.

Use [Dortania troubleshooting](https://dortania.github.io/OpenCore-Install-Guide/troubleshooting/troubleshooting.html), the matching generation-specific guide, and [OpenCore's matching Configuration reference](https://dortania.github.io/docs/latest/Configuration.html).
