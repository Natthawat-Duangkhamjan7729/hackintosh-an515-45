---
name: read-context-first
description: This skill should be used at the start of every repository task, before inspecting, editing, generating code, or running project commands, to read AGENTS.md and relevant project documentation and follow their instructions.
---

# Read project context first

Before carrying out repository work:

1. Read the root `AGENTS.md` and `CLAUDE.md` if present. If `CLAUDE.md` imports another file, follow the import and read that file too.
2. Identify the target area and read relevant Markdown documentation, including any more-specific `AGENTS.md`, `CLAUDE.md`, or `*.md` files in its parent and target directories.
3. Inspect the relevant source files and repository structure. Confirm the language, architecture, and applicable commands from files in the repository; do not infer them from folder names alone.
4. Apply the documented constraints to the task. If guidance is missing or conflicts, state the uncertainty and use the least surprising, smallest change that fits the repository.
5. Only after this context review, proceed with edits or project commands. At completion, report the changes and checks actually performed.

This skill is a reusable workflow. The root `CLAUDE.md` and `AGENTS.md` carry the always-on instruction to perform the context review even when the skill is not explicitly invoked.
