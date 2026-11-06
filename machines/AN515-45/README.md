# Acer Nitro 5 AN515-45-R375 — Hackintosh

## สถานะล่าสุด (2026-11-06)

- **macOS Tahoe 26.7.1 ติดตั้งอยู่บน Apacer** (APFS 249.5 GB) **บูตจาก USB KINGSTON** — ESP ของ Apacer ไม่มี OpenCore ตั้งแต่ 2026-10-27
- config บน USB = `candidate-tahoe-nullmoth-pwrl2` (private-build, `cmp` ตรงกัน ตรวจ 2026-11-06)
- **จอในตัวขับด้วย RTX 3060 ผ่าน NullMoth 2.7.2** (Metal 3) · NootedRed ปิด · iGPU ไม่มีไดรเวอร์
- CPU: AMDRyzenCPUPowerManagement + SMCAMDProcessor อ่าน sensor ได้ · **SSDT-PWRL v2** ยกเพดานไฟตอนเสียบสายจาก ~34 W เป็น ~44 W (แบตเตอรี่คงเดิม 18.5 W)
- ใช้ได้: LAN, Bluetooth, เสียงลำโพง/ไมค์ (VoodooHDA), touchpad/keyboard · ยังไม่มี: Wi-Fi
- ยังไม่ทดสอบในชุดนี้: sleep/wake (SSDT-Acer-NoHybGfx ปิดอยู่), โหลดหนักต่อเนื่องนาน, CPU+GPU พร้อมกัน
- ช่วง 2026-10-27 → 11-06 (ติดตั้งใหม่และตั้ง NullMoth) **ไม่มีบันทึก** — ดูท้าย `docs/PROGRESS-2026-10-09.md`

ประวัติโดยย่อ: Sequoia 15.8.1 บูตได้ 2026-10-09/11 · Tahoe `candidate-tahoe10` 2026-10-12 · ถอดออก 2026-10-16 และ 2026-10-27 · ติดตั้ง Tahoe ใหม่ 2026-10-26 และอีกครั้งหลัง 10-27
`TARGET.json` สรุปสถานะและงานถัดไป (อัปเดต 2026-11-06)

## เริ่มอ่านที่ไหน

| อยากรู้ | อ่าน |
| --- | --- |
| ติดตั้ง Tahoe | `docs/TAHOE-INSTALL-TH.md` |
| วัดผล CPU/GPU, SSDT-PWRL | `tools/cpu-bench/`, `tools/gpu-bench/`, `components/ACPI/SSDT-PWRL.dsl` |
| ติดตั้ง Sequoia (ชุดสำรองบน USB) | `docs/SEQUOIA-REINSTALL-TH.md` |
| แผนติดตั้ง Tahoe | `docs/TAHOE-PLAN-TH.md` |
| EFI ที่บูต macOS ได้จริง (sanitized) | `final-efi/README-TH.md` |
| ติดตั้ง/อัปเดต OpenCore ลง ESP | `docs/EFI-UPDATE-TH.md` |
| จะทำอะไรต่อหลังติดตั้ง | `docs/DEV-PLAN-TH.md` |
| ปัญหาจอ/กราฟิก | `docs/GRAPHICS-ISSUE-TH.md` |
| บันทึกการทดลองทั้งหมด (อังกฤษ) | `docs/PROGRESS-2026-10-09.md` |

## เอกสารใน `docs/`

| ไฟล์ | เนื้อหา |
| --- | --- |
| `TAHOE-INSTALL-TH.md` | คู่มือติดตั้ง Tahoe 26.7.1 รอบ 2026-10-15 (ใช้ซ้ำ 2026-10-26) |
| `SEQUOIA-REINSTALL-TH.md` | คู่มือติดตั้ง Sequoia 15.8.1 รอบ 2026-10-14 |
| `TAHOE-PLAN-TH.md` | แผนและผลติดตั้ง Tahoe 26.7.1 |
| `EFI-UPDATE-TH.md` | ติดตั้ง/อัปเดต OpenCore บน ESP ของ Apacer |
| `DEV-PLAN-TH.md` | งานหลังติดตั้ง (ไม่จำเป็นต่อการบูต) |
| `GRAPHICS-ISSUE-TH.md` | ปัญหาภาพเพี้ยน/จอดำกับ NootedRed |
| `COMPATIBILITY-AUDIT.md` | ตรวจความเข้ากันได้ของฮาร์ดแวร์ |
| `USB-MAP-REVIEW.md` | ตรวจ USB map |
| `MT7921-WIFI-DRIVER-BRIEF.md` | โจทย์ไดรเวอร์ Wi-Fi MT7921 (ดู `../../research/mt7921/` ด้วย) |
| `PROGRESS-2026-10-09.md` | บันทึกความคืบหน้าทุกวัน (engineering log) |
| `archive/` | เอกสารช่วงเตรียมการ 2026-10-09 ที่ล้าสมัยแล้ว: `SUMMARY-TH.md`, `USB-INSTALL-TH.md`, `PREPARATION.md` |

## โครงสร้างโฟลเดอร์

| โฟลเดอร์/ไฟล์ | เนื้อหา |
| --- | --- |
| `TARGET.json` | สรุปเป้าหมาย สถานะ และขั้นต่อไป (ณ 2026-11-06) |
| `checksums.json` | SHA256 ของไฟล์ที่ดาวน์โหลด (ไบนารีไม่ได้ commit) |
| `docs/` | เอกสาร (ตารางด้านบน) |
| `final-efi/` | EFI ที่บูต Sequoia 15.8.1 ได้จริง (sanitized, ไม่มี PlatformInfo จริงและไม่มีไบนารี) |
| `candidates/` | EFI/config ที่ build ไว้ — เก็บเฉพาะชุดสำคัญ (ตารางด้านล่าง) |
| `components/` | SSDT ที่ทำเอง (`.dsl`/`.aml`), USB map, AMD patches |
| `acpi-analysis/` | ACPI tables ที่ dump จากเครื่องและ disassembly |
| `firmware-diagnostics/` | USB สำหรับเก็บข้อมูลเฟิร์มแวร์ (ไม่ใช่ตัวติดตั้ง macOS) |
| `firmware-evidence/` | ผลวิเคราะห์เฟิร์มแวร์ |
| `downloads/` | สำเนาเอกสาร/ซอร์สอ้างอิงจาก upstream (Dortania, ChefKiss, Apple) |
| `tools/` | สคริปต์ build/ติดตั้ง (`build_candidate.py`, `Install-OpenCore-ESP.ps1`, `Resume-Installer.ps1`, `verify_pkg.py`, …) |

`build_candidate.py` เขียน candidate ใหม่ไปที่ `candidates/<ชื่อ>/EFI` ส่วน `--private` เขียนไปที่ `private-build/<ชื่อ>/EFI` (gitignored)
`Install-OpenCore-ESP.ps1` ต้องระบุ `-Source` ทุกครั้ง (ไม่มีค่า default แล้ว)

## Candidates ที่เก็บไว้

| ชุด | ทำไมเก็บ |
| --- | --- |
| `candidate-v1` | baseline แรก + `CANDIDATE-v1.md` อธิบายที่มาของทุกค่า |
| `candidate-v3-test-noNR` | ชุดแรกที่บูต Recovery ได้เสถียร (NootedRed ปิด) |
| `candidate-v10` | Sequoia ที่บูตได้ และเป็นค่า default ของ `build_candidate.py` |
| `candidate-tahoe-install` | ชุดสำหรับติดตั้ง Tahoe |
| `candidate-tahoe10` | Tahoe ล่าสุดที่บูตจาก Apacer ได้ |

ชุดอื่น (`v2`–`v9`, `v7b`, `tahoe`–`tahoe9`, `*-test-*`) ลบออกเมื่อ 2026-10-15 กู้คืนได้จาก git:

```bash
git checkout 34293f5 -- staging/AN515-45-Tahoe/candidates/candidate-v9
```

(ไฟล์จะออกมาที่ path เดิม `staging/...` ย้ายเข้ามาที่ `candidates/` เอง) ในเอกสารเก่า `candidate-vN` หมายถึง `candidates/candidate-vN`

## โฟลเดอร์ที่อยู่เฉพาะในเครื่อง (ไม่เข้า git)

| โฟลเดอร์ | เนื้อหา |
| --- | --- |
| `installer/` | ตัวติดตั้ง Sequoia 15.8.1, Tahoe 26.7.1 (ตรวจ SHA แล้ว) และ Recovery 15.4.1 |
| `packages/` | OpenCore/kext ที่แตก zip แล้ว ใช้โดย `build_candidate.py` |
| `private/` | `PlatformInfo.json` (serial จริง) และ `usb-snapshot-2026-10-11/` (สำเนา USB เดิม: EFI, rescue configs) |
| `private-build/` | EFI ที่ใส่ serial จริงแล้ว: `candidate-tahoe10-install` (ชุดบน USB KINGSTON ตอนนี้), `candidate-tahoe10` (หลังติดตั้ง), `sequoia-install`, `usb-backup-2026-10-14` |
| `boot-logs/` | OpenCore logs และรูปหน้าจอจากการทดลอง |
| `tools/SSDTTime/` | เครื่องมือ SSDTTime + ACPI dump จากเครื่องนี้ (`Results/OEM`) |
| `firmware-evidence/SysReport/` | SysReport ดิบ |

ทั้งหมดมีข้อมูล identity หรือเป็นไบนารีที่โหลดใหม่ได้ตาม `checksums.json` / `final-efi/MANIFEST.md`
