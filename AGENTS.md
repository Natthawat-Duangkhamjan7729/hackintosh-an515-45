# AGENTS.md — OpenCore EFI Knowledge Framework

This repository contains reusable, cross-agent workflows and knowledge references for analyzing and maintaining OpenCore EFI configurations. It does not contain a verified machine profile or a ready-to-boot EFI yet.

## Before starting work

1. Read this file and `README.md`, then read the relevant `docs/` or skill Markdown before changing them or any EFI files.
2. Inspect the supplied hardware report, existing EFI tree, `config.plist`, and logs relevant to the task. Treat reports and EFI contents as sensitive; redact serials, UUIDs, MAC addresses, and other identifiers from responses and examples.
3. Verify claims that depend on hardware, macOS, kext, or OpenCore versions against the matching primary documentation. Never assume that a sample config, SMBIOS mapping, ACPI table, quirk, or panic signature applies universally.
4. For any request to create or substantially rebuild a machine-specific EFI, follow `.agents/skills/build-opencore-efi/SKILL.md` in order and use its domain skills. If key machine inputs are missing, do not create a boot-ready EFI.
5. Preserve the original EFI and config. Work on a separate copy, show a focused diff, and do not install to an EFI System Partition or alter firmware settings unless the user explicitly asks.
6. Validate with tools matching the exact OpenCore release when available. State what was validated and what remains unverified; schema validation does not prove that a configuration will boot.
7. The third-party `qwen-agent` skill routes work through the external `claude-9arm`/Qwen service. Do not invoke it or transmit project files/logs there unless the user explicitly requests that service.

## Project map

- `.agents/skills/` — canonical shared Agent Skills for Codex and other compatible agents.
- `.claude/skills/` — Claude Code copies of those skills; keep names and contents synchronized with `.agents/skills/`.
- Third-party skills from `thananon/9arm-skills` are installed into both skill trees; review their instructions before use.
- `.agents/skills/build-opencore-efi/SKILL.md` — required workflow for building a machine-specific EFI.
- `docs/opencore-framework/` — shared source policy, knowledge-base and evaluation guidance.
- `machines/AN515-45/` — Acer Nitro 5 AN515-45 machine project; index in its `README.md`. Documents in `docs/`, working sanitized EFI in `final-efi/`, experimental builds in `candidates/`, scripts in `tools/`.
- `research/mt7921/` — MT7921 Wi-Fi driver research.
- `research/macos-cross-gpu/`, `research/nullmoth-driver-status/` — dGPU/iGPU display research (Thai).
- `README.md` — entry point, skill routing, and scope.

## Project facts

- **Purpose:** build a cautious, evidence-based assistant workflow for OpenCore EFI analysis and configuration.
- **Machine profile:** not supplied. Do not generate a machine-specific EFI or assume a CPU, motherboard, GPU, macOS target, or OpenCore release.
- **Build/test commands:** none defined; this repository currently contains Markdown guidance and skills only.
