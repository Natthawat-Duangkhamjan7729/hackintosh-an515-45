# Knowledge base and evaluation policy

## Source hierarchy

For a version-sensitive claim, consult sources in this order:

1. The matching OpenCore release's `Configuration.pdf`, release notes, and bundled `Sample.plist` from [Acidanthera/OpenCorePkg](https://github.com/acidanthera/OpenCorePkg).
2. The relevant hardware-generation, ACPI, kext, or troubleshooting page in [Dortania's guides](https://dortania.github.io/OpenCore-Install-Guide/).
3. The exact upstream kext/driver project documentation and release notes.
4. Hardware vendor documentation and direct evidence from the user's system report, ACPI dump, EFI, or logs.
5. Community posts and public EFI repositories only as leads to verify, never as ground truth or drop-in templates.

Record the source URL, access date, applicable OpenCore/macOS/kext version, hardware scope, and the claim supported. If sources disagree or are stale, preserve the disagreement and mark the decision unresolved rather than blending incompatible advice.

## Corpus curation

- Prefer original documentation and minimal, auditable examples over scraped collections of entire EFI folders.
- Keep source license/redistribution terms with each dataset record. Do not mirror material whose reuse rights are unclear.
- Remove or replace personal identifiers before storing examples: SystemSerialNumber, MLB, SystemUUID, ROM, MAC addresses, usernames, disk UUIDs, paths, and logs containing account/device data.
- Label every configuration example with exact hardware, laptop/desktop wiring where known, macOS version, OpenCore version, kext versions, and whether it actually booted. Unknown fields stay unknown.
- Do not treat a publicly posted EFI as validated merely because it exists online. Reject examples with mismatched schema, duplicate/conflicting kexts, missing files, or no provenance.
- Keep versioned snapshots; never silently update a fact whose old applicability matters.

## Evaluation plan (design only)

Build a small, reviewed case set before claiming the workflow is reliable. Cases should cover supported and unsupported hardware, ambiguous PCI IDs, missing input, ACPI conflicts, kext dependencies, schema-version mismatch, known boot-log stages, and sensitive identifiers. Include both positive cases and cases where the right answer is to ask for more data or refuse a speculative patch.

Score at least:

- hardware/OS compatibility accuracy and correct expression of uncertainty;
- schema and file/config consistency using the matching OpenCore validator;
- dependency order and version applicability;
- whether proposed ACPI edits have evidence and a reversible explanation;
- privacy leakage (must be zero for secrets/identifiers in published outputs);
- diagnosis quality: grounded hypotheses, no unsupported one-signature/one-fix claims;
- reproducibility: cited source/version, exact diff, and checks reported honestly.

`ocvalidate` is a necessary schema check when applicable, not an end-to-end boot test. Track actual boot results separately and only from the relevant hardware/OS combination. This repository contains no model training pipeline or evaluation dataset yet.
