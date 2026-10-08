---
name: post-install-tuning
description: Use after a successful macOS installation to plan or apply a focused OpenCore tuning change for PlatformInfo, CPU power management, audio, USB, sleep, or Apple services.
---

# Post-install tuning

Read `AGENTS.md`, `docs/opencore-framework/safety-and-evidence.md`, and the relevant domain skill. Confirm the machine has successfully booted and capture a backup of its current EFI before recommending edits.

1. Ask which observed behavior the user wants to improve (for example sleep/wake, CPU idle/frequency behavior, audio input/output, or Apple service sign-in). Collect exact CPU, board/codec/network details, macOS/OpenCore/kext versions, current config, and relevant logs/measurements.
2. Make one evidence-based change at a time on a copy. Compare the current config to the exact OpenCore schema and appropriate upstream docs; do not apply a generic “optimization” bundle.
3. **PlatformInfo/iServices:** select SMBIOS using hardware and OS behavior, not CPU name alone. Preserve existing valid user values unless asked to change them. Do not invent, randomize, expose, reuse, or publish SystemSerialNumber, MLB, SystemUUID, or ROM/MAC. Guide the user to create sensitive values locally with a trusted tool; do not promise Apple service access or account outcomes. Set fields such as `SpoofVendor` only according to the matching OpenCore release and a specific need.
4. **CPU power:** first inspect native power-management behavior and the platform-specific guide. Add CPUFriend/CPUFriendDataProvider or another helper only when measurements show a concrete need and the method is applicable to that CPU/macOS release.
5. **Audio:** identify the codec and exact audio path before suggesting AppleALC `alcid` or DeviceProperties. Present candidate layouts with evidence, test one candidate at a time, and retain the prior setting for rollback.
6. Validate config with the matching `ocvalidate`, inspect the diff, and report what needs a real reboot/functional test. Do not call an untested change optimized or working.

References: [Dortania SMBIOS guide](https://dortania.github.io/OpenCore-Install-Guide/extras/smbios-support.html), [iServices guide](https://dortania.github.io/OpenCore-Post-Install/universal/iservices.html), and the upstream documentation for the relevant power/audio kexts.
