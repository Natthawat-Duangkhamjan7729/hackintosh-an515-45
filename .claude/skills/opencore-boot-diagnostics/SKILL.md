---
name: opencore-boot-diagnostics
description: Use to diagnose OpenCore picker failures, installer hangs, kernel panics, sleep/wake problems, black screens, and boot logs without applying speculative one-line fixes.
---

# Boot diagnosis

Read `AGENTS.md` and `docs/opencore-framework/safety-and-evidence.md`. Use the workflow skill to identify hardware, target versions, current EFI, and preserve a backup.

1. Ask for the complete relevant OpenCore debug log or panic text, exact point of failure, macOS/OpenCore/kext versions, hardware report, current EFI/config, and the last change. Redact private identifiers.
2. Locate the earliest meaningful failure and distinguish firmware/UEFI, OpenCore picker, installer, kernel, graphics handoff, and post-install failures. A trailing line may be a consequence, not the cause.
3. Treat signatures such as `EXITBS:START`, RTC warnings, MSR 0xE2, AppleFSCompression, or a black screen as clues only. Cross-reference current troubleshooting docs and the matching machine topology. Do not map each string to an automatic quirk/SSDT toggle.
4. Form ranked, testable hypotheses. For each, cite evidence, identify one reversible change, predict a confirming/disconfirming result, and give rollback steps. Change one relevant variable at a time.
5. Do not claim diagnosis from incomplete logs. If evidence is insufficient, return the smallest useful request for additional data and explain why.
6. Do not overwrite the only bootable EFI, install to the ESP, alter firmware, or perform a batch of speculative changes. Validate each proposed config with matching `ocvalidate` but state that only a real boot test establishes boot behavior.

Start with [Dortania troubleshooting](https://dortania.github.io/OpenCore-Install-Guide/troubleshooting/troubleshooting.html) and match the advice to the specific hardware and software release.
