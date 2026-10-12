# Acer Nitro 5 AN515-45 — Hackintosh (macOS Sequoia 15.8.1)

ชื่อโฟลเดอร์มีคำว่า "Tahoe" ด้วยเหตุผลทางประวัติ เป้าหมายที่ใช้งานจริงคือ Sequoia 15.8.1 (ดู `TARGET.json`)

## เริ่มอ่านที่ไหน

| อยากรู้ | อ่าน |
| --- | --- |
| สถานะตอนนี้แบบสั้น | `TARGET.json` |
| EFI ที่บูต macOS ได้จริง | `final-efi/README-TH.md` |
| จะทำอะไรต่อ | `docs/DEV-PLAN-TH.md` |
| ติดตั้ง/อัปเดต OpenCore ลง ESP | `docs/EFI-UPDATE-TH.md` |
| ปัญหาจอ/กราฟิก | `docs/GRAPHICS-ISSUE-TH.md` |
| บันทึกการทดลองทั้งหมด | `docs/PROGRESS-2026-10-09.md` |

## โครงสร้างโฟลเดอร์

| โฟลเดอร์/ไฟล์ | เนื้อหา |
| --- | --- |
| `TARGET.json` | สรุปเป้าหมาย สถานะ และขั้นต่อไป |
| `checksums.json` | SHA256 ของไฟล์ที่ดาวน์โหลด (ไบนารีไม่ได้ commit) |
| `docs/` | เอกสารทั้งหมด: สรุป, แผน, คู่มือติดตั้ง, compatibility audit, USB map review, บันทึกความคืบหน้า |
| `final-efi/` | EFI ที่ใช้งานได้จริง (sanitized, ไม่มี PlatformInfo จริงและไม่มีไบนารี) |
| `candidates/` | EFI/config ทุกรุ่นที่สร้างระหว่างทดลอง (`candidate-v1` … `candidate-v9`, `*-test-*`) — เก็บไว้เป็นประวัติ |
| `components/` | SSDT ที่ทำเอง (`.dsl`/`.aml`), USB map, AMD patches |
| `acpi-analysis/` | ACPI tables ที่ dump จากเครื่องและ disassembly |
| `firmware-diagnostics/` | USB สำหรับเก็บข้อมูลเฟิร์มแวร์ (ไม่ใช่ตัวติดตั้ง macOS) |
| `firmware-evidence/` | ผลวิเคราะห์เฟิร์มแวร์ |
| `downloads/` | สำเนาเอกสาร/ซอร์สอ้างอิงจาก upstream (Dortania, ChefKiss, Apple) |
| `tools/` | สคริปต์ build/ติดตั้ง (`build_candidate.py`, `Install-OpenCore-ESP.ps1`, …) |

`build_candidate.py` เขียน candidate ใหม่ไปที่ `candidates/<ชื่อ>/EFI` ส่วน `--private` ยังเขียนไปที่ `private-build/<ชื่อ>/EFI` (gitignored) เหมือนเดิม

## โฟลเดอร์ที่อยู่เฉพาะในเครื่อง (ไม่เข้า git)

`private/`, `private-build/`, `packages/`, `installer/`, `boot-logs/`, `SysReport/`
และ kext/ไฟล์ `.efi` ทั้งหมด — มีข้อมูล identity หรือเป็นไบนารีที่โหลดใหม่ได้ตาม `checksums.json` / `final-efi/MANIFEST.md`

ข้อความในเอกสารเก่า (เช่น `docs/PROGRESS-2026-10-09.md`) ที่เขียนว่า `candidate-vN` หมายถึง `candidates/candidate-vN` ตั้งแต่จัดโครงสร้างใหม่
