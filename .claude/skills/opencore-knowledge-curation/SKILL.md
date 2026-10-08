---
name: opencore-knowledge-curation
description: Use to build, maintain, source, version, anonymize, or evaluate a knowledge base for AI-assisted OpenCore EFI engineering; includes dataset provenance and evaluation design.
---

# Knowledge curation

Read `AGENTS.md`, `README.md`, and `docs/opencore-framework/knowledge-base-and-evaluation.md` before adding material.

1. Prefer primary, versioned sources: Acidanthera OpenCore docs/release artifacts; relevant Dortania guides; upstream kext/driver documentation; then vendor manuals and direct system evidence. Community posts/public EFI files are leads, not ground truth.
2. Store each claim with source URL, access date, hardware scope, macOS/OpenCore/kext version, evidence status, and license/redistribution information. Keep stale claims versioned and visibly stale; do not silently rewrite applicability.
3. Before saving examples, redact serial, MLB, UUID, ROM/MAC, credentials, personal paths, usernames, and log data that can identify a person or machine.
4. Label EFI examples with exact known hardware/software versions and actual boot-test evidence. Keep unknowns as unknown; never infer a general rule from one successful EFI.
5. Reject unverified “fix tables” and configs lacking provenance, matching schema, complete referenced files, or conflict checks. Convert anecdotes into hypotheses with limits.
6. For an evaluation plan, include ambiguous/missing-input and unsupported-hardware cases where the correct behavior is uncertainty or a request for evidence. Track compatibility, schema/file consistency, dependency correctness, source-grounding, privacy leakage (target zero), and honest validation reporting.
7. Do not claim that a training pipeline, knowledge graph, dataset, or reliability benchmark exists unless it has actually been built and measured.

See [framework source and evaluation policy](../../../docs/opencore-framework/knowledge-base-and-evaluation.md).
