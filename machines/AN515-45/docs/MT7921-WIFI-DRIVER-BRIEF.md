# Brief: macOS Wi-Fi driver for MediaTek MT7921 (for another AI / developer)

> สรุปภาษาไทย: เอกสารนี้คือโจทย์สำหรับให้ AI หรือนักพัฒนาอีกคนลองเขียนไดรเวอร์ Wi-Fi ของ MediaTek MT7921 สำหรับ macOS บนเครื่อง Acer Nitro 5 AN515-45 ที่ติดตั้ง Hackintosh ไว้แล้ว ยังไม่มีไดรเวอร์นี้อยู่ในโลก (ณ 2026-10-09) งานนี้เป็นงานวิจัยระดับ kernel ใช้เวลานาน และมีโอกาสไม่สำเร็จสูง ให้ทำทีละ milestone และทดสอบจาก USB เท่านั้น

## 1. Goal

Create a macOS kernel extension (kext) that drives the **MediaTek MT7921 PCIe Wi-Fi 6** card in this laptop, so macOS can scan, associate (WPA2-PSK first) and pass IP traffic.

- **Primary target (realistic):** an itlwm-style driver that exposes the card as a network interface. Connection is controlled by a companion user-space app, similar to HeliPort.
- **Stretch target (hard):** native integration with Apple's private IO80211Family, so the macOS Wi-Fi menu works, similar to AirportItlwm.
- **Non-goals for now:** Bluetooth (separate USB device; see §9), AirDrop/Continuity, monitor mode, 6 GHz.

As of 2026-10-09 no released macOS Wi-Fi driver for MT7921 is known. The closest work is **laobamac/SimpleMtkWlan** (GPL-2.0, no releases, last push 2026-06-27): an experimental MT792x PCIe kext targeting 14c3:7961 with OpenBSD net80211; bring-up stage (attach, firmware, DMA, scan, association debugging). Evaluate continuing from it before starting from scratch. Community forums (EliteMacx86, AMD-OSX) report MediaTek Wi-Fi as unsupported. Treat this as a research project: expect months of work and a real chance of not reaching a usable driver.

## 2. Hardware facts (verified on this machine)

| Item | Value |
| --- | --- |
| Laptop | Acer Nitro 5 AN515-45-R375 |
| CPU / platform | AMD Ryzen 7 5800H (Cezanne), FP6, AMD FCH |
| Wi-Fi | MediaTek **MT7921**, PCI **14C3:7961**, subsystem **11AD:3802** (Lite-On module), class 0x028000 |
| Wi-Fi PCI path | `PciRoot(0x0)/Pci(0x2,0x2)/Pci(0x0,0x0)` (behind AMD GPP bridge 1022:1634) |
| Bluetooth (same module) | USB **04CA:3802**, internal port on XHC0 |
| Ethernet (works) | Killer E2600 10EC:2600 via RealtekRTL8111 3.0.0 |
| Other NVMe/GPU | Apacer NVMe (macOS + Windows); RTX 3060 enabled but unused by macOS |

## 3. Software environment

- macOS **Sequoia 15.8.1 (24H32)**, x86_64. Check the exact Darwin version with `uname -r` on the machine.
- Boot loader: **OpenCore 1.0.8**. Kexts are injected by OpenCore from `EFI/OC/Kexts` + `config.plist` Kernel→Add. They do **not** need Apple signing.
- Already injected: Lilu 1.7.2, VirtualSMC 1.3.8, NootedRed 0.8.10, AppleALC 1.9.8, VoodooI2C/PS2, NVMeFix, ForgedInvariant, RealtekRTL8111, USBMap. Lilu is available if patching is needed.
- `SecureBootModel=Disabled`, `csr-active-config=00000000` (SIP on). Boot-args currently `-v keepsyms=1 debug=0x100`.
- The project repo (private) holds the EFI build script `machines/AN515-45/tools/build_candidate.py`, the progress log and the update workflow `machines/AN515-45/docs/EFI-UPDATE-TH.md`.

## 4. Reference material

Verify every path and version against the current upstream tree before relying on it.

- **Linux mt76 driver** (GPL/ISC dual-licensed parts; check headers): `drivers/net/wireless/mediatek/mt76/`
  - `mt7921/` — `pci.c` (probe, PCIe), `init.c`, `main.c`, `mac.c`, `mcu.c`, `dma.c`, `regs.h`
  - shared: `mt76_connac_mcu.c`, `mt76_connac_mac.c`, `mt792x_*.c`, `dma.c`, `mmio.c`, `mcu.c`
- **Firmware** (linux-firmware, `mediatek/`): `WIFI_MT7961_patch_mcu_1_2_hdr.bin`, `WIFI_RAM_CODE_MT7961_1.bin`. Check the redistribution licence before bundling.
- **itlwm / AirportItlwm** (OpenIntelWireless): the reference architecture. It ports OpenBSD's net80211 into a kext, uses HeliPort for control, and AirportItlwm adds IO80211Family glue.
- **FreeBSD** mt76 via LinuxKPI (recent): an alternative porting reference.
- Apple **IOKit / IONetworkingFamily** docs (`IOEthernetController`, `IOPCIDevice`, `IOInterruptEventSource`, `IOBufferMemoryDescriptor`/DMA).

## 5. Suggested architecture

1. `IOPCIDevice` match on `14C3:7961`: map BAR(s), enable bus mastering and MSI, set up interrupts.
2. A WFDMA ring layer for TX/RX and MCU command/event rings, ported from mt76 `dma.c` and the mt7921 regs.
3. MCU layer: firmware download (patch, then RAM code), then a command/event protocol (`mt76_connac_mcu`).
4. 802.11 layer: reuse a ported net80211 (as itlwm does) **or** let firmware offload where MT7921 supports it (connac2 firmware handles much of the MLME; check which commands the Linux driver uses for scan/connect).
5. Network interface: `IOEthernetController` + `IOEthernetInterface` (itlwm-style) for the primary target.
6. A user-space control path (IOUserClient or `sysctl`) for SSID/password, or reuse the HeliPort protocol if compatible.

## 6. Milestones and acceptance criteria

| # | Milestone | Done when |
| --- | --- | --- |
| M0 | Skeleton kext loads | It matches 14C3:7961, logs BAR/IRQ info, and unloads/reboots cleanly. **No panic in 10 boots.** |
| M1 | Chip alive | Reads chip ID/revision registers matching the Linux driver's expectations, and power-on handshake (FW ownership) succeeds. |
| M2 | Firmware running | Patch + RAM code download succeeds; firmware version string reported via MCU event. |
| M3 | Scan | Lists nearby SSIDs/BSSIDs with channel and RSSI (log or user client). |
| M4 | Associate | Connects to a WPA2-PSK 2.4/5 GHz AP and completes the 4-way handshake. |
| M5 | Traffic | Gets DHCP, pings the gateway, sustains a 5-minute download without panic; suspend and resume are optional. |
| M6 (stretch) | Native menu | IO80211Family integration; macOS Wi-Fi menu lists and joins networks. |

Report measurable evidence for each milestone (logs, `ifconfig`, ping output). Don't claim a milestone without it.

## 7. Development and test protocol (mandatory)

- **Build on macOS** with Xcode + MacKernelSDK (as acidanthera projects do), target x86_64. The Lilu SDK is only needed if you patch Apple code.
- **Never install the test kext to the Apacer EFI partition.** Test only via the **USB OpenCore** (`E:\EFI\OC` when seen from Windows):
  1. build a new candidate with `tools/build_candidate.py` (add the kext entry after Lilu);
  2. copy the kext + config to the USB;
  3. boot with F12 → USB.
  The Apacer EFI (known-good) stays as the fallback.
- **Kext load without reboot** (`kextload`) is not possible with SIP on; use OpenCore injection plus reboot. Keep `-v keepsyms=1 debug=0x100` so panics stay on screen.
- **Collect logs:** `log show --last boot --predicate 'sender == "<KextName>"'`, `/Library/Logs/DiagnosticReports/*.panic`, and photos of panic screens.
- Change one thing per test boot. Keep an experiment ledger (change → result → conclusion).
- Respect licences: keep upstream copyright/SPDX headers when porting; prefer GPL-compatible distribution of the kext if Linux code is ported.

## 8. Risks

- Kernel panics and possible filesystem damage on hard crashes. macOS lives on the same NVMe as Windows, so keep backups (a system image and an ESP backup exist on D:).
- IO80211Family private API changes between macOS releases (stretch goal only).
- Firmware/MCU protocol details may differ by firmware version; pin the firmware files used.
- Effort: the reference project (itlwm) took experienced developers years.

## 9. Related but separate: Bluetooth

The module's Bluetooth (USB 04CA:3802) may already be served by **laobamac/SimpleMtkBtFw 1.0.0** (experimental, Lilu-based firmware loader; its Info.plist lists 04CA:3802). It has not been tested on this machine. It is independent of this Wi-Fi work.

## 10. Practical alternative (for context)

Swapping the M.2 card for a supported one (Broadcom BCM94360NG, or Intel AX200/AX210 with AirportItlwm) gives working Wi-Fi in a day. This brief exists because the owner wants to explore building an MT7921 driver anyway.
