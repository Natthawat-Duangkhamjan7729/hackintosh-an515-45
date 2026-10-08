# Firmware evidence findings — 2026-10-09

Source: diagnostic USB boot on the AN515-45 (OpenCore 1.0.8 DEBUG, firmware-only config). Copied from E: unchanged:
`opencore-2026-10-09-023922.txt` and `SysReport/`. SysReport contains SMBIOS identity data and `ACPI/MSDM-1.aml` (possible Windows key) — keep local, do not publish.

## Observed facts

| Item | Evidence | Value |
| --- | --- | --- |
| Boot path | log `BS: Booter path`, `OC: Booter path` | Firmware loaded `\EFI\BOOT\BOOTx64.efi` → `OpenCore.efi` from USB |
| UEFI Secure Boot | `OCSB: Secure boot is disabled` | Disabled at time of test |
| CPU | `OCCPU`, `CPU/CPUInfo.txt` | Ryzen 7 5800H, signature A50F00, 1 package / 8 cores / 16 threads; TSC ≈3194 MHz, FSB ≈99.8 MHz |
| Firmware GOP | `GOP/GOPInfo.txt`, `OCC:` | AMD GOP driver 2.20.0.17.10; 1920x1080 native mode 0, 9 modes; FB at `0xFC10000000` (above 4 GiB) |
| Firmware drivers | `Drivers/DriverImageNames.txt` | AMD GOP and NVIDIA GPU UEFI drivers both present; I2C host, PS/2, USB xHCI, Realtek USB UNDI |
| UEFI memory map | `MMDD: Dumping the original memory map` | 51 descriptors × 0x30 = 0x990 bytes (< 4096) |
| Memory Attributes Table | `OCMM: MemoryAttributesTable` | Present, 38 entries: 19 RT Code RUN+XP, 18 RT Code RUN+RO, 1 RT Data RUN+XP. No RWX entry |
| Lower 4 GiB | `OCABC: Firmware has ... free pages` | 793396 free pages (~3.0 GiB) below 4 GiB; largest Available block 0x09F0F000–0xB46FDFFF (2727 MB) |
| Reproducibility | three MmapDump runs | Original memory maps byte-identical across all three runs |
| PCI | `PCI/PCIInfo.txt` | iGPU 1002:1638 at PciRoot(0x0)/Pci(0x8,0x1)/Pci(0x0,0x0); xHCI at …/Pci(0x8,0x1)/Pci(0x0,0x3) and /Pci(0x0,0x4); dGPU 10DE:2520 at PciRoot(0x0)/Pci(0x1,0x1)/Pci(0x0,0x0); 2× xHCI 1022:1639; NVMe 1987:5013; Ethernet 10EC:2600; Wi-Fi 14C3:7961; 2× SATA AHCI 1022:7901 |

## Interpretation for the future macOS config (OpenCore 1.0.8)

- **Firmware supports MAT.** Configuration.pdf 1.0.8 (§Booter Quirks, RebuildAppleMemoryMap Note 2): it "replaces EnableWriteUnprotector on firmware supporting Memory Attribute Tables". Candidate: `EnableWriteUnprotector=false`, `RebuildAppleMemoryMap=true`, `SyncRuntimePermissions=true`. The doc says the need is determined by early boot failures, so this is the starting candidate, not a proven requirement.
- **Memory map size is below 4 KB** before OpenCore drivers load. The size limit is not the reason for RebuildAppleMemoryMap here; its value is in applying MAT permissions.
- **Ample free low memory and stable layout:** there is no evidence that `ProvideCustomSlide`, `AvoidRuntimeDefrag` or `SetupVirtualMap` need non-default changes. Decide those from the first macOS boot log.
- **GOP framebuffer above 4 GiB:** this suggests Above 4G decoding is active. That is consistent with the current BIOS state, but BIOS menu visibility was not inventoried. Resizable BAR state cannot be read from this report. Keep `ResizeAppleGpuBars=-1` (the iGPU is the only macOS display path).
- **Native GOP works at 1920x1080**, so no console/GOP workaround is indicated.
- **CPU topology confirms 8 physical cores**, matching the staged AMD Vanilla core-count replacement (`components/AMD-core-patch-diff.json`).
- `OpenRuntime is missing` and `Failed to get FSBFrequency ... Apple Platform Info` are expected for this firmware-only diagnostic config, not faults.

Unverified: macOS boot, runtime behaviour after OpenRuntime loads, and BIOS options (UMA size, Above 4G and ReBAR toggles). Schema validation and these logs do not prove a macOS boot.
