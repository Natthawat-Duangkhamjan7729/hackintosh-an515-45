# OpenCore EFI skill framework

This repository turns the attached OpenCore/Hackintosh knowledge framework into reusable Agent Skills for building EFI folders and for hardware analysis, ACPI, kext dependencies, configuration validation, PlatformInfo, boot diagnosis, and knowledge-base curation.

## Scope

These files provide agent instructions and a research/engineering workflow. They are **not a trained model, compatibility database, or standalone executable EFI generator**. Machine-specific work for one Acer Nitro 5 AN515-45 lives under `staging/AN515-45-Tahoe/`; it applies only to that machine and its recorded inputs.

The framework intentionally treats symptom-to-fix mappings as diagnostic hypotheses. A panic string or generic CPU/GPU family is not enough to safely select quirks or patches. Collect the exact machine details, current EFI, version-matched docs, and relevant logs before proposing changes.

## Repository layout

| Path | Contents |
| --- | --- |
| `AGENTS.md`, `CLAUDE.md` | Always-loaded agent rules |
| `.agents/skills/`, `.claude/skills/` | Agent Skills (kept in sync) |
| `docs/opencore-framework/` | Shared source policy, knowledge-base and evaluation guidance |
| `staging/AN515-45-Tahoe/` | AN515-45 machine project: docs, final EFI, candidates, ACPI, tools — start at its `README.md` |
| `research/mt7921/` | MediaTek MT7921 Wi-Fi driver research and offline build prep |

## Skills

The canonical cross-agent skill files live in `.agents/skills/`. Matching copies live in `.claude/skills/` for Claude Code. When changing a skill, update both copies and check that they match.

| Skill | Use it for |
| --- | --- |
| `build-opencore-efi` | Required ordered workflow for a new or substantially rebuilt EFI; gathers inputs, checks compatibility, constructs a staged EFI, and validates it. |
| `inspect-hardware` | Parse a user-provided inventory and assess component support for a pinned macOS target. |
| `debug-boot-log` | Analyze boot/panic logs as evidence and propose reversible diagnostic steps. |
| `map-usb` | Inventory physical ports and build a per-controller USB map with observed connector data. |
| `post-install-tuning` | Make focused, evidence-based post-install changes for power, audio, PlatformInfo, or services. |
| `update-efi` | Migrate a staged EFI to a pinned OpenCore/kext release and validate the matching schema. |
| `opencore-efi-workflow` | Route a request, gather evidence, plan changes, preserve and validate EFI copies. |
| `opencore-hardware-audit` | Interpret system reports, identify devices, and assess version-specific compatibility. |
| `opencore-acpi-engineering` | Inspect ACPI namespace/tables and reason about SSDTs and patches. |
| `opencore-kext-planning` | Select kexts and derive dependency/load order for a target. |
| `opencore-config-validation` | Edit/review `config.plist` against a specific OpenCore schema and EFI tree. |
| `opencore-platform-identity` | Select and handle PlatformInfo/SMBIOS values with privacy protections. |
| `opencore-boot-diagnostics` | Diagnose boot logs and panics using evidence and reversible hypotheses. |
| `opencore-knowledge-curation` | Maintain a sourced, versioned, privacy-filtered reference corpus and evaluation plan. |
| `debug-mantra` | Use a reproduce/trace/falsify/ledger discipline for software debugging. |
| `post-mortem` | Write an engineering post-mortem only after the cause and fix are validated. |
| `scrutinize` | Review a plan, change, or design end-to-end and look for simpler alternatives. |
| `management-talk` | Reframe engineering updates for technical leadership and a specified channel. |
| `qwen-agent` | Delegate bounded mechanical work to the external 9arm/Qwen service; use only when the user explicitly requests that service. |
| `qwenchance` | Keep long tasks on track and identify when a handoff is useful. |

The six `9arm-skills` skills were installed from [thananon/9arm-skills](https://github.com/thananon/9arm-skills) using the repository's recommended `npx skills add` command. Review their instructions before use. `qwen-agent` is opt-in because it sends delegated task context to an external service.

## Working sequence

1. Establish hardware, macOS target, OpenCore release, current EFI state, and the user's requested outcome. Mark unknowns explicitly.
2. Audit compatibility and collect source-backed findings before constructing or changing files.
3. Make only the smallest justified change on a backup copy. Explain each non-obvious ACPI, kext, quirk, or identity choice.
4. Check file/config consistency and run the `ocvalidate` that matches the exact OpenCore release, if available. Report its limits and any checks not performed.
5. Return a diff, evidence, confidence/unknowns, and recovery steps. Do not claim boot success unless the user reports an actual boot test.

## Primary reference starting points

- [OpenCore Configuration Reference](https://dortania.github.io/docs/latest/Configuration.html) and [Acidanthera OpenCorePkg](https://github.com/acidanthera/OpenCorePkg)
- [Dortania OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/), especially [hardware limitations](https://dortania.github.io/OpenCore-Install-Guide/macos-limits), [ACPI](https://dortania.github.io/Getting-Started-With-ACPI/), [kext collection](https://dortania.github.io/OpenCore-Install-Guide/ktext.html), [SMBIOS selection](https://dortania.github.io/OpenCore-Install-Guide/extras/smbios-support.html), and [troubleshooting](https://dortania.github.io/OpenCore-Install-Guide/troubleshooting/troubleshooting.html)
- [ocvalidate README](https://github.com/acidanthera/OpenCorePkg/blob/master/Utilities/ocvalidate/README.md)

The guides and schemas evolve. Resolve current version information at task time; do not copy values from this README as configuration instructions.
