# แผนพัฒนา — Hackintosh AN515-45 (หลัง Final EFI)

สร้าง: 2026-10-12 · ฐานอ้างอิง: commit `3790943` (Final EFI, Sequoia 24.6)

เอกสารนี้คือแผนว่าจะทำอะไรต่อ ไม่ใช่บันทึกผล — ผลการทดสอบให้บันทึกใน `PROGRESS-*.md`
และอัปเดต `TARGET.json` เมื่อสถานะเปลี่ยน

---

## สถานะปัจจุบัน (ตรวจจาก config ที่ commit แล้ว)

| รายการ | ค่า | หลักฐาน |
| --- | --- | --- |
| macOS | Sequoia 15.8.1 (24H32) บูตได้ | OpenCore log 2026-10-11: `Read kernel version 24.6.0` |
| OpenCore | 1.0.8 DEBUG | `ocvalidate` 1.0.8: no issues |
| SMBIOS | MacBookPro16,2 | `final-efi/EFI/OC/config.plist` |
| กราฟิก | NootedRed 0.8.10 ขับจอในตัว (Vega/Cezanne) | ใช้งานได้ ยกเว้นอาการใน `GRAPHICS-ISSUE-TH.md` |
| dGPU | SSDT-Acer-NoHybGfx **เปิดใช้งานอยู่** | เรียก `_DSM` + `_PS3` ที่ `\_SB.PCI0.GPP0.PEGP` เฉพาะ Darwin |
| SIP | `csr-active-config` = `00000000` (เปิดเต็ม) | config.plist |
| boot-args | `-v keepsyms=1 debug=0x100` | config.plist |
| SecureBootModel | Disabled | config.plist |
| ยังไม่ลง | Bluetooth (SimpleMtkBtFw), Wi-Fi MT7921 | `TARGET.json` nextSteps |

---

## ปัญหาความสอดคล้องของเอกสาร (ต้องปิดก่อน)

ทั้งสองข้อนี้ทำให้งานต่อไปตั้งต้นผิดได้ จึงอยู่ลำดับแรก

1. **`GRAPHICS-ISSUE-TH.md` เขียนว่า dGPU "เปิดทิ้งไว้ตามที่ผู้ใช้เลือก"**
   แต่ config ที่บูตจริงเปิด `SSDT-Acer-NoHybGfx` ซึ่งพยายามสั่งปิด dGPU ใน Darwin
   — ข้อความขัดกัน ต้องตรวจว่าจริง ๆ แล้ว dGPU อยู่สถานะไหนแล้วแก้เอกสารให้ตรง
2. **`final-efi/README-TH.md` อ้างถึง `../TAHOE-PLAN-TH.md` ซึ่งไม่มีอยู่ในรีโป**
   — ต้องสร้าง หรือลบการอ้างอิงออก

หมายเหตุสำคัญ: `PROGRESS-2026-10-09.md` บันทึกไว้ว่า `PEGP._PS3` มีเงื่อนไข `OPCE == 3`
ดังนั้น **การเรียก `_PS3` ไม่ได้แปลว่า dGPU ถูกปิดจริง** ต้องพิสูจน์ด้วย ioreg ไม่ใช่สมมติจากชื่อ SSDT

---

## เฟส 1 — ปิดช่องว่างข้อมูล (ไม่แก้ EFI)

ทำได้เลย ความเสี่ยงศูนย์ เพราะเป็นการอ่านอย่างเดียว

| # | งาน | คำสั่ง / วิธี | ปิดคำถามอะไร |
| --- | --- | --- | --- |
| 1.1 | สถานะ dGPU จริงใน macOS | `ioreg -l \| grep -i -A5 "PEGP\|GPP0"` และ `system_profiler SPDisplaysDataType` | SSDT ปิด dGPU ได้จริงไหม |
| 1.2 | VRAM ที่ NootedRed ได้รับ | `ioreg -l \| grep -i "VRAM"` | 512 MB ตามที่สันนิษฐานหรือไม่ |
| 1.3 | พอร์ต HDMI ต่อกับ GPU ตัวไหน | ฝั่ง Windows: เสียบจอนอก → Task Manager > Performance ดูว่า GPU ตัวใดมี output / NVIDIA Control Panel เห็นจอนอกไหม | ตัดสินว่าแนวทาง NVIDIA มีทางไปต่อหรือไม่ |
| 1.4 | เมนู UMA Frame Buffer ใน BIOS | เข้า BIOS (F2) หาเมนู UMA | เพิ่ม VRAM เป็น 1 GB ได้ไหม |
| 1.5 | Refresh rate ที่ได้จริง | System Settings > Displays | 144 Hz ใช้ได้ไหม |

**ผลข้อ 1.3 เป็นตัวตัดสินทิศทางของเฟส 4** ถ้า HDMI เดินจาก iGPU → แนวทาง NVIDIA แทบไม่มีประโยชน์กับเครื่องนี้

---

## เฟส 2 — แก้อาการจอเพี้ยน (ไม่แก้ EFI)

จาก `GRAPHICS-ISSUE-TH.md` — เป็นบั๊กที่ NootedRed ยอมรับเองเรื่องแอป Chromium/Electron
ไม่ใช่ปัญหา config ดังนั้นแก้ที่ฝั่ง OS ก่อน

| # | งาน | ความเสี่ยง |
| --- | --- | --- |
| 2.1 | ทดสอบ `open -a "Claude" --args --disable-gpu` | ไม่มี |
| 2.2 | ปิด GPU rasterization ใน `chrome://flags` | ไม่มี |
| 2.3 | ตั้งวอลเปเปอร์ภาพนิ่ง ไม่ใช้ Memoji | ไม่มี |
| 2.4 | ถ้า 2.1 ได้ผล → ทำ Automator/shortcut ให้ถาวร | ไม่มี |
| 2.5 | ถ้า 1.4 มีเมนู UMA → ตั้ง 1 GB แล้ววัดผลซ้ำ | ต่ำ |

เกณฑ์ปิดงาน: บันทึกว่าแต่ละวิธีได้ผล/ไม่ได้ผล พร้อมแอปที่ทดสอบ ลงใน `PROGRESS-*.md`

ยังไม่ทำตอนนี้: Smokeless-UMAF (เสี่ยงสูง), NootedRed nightly (ทดสอบจาก USB เท่านั้น)

---

## เฟส 3 — งานค้างจาก `TARGET.json`

เรียงตามผลตอบแทนต่อความเสี่ยง ทุกข้อแก้ EFI → ต้องผ่านลูป staging → `build_candidate.py` → `ocvalidate` → **ทดสอบจาก USB** → แล้วค่อย `--private` ลง ESP

| # | งาน | สถานะ | หมายเหตุ |
| --- | --- | --- | --- |
| 3.1 | USB map review | `USBMap.kext` ยัง experimental | ดู `USB-MAP-REVIEW.md`; ChefKiss แนะนำ native map |
| 3.2 | Bluetooth — retest SimpleMtkBtFw พร้อม log | kext อยู่ใน config แล้ว ยังไม่ยืนยันผล | build ด้วย `--bt` |
| 3.3 | Wi-Fi MT7921 | งานไดรเวอร์ภายนอก | ดู `MT7921-WIFI-DRIVER-BRIEF.md`; ทางเลือก = เปลี่ยนการ์ด |
| 3.4 | Sleep/wake | ยังไม่ทดสอบ | ทดสอบหลัง 3.1 เพราะ USB map กระทบ sleep |
| 3.5 | ล้าง `OC.bak-*` บน ESP + จัด OpenCore ขึ้นก่อนใน boot order | ค้าง | งานบ้าน ทำเมื่อว่าง |

---

## เฟส 4 — การทดลอง NVIDIA (แยกต่างหาก ทำทีหลัง)

**ห้ามแตะ ESP ที่ใช้งานอยู่** ต้องเป็น candidate แยกและทดสอบจาก USB เท่านั้น

### เงื่อนไขก่อนเริ่ม

- ผลข้อ 1.3 ต้องออกมาว่า **HDMI เดินตรงจาก RTX 3060** ถ้าไม่ใช่ ให้ปิดแนวทางนี้แล้วบันทึกเหตุผล
- ไดรเวอร์ `nullmoth/nvidia-macos-driver` รองรับ macOS 15 และการ์ด Turing ขึ้นไป (RTX 3060 = Ampere อยู่ในตาราง)
  แต่ทดสอบจริงบนฮาร์ดแวร์เพียง RTX 5060 — README ระบุเองว่า device table กว้างกว่าการทดสอบจริง

### จุดที่ขัดกับ config ปัจจุบัน (ต้องแก้ ต้องทดสอบ)

| รายการ | ค่าปัจจุบัน | ที่ไดรเวอร์ต้องการ | ความขัดแย้ง |
| --- | --- | --- | --- |
| SMBIOS | MacBookPro16,2 (NootedRed แนะนำ) | รุ่นที่มี dGPU, ทดสอบด้วย `iMacPro1,1` | **ขัดกันโดยตรง** |
| SSDT-Acer-NoHybGfx | เปิด | ต้องปิด (dGPU ต้องมองเห็นได้) | ต้องปิด |
| ResizeAppleGpuBars | ไม่ได้ตั้ง | ต้องตั้งตามคู่มือ | ต้องเพิ่ม |
| csr-active-config | `00000000` | ค่าตามคู่มือไดรเวอร์ | ต้องเปลี่ยน |
| SecureBootModel | Disabled | Disabled | ตรงแล้ว |
| WhateverGreen / `nv_disable=1` | ไม่มีอยู่แล้ว | ต้องไม่มี | ตรงแล้ว |
| Above 4G Decoding / CSM | ยังไม่ตรวจ | ON / OFF | ต้องตรวจใน BIOS |

### สิ่งที่ยังไม่มีใครตอบได้

- README ของไดรเวอร์ **ไม่พูดถึงการ์ดโน้ตบุ๊ก, Max-Q, muxless/Optimus หรือจอในตัวเลย**
- ไม่พูดถึงแพลตฟอร์ม AMD (เครื่องนี้ Ryzen ต้องใช้ AMD kernel patch)
- ยังไม่มีใครยืนยันว่ารัน NootedRed (Vega) คู่กับไดรเวอร์นี้ (RTX) พร้อมกันได้

**ข้อเท็จจริงที่ต้องจำ:** ไดรเวอร์นี้ไม่ได้ทำให้ Optimus ทำงาน macOS ไม่มีกลไก muxless
จอในตัวยังต่อกับ Vega เหมือนเดิม ทางที่เป็นไปได้มีทางเดียวคือจอนอกที่เดินตรงจาก dGPU

### ลำดับถ้าจะลองจริง

1. สร้าง `candidate-nvidia-v1` แยก ไม่แตะ `final-efi`
2. แก้ทีละอย่างตามตารางข้างบน บันทึกทุกการเปลี่ยน
3. `ocvalidate` ให้ผ่าน
4. บูตจาก USB พร้อมจอนอกเสียบไว้ เก็บ log
5. ถ้าพัง → กลับไปบูต ESP เดิม ซึ่งไม่ถูกแตะต้อง

---

## ลำดับที่แนะนำ

```
เฟส 1 (อ่านอย่างเดียว)  →  เฟส 2 (แก้ที่ OS)  →  เฟส 3 (แก้ EFI ทีละข้อ)  →  เฟส 4 (ทดลองแยก)
      ↑                                                                              ↑
  ทำได้เลยวันนี้                                                      ต้องรอผล 1.3 ก่อน
```

เหตุผล: เฟส 1–2 ไม่แตะ EFI ที่บูตได้อยู่ จึงไม่มีอะไรเสีย และผลจากเฟส 1 เป็นข้อมูลตั้งต้นของทุกเฟสถัดไป

---

## กฎที่ใช้กับทุกเฟส (จาก `AGENTS.md`)

- แก้ทีละอย่าง บันทึกผลทุกครั้ง
- ทดสอบจาก USB ก่อนเสมอ ไม่เขียนทับ ESP ที่ใช้งานได้
- PlatformInfo จริงอยู่ใน `private/` เท่านั้น build ด้วย `--private` สำหรับ ESP
- ปกปิด serial / MLB / UUID / ROM / MAC ในทุกสรุปและตัวอย่าง
- ยืนยันข้อมูลที่ขึ้นกับเวอร์ชันกับเอกสารต้นทาง และระบุเวอร์ชันที่ตรวจ
- `ocvalidate` ผ่าน ≠ บูตได้ — ระบุเสมอว่าอะไรยังไม่ได้พิสูจน์

---

## แหล่งอ้างอิงที่ใช้ในแผนนี้

- `final-efi/EFI/OC/config.plist` และ `MANIFEST.md` (commit `3790943`)
- `GRAPHICS-ISSUE-TH.md`, `PROGRESS-2026-10-09.md`, `TARGET.json`
- https://github.com/nullmoth/nvidia-macos-driver — ตรวจ 2026-10-12
- https://nullmothsystems.com/ — ตรวจ 2026-10-12 (ไดรเวอร์ 1.13.0)
- https://chefkiss.dev/applehax/nootedred — ตามที่บันทึกไว้ใน `GRAPHICS-ISSUE-TH.md`
