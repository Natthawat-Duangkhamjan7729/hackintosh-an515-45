---
name: opencore-platform-identity
description: Use to reason about SMBIOS model selection and OpenCore PlatformInfo fields, including SystemProductName, serial, MLB, UUID, ROM, and iServices-related privacy.
---

# PlatformInfo and identity

Read `AGENTS.md`, `docs/opencore-framework/safety-and-evidence.md`, and the workflow skill. Require exact CPU class (desktop/mobile/server), GPU setup, target macOS, and relevant device behavior before comparing SMBIOS choices.

1. Compare plausible model profiles using current Dortania guidance and hardware behavior (CPU/power management, GPU/display policy, USB, sleep, OS compatibility); do not use a fixed CPU-to-SMBIOS lookup table as the sole criterion.
2. Explain tradeoffs and alternatives. Mark the result as a recommendation, not an Apple-supported configuration or a guarantee of power management/iServices.
3. Do not copy real Apple identifiers or reuse serial/MLB/UUID/ROM from public EFI examples. In generated config drafts use obvious placeholders or leave identity fields blank until the user generates unique values locally with a trusted tool.
4. Do not expose identifiers in chat, logs, examples, commits, or the curated corpus. Redact SystemSerialNumber, MLB, SystemUUID, ROM/MAC. Do not claim that an algorithmically valid serial is unassigned or safe for Apple services.
5. Keep `PlatformInfo -> Generic` internally consistent and version-check all related keys against the matching OpenCore schema. Explain how the user can fill sensitive values locally without asking them to paste secrets into chat.

See [Dortania SMBIOS selection](https://dortania.github.io/OpenCore-Install-Guide/extras/smbios-support.html) and the matching OpenCore Configuration reference.
