@AGENTS.md

# Claude Code project rules

- Read the imported `AGENTS.md` and `README.md` at the beginning of repository work. Read the relevant skill and framework documents before changing EFI guidance or configuration.
- For any EFI build or full rebuild, follow `.claude/skills/build-opencore-efi/SKILL.md` in order. For focused domain work, select and follow the applicable `opencore-*` skill. Canonical Codex/shared copies are in `.agents/skills/`; keep both trees synchronized when editing a skill.
- Skill discovery is model-guided. These instructions in `CLAUDE.md` and `AGENTS.md` are the always-loaded workflow; do not rely on a skill being invoked as a tool gate.
- Verify version-sensitive technical claims against primary OpenCore, Dortania, or upstream project documentation and identify the versions checked.
- Protect hardware reports and SMBIOS identifiers. Redact serials, MLB, UUIDs, ROM/MAC values in summaries and examples.
- Never present a generated config or EFI as boot-ready without matching hardware inputs and release-matched validation. Preserve the original EFI and provide a focused diff.
- The third-party `qwen-agent` skill uses the external `claude-9arm`/Qwen service. Do not invoke it or send project files/logs to that service unless the user explicitly requests it.
