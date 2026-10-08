---
name: update-efi
description: Use when the user explicitly requests updating OpenCore, kexts, drivers, or validating an existing EFI against a newer release; also use for a version-pinned config migration plan.
---

# OpenCore EFI update workflow

Read `AGENTS.md`, `docs/opencore-framework/safety-and-evidence.md`, and the build/config-validation skills. Updating an EFI is a coordinated migration, not a blind replacement of every component with its latest release.

1. Establish current OpenCore version, macOS target, hardware, current EFI tree/config, requested target version (or ask whether “latest” means latest stable release), known working boot state, and required features. Inspect release notes and the version-specific `Differences.pdf`/configuration docs.
2. Preserve the original EFI and make a separate staging copy. Do not mount or modify the boot ESP, change firmware, or discard the working fallback unless explicitly requested.
3. Pin a compatible target OpenCore release and update its coordinated core files from the official upstream release (including `BOOTx64.efi`, `OpenCore.efi`, and `OpenRuntime.efi` as applicable). Verify provenance and checksums/signatures when the source provides them. Do not mix files from different OpenCore builds.
4. Review config changes against that release's `Sample.plist`, Configuration reference, and Differences document. Migrate required/deprecated keys deliberately; do not overwrite the user's config with the sample and do not auto-toggle quirks to silence validation.
5. Update kexts and auxiliary drivers only when individually compatible with the hardware, macOS target, and chosen OpenCore version. Review each upstream release note and dependency. Keep a manifest of old/new versions and sources; do not fetch from unofficial mirrors.
6. Recheck EFI file/config consistency and dependency order. Run `ocvalidate` shipped with the target OpenCore release; fix understood errors and rerun. If validator/tools/required release artifacts are missing, leave the staging copy clearly unvalidated instead of substituting a different version.
7. Report staged path, version changes, source URLs, config/file diff, validator output, any manual test needed, rollback path, and unverified behavior. Do not claim boot-tested until the user confirms testing on the target hardware.

Primary references: [Dortania update guide](https://dortania.github.io/OpenCore-Post-Install/universal/update), [Acidanthera OpenCorePkg releases](https://github.com/acidanthera/OpenCorePkg/releases), and the target release's `Docs/Configuration.pdf`, `Docs/Sample.plist`, `Docs/Differences.pdf`, and `Utilities/ocvalidate`.
