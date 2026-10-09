# ปัญหาหน้าจอ / กราฟิก — Acer Nitro 5 AN515-45 (macOS Sequoia 15.8.1)

อัปเดต: 2026-10-09 · สถานะ: **ยังไม่แก้** (มีวิธีบรรเทา รอทดสอบ)

## อาการ

- หน้าต่างแอปบางตัว **ภาพเพี้ยนเป็นจุด/บล็อก** ข้อความอ่านไม่ออก: Claude, ChatGPT, Codex (แอป Electron/Chromium)
- **Safari** บางหน้าเนื้อหาเป็น **สีดำ**
- ส่วนอื่นแสดงผลปกติ: วอลเปเปอร์, Dock, แถบเมนู, Finder, System Settings
- ไม่มี panic เครื่องยังใช้งานต่อได้

หลักฐาน: รูปจากผู้ใช้ 5 รูป (เก็บในเครื่อง ไม่อยู่ใน git)

## เครื่องและค่าที่เกี่ยวข้อง

| รายการ | ค่า |
| --- | --- |
| iGPU | AMD Radeon Vega (Cezanne), PCI 1002:1638, จอในเครื่อง 1920×1080 144 Hz ต่อกับ iGPU |
| dGPU | NVIDIA RTX 3060 Laptop 10DE:2520 — macOS ไม่มีไดรเวอร์ (เปิดทิ้งไว้ตามที่ผู้ใช้เลือก) |
| ไดรเวอร์กราฟิก | NootedRed 0.8.10 (release ล่าสุด) + Lilu 1.7.2 |
| SMBIOS | MacBookPro16,2 (ตามที่ NootedRed แนะนำ) |
| VRAM (UMA) | **512 MB** — NootedRed ต้องการ "512MiB minimum, 1GiB+ for proper functionality" |
| ความสว่างจอ | SSDT-PNLF + ALS0 + SMCLightSensor + BrightnessKeys — ใช้ได้ |
| EFI ปัจจุบัน | candidate-v9 (+ PlatformInfo ส่วนตัว) บน EFI ของ Apacer |

## สาเหตุ (จากแหล่งข้อมูลทางการ)

1. **ปัญหาที่ NootedRed ยอมรับไว้เอง** — หน้า NootedRed ของ ChefKiss (บันทึกไว้ 2026-10-09):
   > Chrome, Chromium-based browsers and apps like Sublime Text cause graphical artefacts amongst other problems — *Known issue, unknown cause.*
   วิธีเลี่ยงที่แนะนำ: ปิด GPU rasterisation / hardware acceleration หรือเปิดแอปด้วย `--disable-gpu`
2. **Issue ที่ยังเปิดอยู่:** NootedRed #158 "Blend shader functions cause corruption, freezes or crashes"
3. **VRAM น้อย** (512 MB) — ต่ำกว่าที่แนะนำ อาจทำให้อาการหนักขึ้น
4. **ข้อแนะนำสำหรับ Sonoma ขึ้นไป** (หน้าเดียวกัน): ใช้วอลเปเปอร์ภาพนิ่ง และไม่ใช้ Memoji เป็นรูปโปรไฟล์ เพื่อลดปัญหา compute

ไม่ใช่ปัญหาจาก config ของ OpenCore — ค่า EFI ตรงตามที่ NootedRed กำหนด (SMBIOS, ไม่มี WhateverGreen, Lilu มาก่อน)

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
