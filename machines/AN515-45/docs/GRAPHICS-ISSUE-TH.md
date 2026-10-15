# ปัญหาหน้าจอ / กราฟิก — Acer Nitro 5 AN515-45 (macOS Sequoia 15.8.1)

อัปเดต: 2026-10-09 · สถานะ: **ยังไม่แก้** (มีวิธีบรรเทา รอทดสอบ)

## อาการ

- หน้าต่างแอปบางตัว **ภาพเพี้ยนเป็นจุด/บล็อก** ข้อความอ่านไม่ออก: Claude, ChatGPT, Codex ตามรายงานผู้ใช้; ยังไม่ได้ยืนยัน framework และเวอร์ชันของแต่ละ app bundle บนเครื่อง จึงไม่ถือว่าทั้งหมดเป็น Electron/Chromium
- **Safari** บางหน้าเนื้อหาเป็น **สีดำ**
- ส่วนอื่นแสดงผลปกติ: วอลเปเปอร์, Dock, แถบเมนู, Finder, System Settings
- ไม่มี panic เครื่องยังใช้งานต่อได้

หลักฐาน: รูปจากผู้ใช้ 5 รูป (เก็บในเครื่อง ไม่อยู่ใน git)

## เครื่องและค่าที่เกี่ยวข้อง

| รายการ | ค่า |
| --- | --- |
| iGPU | AMD Radeon Vega (Cezanne), PCI 1002:1638, จอในเครื่อง 1920×1080 144 Hz ต่อกับ iGPU |
| dGPU | NVIDIA RTX 3060 Laptop 10DE:2520 — macOS ไม่มีไดรเวอร์ (เปิดทิ้งไว้ตามที่ผู้ใช้เลือก) |
| ไดรเวอร์กราฟิก | NootedRed 0.8.10 + Lilu 1.7.2 ตามบันทึกชุด EFI; ยังต้องยืนยันเวอร์ชันที่โหลดจริงใน macOS |
| SMBIOS | MacBookPro16,2 (ตามที่ NootedRed แนะนำ) |
| VRAM (UMA) | **512 MB** — NootedRed ต้องการ "512MiB minimum, 1GiB+ for proper functionality" |
| ความสว่างจอ | SSDT-PNLF + ALS0 + SMCLightSensor + BrightnessKeys — ใช้ได้ |
| EFI ปัจจุบัน | candidate-v9 (+ PlatformInfo ส่วนตัว) บน EFI ของ Apacer |

## ข้อมูล upstream และข้อสันนิษฐาน (ยังไม่ยืนยัน root cause บนเครื่องนี้)

1. **ปัญหาที่ NootedRed ยอมรับไว้เอง** — หน้า NootedRed ของ ChefKiss (บันทึกไว้ 2026-10-09):
   > Chrome, Chromium-based browsers and apps like Sublime Text cause graphical artefacts amongst other problems — *Known issue, unknown cause.*
   วิธีเลี่ยงที่แนะนำ: ปิด GPU rasterisation / hardware acceleration หรือเปิดแอปด้วย `--disable-gpu`
2. **Issue ที่ยังเปิดอยู่:** NootedRed #158 "Blend shader functions cause corruption, freezes or crashes"
3. **VRAM น้อย** (512 MB) — ต่ำกว่าที่แนะนำ อาจทำให้อาการหนักขึ้น
4. **ข้อแนะนำสำหรับ Sonoma ขึ้นไป** (หน้าเดียวกัน): ใช้วอลเปเปอร์ภาพนิ่ง และไม่ใช้ Memoji เป็นรูปโปรไฟล์ เพื่อลดปัญหา compute

การที่บันทึก EFI มี SMBIOS, ลำดับ Lilu และไม่มี WhateverGreen ตามคำแนะนำ ยังไม่เพียงพอที่จะตัดปัญหา config หรือยืนยัน root cause ต้องมีผลทดสอบเปรียบเทียบบน macOS ก่อน ส่วน UMA 512 MB เป็นข้อมูลที่รายงานมา ไม่ใช่ข้อพิสูจน์ว่าการเพิ่ม UMA จะแก้ภาพเพี้ยน

## วิธีบรรเทา (เรียงจากง่ายไปยาก)

| # | วิธี | เสี่ยง | สถานะ |
| --- | --- | --- | --- |
| 1 | เปิดแอป Electron ด้วย `open -a "Claude" --args --disable-gpu` (เปลี่ยนชื่อแอปตามต้องการ) | ไม่มี | ⏳ รอทดสอบ |
| 2 | Chrome/Edge: ปิด **GPU rasterization** ใน `chrome://flags` | ไม่มี | — |
| 3 | ตั้งวอลเปเปอร์เป็นภาพนิ่ง, ไม่ใช้ Memoji | ไม่มี | ⏳ |
| 4 | เข้า BIOS (F2) หาเมนู UMA Frame Buffer Size → ตั้ง 1 GB ขึ้นไป | ต่ำ (ถ้ามีเมนู) | ⏳ ยังไม่ได้ตรวจ |
| 5 | ปลดล็อกเมนู BIOS ที่ซ่อนด้วย Smokeless-UMAF เพื่อเพิ่ม UMA | **สูง** — แก้ค่า BIOS ที่ซ่อนอยู่ | ไม่แนะนำถ้าไม่จำเป็น |
| 6 | ลอง NootedRed nightly build (อาจมีแก้แล้ว) — ทดสอบผ่าน USB เท่านั้น | กลาง | ยังไม่ทำ |

ถ้าข้อ 1 ได้ผล ทำ shortcut/Automator ให้เปิดแอปพร้อม `--disable-gpu` ทุกครั้ง

ข้อจำกัดการทดสอบ: ต้อง Quit แอปและให้ process เดิมสิ้นสุดก่อนเปิดด้วย flag
มิฉะนั้นอาจเพียงเปิดหน้าต่างของ process เก่าซึ่งไม่ได้รับ flag ใหม่
ใช้เฉพาะแอปที่ยืนยันว่ารองรับ switch นี้ ไม่ใช้เป็นวิธีแก้ Safari แบบเหมารวม
ตารางด้านบนเป็นวิธีที่เอกสารเดิมเสนอ ยังไม่มีผลทดลองใน session นี้

## เริ่มวินิจฉัยใหม่ 2026-10-09

| รายการ | หลักฐาน / ผล | สถานะ |
| --- | --- | --- |
| อาการเดิม | เอกสารอ้างถึงภาพ 5 รูป แต่ session นี้ยังไม่ได้เห็นรูปหรือเข้าถึง macOS | User-reported |
| upstream #158 | ตรวจหน้า issue แล้ว ยัง Open; ปัญหา dual-source blending มีรายงาน upstream | ไม่ยืนยันสาเหตุเฉพาะเครื่อง |
| reproduction | รอชื่อ/เวอร์ชันแอป หน้าที่กระตุ้นอาการ และผลเปิดปกติซ้ำ | Pending |
| baseline environment | รอ macOS/Darwin และข้อมูล GPU/VRAM ที่ macOS เห็นจริง | Pending |
| การแก้ไขเครื่อง | ยังไม่เปลี่ยน EFI, BIOS, boot-args หรือการตั้งค่าแอป | None |

ขั้นเก็บ baseline: เลือกแอปเดียว (เช่น Claude) เปิดหน้าเดิมด้วยวิธีปกติ
บันทึกผล จากนั้น Quit และเปิดซ้ำอีกครั้ง โดยยังไม่เปลี่ยนตัวแปรอื่น
ระบุว่าเพี้ยนทั้งหน้าต่างหรือเฉพาะเนื้อหา และเกิด 2/2 ครั้งหรือไม่
สำหรับ Safari ต้องมีหน้าตัวอย่างแยก ไม่ถือว่าเป็นอาการเดียวกันอัตโนมัติ
ผลคำสั่ง `sw_vers`, `uname -r`, `system_profiler SPDisplaysDataType`
ใช้ประกอบ baseline ได้; ปิดบัง serial/UUID ของจอหรืออุปกรณ์ก่อนแชร์

### ทิศทาง root-cause research จาก upstream (ตรวจ 2026-10-09)

ผู้ใช้ต้องการแก้สาเหตุจริง ไม่หยุดที่การปิด hardware acceleration
ตรวจ issue #158 ครบทั้งสองหน้าของ comments ผ่าน GitHub API (114 comments, issue ยัง open):

- [2024-08-25](https://github.com/ChefKissInc/NootedRed/issues/158#issuecomment-2308900749): ผู้พัฒนาระบุความเกี่ยวข้องกับ dual-source blending แต่แก้ข้อความภายหลังว่าอาจเป็น blending โดยรวม; workaround ไม่ได้ผลเสมอ
- [2025-03-02](https://github.com/ChefKissInc/NootedRed/issues/158#issuecomment-2692960734): ผู้พัฒนาระบุว่าต้องใช้ user-space patches ที่ซับซ้อนกว่าการ patch ผ่าน Lilu ตามปกติ
- [2026-07-13](https://github.com/ChefKissInc/NootedRed/issues/158#issuecomment-4956933150): เสนอว่าบางฟังก์ชันขาดกรณี iGPU จึงใช้ค่าของ Vega dGPU เป็นทฤษฎีที่ยังไม่ยืนยันด้วยการแก้และทดสอบสำเร็จ

นี่เป็นทิศทางวิจัยสำหรับ upstream bug ไม่ใช่ข้อพิสูจน์ของเครื่องนี้หรือ Safari
ยังไม่มีผล A/B, patch หรือ boot test ใน session นี้ จึงไม่สร้าง EFI candidate แบบคาดเดา
การทดลองปิด acceleration เป็นเพียงเครื่องมือแยกเส้นทางที่เสีย ไม่ใช่ผลแก้ root cause

### อาการค้างเพิ่มเติมจากผู้ใช้

ผู้ใช้รายงานว่าพบทั้งแอปค้าง จอหยุดแต่เสียงยังเล่น เครื่องหยุดจนต้องกด Power
และหน่วงแล้วกลับมาใช้ได้ โดย Safari เพียงสองหน้าก็เริ่มมีอาการ
ยังไม่ทราบ URL/เนื้อหา ระยะเวลาจนค้าง memory pressure, swap, CPU usage
หรือความสัมพันธ์กับ sleep/wake จึงยังแยก GPU hang ออกจาก memory/CPU/I/O stall ไม่ได้
ขั้นถัดไป: เก็บ Activity Monitor แท็บ Memory และ CPU ขณะเริ่มหน่วง
พร้อมชื่อหน้าที่กระตุ้นอาการ (ไม่แชร์ URL ที่มี token/ข้อมูลส่วนตัว)
ยังไม่มีการเปลี่ยนค่า EFI หรือยืนยันว่า UMA เป็นสาเหตุ

## สิ่งที่ยังไม่ได้ทดสอบเกี่ยวกับจอ

- ออกจอนอก (HDMI/USB-C) — HDMI ต่อกับ dGPU หรือ iGPU ยังไม่ทราบ (ถ้าต่อกับ RTX 3060 จะใช้ใน macOS ไม่ได้)
- Sleep/wake แล้วจอกลับมาไหม
- Refresh rate 144 Hz ใน macOS
- Video decode (VCN) — NootedRed #28 ยังเปิดอยู่ ดูวิดีโออาจใช้ CPU แทน

## ถ้าจะลองแก้ต่อ (สำหรับ AI/คนที่ทำต่อ)

1. เก็บข้อมูลก่อนแก้: `system_profiler SPDisplaysDataType`, `ioreg -l | grep -i "VRAM\|nootedred"`, ผลข้อ 1 และ 3
2. ทุกการเปลี่ยน EFI: แก้ใน staging → `tools/build_candidate.py` → ocvalidate → **ทดสอบจาก USB** → ถ้าผ่านค่อย build `--private` แล้วติดตั้งด้วย `tools/Install-OpenCore-ESP.ps1`
3. DeviceProperties ต้องใช้ path `PciRoot(0x1)/...` (PCI0 _UID = 1)
4. เปลี่ยนทีละอย่าง บันทึกผลใน `PROGRESS-2026-10-09.md`

แหล่งอ้างอิง: https://chefkiss.dev/applehax/nootedred · https://github.com/ChefKissInc/NootedRed/issues/158 · https://github.com/ChefKissInc/NootedRed/issues/28
