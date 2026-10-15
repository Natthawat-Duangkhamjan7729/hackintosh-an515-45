# สถานะไดรเวอร์ NullMoth NVIDIA — Tahoe และการ์ดโน้ตบุ๊ก

ตรวจ 2026-10-13 · อัปเดต 2026-10-15 (v2.0.0 รองรับ Tahoe ดู[ท้ายเอกสาร](#อัปเดต-2026-10-15--v200-รองรับ-tahoe-อย่างเป็นทางการแล้ว)) · สถานะ: **หลักฐานจากภายนอก ยังไม่ได้ทดสอบบนเครื่องนี้**

ตอบคำถาม G3 ใน [`../macos-cross-gpu/README-TH.md`](../macos-cross-gpu/README-TH.md)
ว่าไดรเวอร์รองรับ RTX 3060 Laptop (GA106) บนเวอร์ชัน macOS ที่เราจะใช้หรือไม่

## ระดับความน่าเชื่อถือของแหล่ง

เรียงจากสูงไปต่ำ — ใช้ตัดสินน้ำหนักของทุกข้อด้านล่าง

1. **หน้าเว็บทางการ / README / release** — ตรวจเองได้ตลอดเวลา
2. **บอตประกาศใน Discord** (`Big Brother`, `Moth`) — ข้อความอัตโนมัติจากโปรเจกต์
3. **ข้อความจากผู้พัฒนา** (`nullmoth`)
4. **ข้อความจากสมาชิก** — เบาะแส ไม่ใช่ข้อสรุป

---

## 1. เวอร์ชันและการรองรับ macOS (ทางการ)

| รายการ | ค่า | แหล่ง |
| --- | --- | --- |
| เวอร์ชันล่าสุด | **1.14.7** | nullmothsystems.com/downloads — "DRIVER 1.14.7 OUT NOW" |
| macOS ที่ระบุรองรับ | **macOS 15 Sequoia เท่านั้น** | หน้าเดียวกัน |
| macOS 26 Tahoe | **ไม่ถูกกล่าวถึงเลย** | หน้าเดียวกัน |
| การ์ดที่รองรับ | Turing ขึ้นไป (GTX 16, RTX 20/30/40/50) 235 display-card ID | หน้าเดียวกัน |
| การ์ดที่ยืนยันด้วยฮาร์ดแวร์ | RTX 5060 (validated) · RTX 5070, 5080 (รายงานว่าใช้ได้) | หน้าเดียวกัน |

**ข้อสังเกต:** หน้า GitHub releases ที่ดึงมาได้แสดงแค่ 1.0.0 (7 ต.ค.) ซึ่งไม่ตรงกับเว็บทางการ
ให้ถือว่าเว็บทางการเป็นแหล่งที่อัปเดตกว่า และตรวจซ้ำที่ `CARD-SUPPORT.md` ในรีโปก่อนใช้งานจริง

---

## 2. Tahoe — เอกสารทางการขัดกันเอง

| หลักฐาน | เนื้อหา | น้ำหนัก |
| --- | --- | --- |
| เว็บทางการ (ตรวจ 13 ต.ค.) | ไม่กล่าวถึง Tahoe เลย | สูง |
| บอต `Moth`, start-here, 10 ต.ค. | "The NVIDIA driver targets macOS 15 Sequoia and newer, although only Sequoia is currently supported. **Support for macOS 26 Tahoe is planned.**" — **ประโยคนี้ถูกลบออกจาก start-here แล้ว** | กลาง |
| บอต `Big Brother`, 1.14.0, 12 ต.ค. | changelog มีบรรทัด "Black desktop on macOS 26 (Tahoe)" | กลาง |
| บอต `Big Brother`, 1.14.1 / 1.14.2, 12 ต.ค. | "Preparing a 1401 desktop for macOS 26 (Tahoe) now moves it from **iMacPro1,1 (which macOS 26 refuses) to MacPro7,1**" | กลาง |
| สมาชิก `WindowServer` (ปักหมุดใน #tahoe), 12 ต.ค. | "the official driver does not support Tahoe, so we cannot advocate for actually installing it" | ต่ำ (แต่ถูกปักหมุด) |
| สมาชิก `AppleKeyStoreIsStupid`, 13 ต.ค. | "not yet, nullmoth is gonna release it with 2.0" · "should be within a few days" | ต่ำ ไม่มีแหล่งทางการยืนยัน |
| ผู้ใช้จริง `Sayoneku`, 11 ต.ค. | ลง Tahoe ด้วย 1.13 แล้วบูตปกติไม่ได้ ต้องเข้า Safe Mode | ต่ำ |
| ผู้ใช้จริง `Miteigi`, 12 ต.ค. | "macOS Tahoe works too!" | ต่ำ |

**สรุปข้อ 2:** งานฝั่ง Tahoe **กำลังเกิดขึ้นจริง** (มี changelog แก้ black desktop บน macOS 26
และมีการเปลี่ยน SMBIOS สำหรับ Tahoe) แต่ **ยังไม่มีการประกาศรองรับอย่างเป็นทางการ**
ผลจากผู้ใช้จริงยังขัดกันเอง ไม่พบข้อความเรื่อง Tahoe จากบัญชีผู้พัฒนาโดยตรง

---

## 3. ข้อมูลใหม่ที่สำคัญ: SMBIOS บน macOS 26

บอตประกาศระบุว่า **macOS 26 ปฏิเสธ `iMacPro1,1`** จึงต้องย้ายไป **`MacPro7,1`**

กระทบเราโดยตรง เพราะ EFI ปัจจุบันใช้ `MacBookPro16,2` ตามที่ NootedRed ต้องการ
ความขัดแย้ง SMBIOS จึงไม่ได้มีสองทางเลือกอย่างที่เคยบันทึก แต่มีสามค่าที่ต้องประนีประนอม:

| ใคร | ต้องการ |
| --- | --- |
| NootedRed (Vega — ขับจอในตัว) | `MacBookPro16,2` |
| ไดรเวอร์ NVIDIA บน Sequoia | ทดสอบด้วย `iMacPro1,1` |
| ไดรเวอร์ NVIDIA บน Tahoe | `MacPro7,1` (macOS 26 ปฏิเสธ `iMacPro1,1`) |

ยังไม่มีใครรายงานว่ารัน NootedRed กับไดรเวอร์ NVIDIA พร้อมกันบน SMBIOS เดียวได้

---

## 4. การ์ดโน้ตบุ๊กและ muxless — ตรงกับเครื่องเราที่สุด

### 4.1 เครื่องมือของโปรเจกต์เองตอบเรื่อง muxless แล้ว

สมาชิก `coru` (12 ต.ค.) วางข้อความที่ **แอป 1401 แสดงเอง** ว่า:

> การ์ดนี้อยู่ในรายการที่ NVIDIA รองรับ แต่ **ยังไม่ได้ทดสอบกับไดรเวอร์**
> และ **จอในตัวของโน้ตบุ๊กที่ไม่มี MUX จะดำใน macOS ต้องใช้จอนอกที่ต่อกับพอร์ตของการ์ด NVIDIA**

**นี่คือคำตอบจากโปรเจกต์เอง ตรงกับข้อสรุปที่เราวิเคราะห์ไว้** และทำให้ G4 (พอร์ต HDMI
เดินจาก GPU ตัวไหน) กลายเป็น **การทดลองที่ชี้ขาด** ไม่ใช่แค่ข้อมูลประกอบ

### 4.2 หลักฐานว่า Ampere + Ryzen ใช้ได้บน Sequoia

สมาชิก `yarosan` (13 ต.ค.) โพสต์ Geekbench: **RTX 3060 12GB เดสก์ท็อป (GA106)**
บน Ryzen 5 5500 / B550M, macOS 15.8.1, ไดรเวอร์ 1.14.2–1.14.4
→ Metal 56.7k, OpenCL 40.3k

ปิดข้อกังวลเรื่อง "Ampere ไม่เคยถูกทดสอบ" และ "แพลตฟอร์ม AMD ใช้ไม่ได้" **สำหรับ Sequoia**
(หมายเหตุทางการของ 1.14.0 และ 1.14.3 ก็มีการแก้ปัญหากับ Ryzen 7000/8000/9000 ด้วย)

### 4.3 รายงานจาก RTX 3060 Laptop — ฮาร์ดแวร์ใกล้เคียงเรามาก

สมาชิก `Jult` (12 ต.ค.) ระบุว่าใช้ **Ryzen 7 5800H + RTX 3060 Laptop** แล้ว "it works"
โดยต้อง **"Disable the SSDT that disable your GPU"**

- ชุดฮาร์ดแวร์ใกล้เคียง AN515-45 มาก
- ตรงกับที่เราวิเคราะห์ว่าต้องปิด `SSDT-Acer-NoHybGfx`
- **แต่เป็นข้อความสมาชิกคนเดียว ไม่มีรายละเอียดว่าภาพออกทางไหน** และไม่ได้บอกว่า sleep เป็นอย่างไร
- อยู่บน Sequoia ไม่ใช่ Tahoe

---

## 5. ผลต่อเงื่อนไข G1–G4

| รหัส | สถานะใหม่ |
| --- | --- |
| G1 | ยังไม่ได้รัน — ต้องทำบนเครื่องจริง |
| G2 | ยังไม่ได้รัน — ต้องทำบนเครื่องจริง |
| **G3** | **ผ่านบน Sequoia แบบมีเงื่อนไข** — GA106 ยืนยันด้วย Geekbench จริง (เดสก์ท็อป) และมีรายงานจาก RTX 3060 Laptop หนึ่งราย แต่แอป 1401 เองยังระบุว่าการ์ดโน้ตบุ๊กรุ่นนี้ "ยังไม่ได้ทดสอบ" · **ไม่ผ่านบน Tahoe** — ไม่มีการรองรับทางการ |
| **G4** | **ยกระดับเป็นการทดลองชี้ขาด** — เครื่องมือของโปรเจกต์เองระบุว่า muxless ต้องใช้จอนอกที่ต่อกับพอร์ต NVIDIA |

---

## 6. ข้อสรุปเชิงตัดสินใจ

เส้นทาง dGPU **เป็นไปได้จริงบน Sequoia 15.8.1 แต่ไม่ใช่บน Tahoe 26.7.1**
และเงื่อนไขคือ **ต้องมีจอนอกที่เดินตรงจาก RTX** — จอในตัวจะดำ ไม่ใช่ "ช้า" แต่ดำไปเลย

จึงมีสามทาง เลือกก่อนลงแรงต่อ:

1. **อยู่กับ Tahoe 26.7.1 ต่อ** — พักเรื่อง NVIDIA ไว้ รอประกาศทางการ
2. **ทำ candidate แยกคาไว้บน Sequoia 15.8.1** เพื่อการทดลองนี้โดยเฉพาะ ไม่แตะ ESP ที่ใช้งานอยู่
3. **ตรวจ G4 ก่อนตัดสินใจ** — ถ้า HDMI เดินจาก iGPU ทั้งสองทางข้างบนก็ไม่มีประโยชน์ จบเรื่อง

**แนะนำข้อ 3 ก่อน** เพราะถูกที่สุด เร็วที่สุด และตัดคำถามที่เหลือทั้งหมดได้ในครั้งเดียว

---

## อัปเดต 2026-10-13 (รอบที่สอง) — ยืนยันจากแหล่งปฐมภูมิแล้ว

### คำยืนยันตรงตัวจาก release notes v1.14.7

> "This release does not qualify every macOS 15 system or **announce official Tahoe support**."

**นี่คือคำตอบที่ชัดที่สุดเท่าที่จะหาได้** มาจาก release ทางการเอง ไม่ใช่เบาะแสจาก Discord
สถานะ Tahoe = **ไม่รองรับอย่างเป็นทางการ** ณ เวอร์ชันล่าสุด

### ปัญหาที่ยังเปิดอยู่ใน 1.14.7 (จาก release notes)

- high-refresh display switching
- small-BAR surface failures
- Chromium hardware composition
- **sleep/wake failures**

ข้อสุดท้ายกระทบเราโดยตรง เพราะ `SSDT-Acer-NoHybGfx` อาจเป็นตัวที่ทำให้ sleep ทำงานอยู่
ถ้าปิดมันเพื่อให้เห็น dGPU แล้วไปเจอบั๊ก sleep/wake ของไดรเวอร์อีกชั้น จะกลายเป็นสองปัญหาซ้อนกัน

### หลักฐานแรกของการรันบน Tahoe 26.7.1 — เวอร์ชันเดียวกับเราพอดี

สมาชิก `jeff` (13 ต.ค. 08:58) แนบ crash report ระบุ:

| รายการ | ค่า |
| --- | --- |
| macOS | **26.7.1** — build เดียวกับเป้าหมายปัจจุบันของเรา |
| ไดรเวอร์ | 1.14.4 |
| SMBIOS | **MacPro7,1** (สอดคล้องกับที่บอตบอกว่า macOS 26 ปฏิเสธ iMacPro1,1) |
| อาการ | **ค้างทั้งเครื่องเวลาโหลดหนัก** สันนิษฐานว่า `mediaanalysisd` ค้างตอนประมวลผลวิดีโอ |

**ตีความ:** ไดรเวอร์ *รันได้* บน Tahoe 26.7.1 แต่ *ไม่เสถียร* นี่คือข้อมูลที่มีค่าที่สุดในรอบนี้
เพราะเป็น build เดียวกับที่เราใช้ ไม่ใช่การอนุมานข้ามเวอร์ชัน

### มี fork สำหรับ Tahoe โดยเฉพาะ

สมาชิก `jeff` (13 ต.ค. 08:50):

> "you can use nullmoth's official driver as the changes made by highdelay for tahoe to work were
> added into the official driver in release 1.14 or so, **i believe**. though, the official driver is
> only meant for macos 15, so any bugs on tahoe wont be prioritized, and its moreover recommended to
> use the driver by **highdelay** since fixes might be implemented faster."

- fork ของ HighDelay มีลิงก์ปักหมุดไว้ใน #tahoe
- **ยังตรวจสอบจากภายนอกไม่ได้** — ค้นเว็บแล้วไม่พบรีโปนี้ ต้องเอาลิงก์จาก pin ใน Discord มาตรวจเอง
- jeff เขียนเองว่า "i believe" = ไม่ยืนยัน

### ความไม่สอดคล้องของช่องทางประกาศ

ช่อง driver-updates ประกาศล่าสุดแค่ 1.14.6 แต่เว็บทางการและ GitHub มี 1.14.7 แล้ว
→ **อย่าใช้ Discord เป็นแหล่งตรวจเวอร์ชัน** ให้ดูเว็บทางการหรือ GitHub releases เท่านั้น

---

## อัปเดต 2026-10-13 (รอบที่สาม) — รายงานจากโน้ตบุ๊ก Ryzen 5800H สองราย

### ข้อมูลที่เจอ

| ผู้โพสต์ | ฮาร์ดแวร์ | macOS | รายงาน |
| --- | --- | --- | --- |
| `Jult` (#it-boots, กระทู้ "Booted on R7-5800H + RTX 3060 Mobile", 12 ต.ค. 19:43) | Ryzen 7 5800H + **RTX 3060 Laptop** | Sequoia (บริบท ไม่ได้ระบุในกระทู้) | "Everything I do is download the 1401 app and let the app handle the rest. P/s: **Disable the SSDT that disable your GPU**" มีภาพหน้าจอ |
| `parovozilya` (#general, 13 ต.ค. 03:22) | Ryzen 5800H + **RTX 3070 Laptop**, **จอ 144 Hz** | **15.8** บน OpenCore | "running mostly fine, smooth in most stuff, chrome gpu is still glitchy for me tho" |
| `Ben` (#general, 9 ต.ค.) | โน้ตบุ๊ก AMD | **Tahoe** | ใช้ได้ แต่ **APU อย่างเดียว ไม่ใช่ NVIDIA** |
| `kxnnedy` (#bug-reports, 13 ต.ค. 02:52) | Ryzen 7 5700X + RTX 4060 **เดสก์ท็อป** | **Tahoe** | DaVinci Resolve crash — ยังไม่มีใครตอบ |

ค้นคำว่า "3060 Tahoe" → **ไม่พบผลลัพธ์เลย** ยังไม่มีใครรายงาน RTX 3060 บน Tahoe ในเซิร์ฟเวอร์นี้

### คำถามที่สำคัญที่สุดตอนนี้ — ยังไม่มีคำตอบ

`parovozilya` ระบุว่ามี **จอ 144 Hz** และบอกว่า "running mostly fine" บน RTX 3070 Laptop
**จอ 144 Hz บนโน้ตบุ๊กมักหมายถึงจอในตัว** ซึ่งถ้าจริงจะ**ขัดกับข้อความของแอป 1401**
ที่บอกว่าโน้ตบุ๊ก muxless จอในตัวจะดำ

เป็นไปได้สามอย่าง ยังแยกไม่ออกจากข้อมูลที่มี:

1. เขาใช้จอนอกที่ต่อกับพอร์ต NVIDIA (ตรงกับคำเตือนของ 1401)
2. โน้ตบุ๊กของเขามี MUX (บางรุ่นมี) จึงไม่ใช่เคสเดียวกับเรา
3. จอในตัว muxless ใช้ได้จริง และคำเตือนของ 1401 กว้างเกินไป

**ข้อ 3 ถ้าเป็นจริงจะเปลี่ยนทั้งโปรเจกต์** เพราะแปลว่าเส้นทางคัดลอกเฟรมของ Apple
ถูกใช้งานได้จริงกับไดรเวอร์ชุดนี้

เช่นเดียวกับ `Jult` ที่ใช้ RTX 3060 Laptop ตรงรุ่นกับเรา แต่ไม่ได้บอกว่าภาพออกทางไหน

**การกระทำที่ถูกที่สุดตอนนี้คือถามสองคนนี้ตรง ๆ ว่าใช้จอในตัวหรือจอนอก**
ถูกกว่าการทดลองใด ๆ ที่เราทำเองได้ และตอบคำถามหลักของโปรเจกต์ได้ทันที

### ข้อสังเกตเพิ่ม

- `parovozilya` บอกว่า "chrome gpu is still glitchy" บน RTX — **อาการคล้ายกับที่เราเจอกับ NootedRed**
  ใน `GRAPHICS-ISSUE-TH.md` คนละไดรเวอร์แต่อาการใกล้กัน ยังไม่ทราบว่าเกี่ยวข้องกันหรือไม่
- **แก้ข้อมูลเดิม:** ป้าย "CEO" ของ `kxnnedy` เป็นแท็กเซิร์ฟเวอร์ ไม่ใช่ผู้พัฒนา
  รายงานรอบก่อนของเอกสารนี้อาจทำให้เข้าใจผิด — ข้อความของเขานับเป็นสมาชิกทั่วไป
- Tahoe มีคนใช้กับ RTX 40 เดสก์ท็อปแล้ว แต่เจอ crash และยังไม่มีใครตอบ

---

## อัปเดต 2026-10-15 — v2.0.0 รองรับ Tahoe อย่างเป็นทางการแล้ว

ตรวจจาก GitHub releases โดยตรง (แหล่งระดับ 1)

### Releases ตั้งแต่ตรวจครั้งก่อน

| เวอร์ชัน | วันที่ | สาระ |
| --- | --- | --- |
| 1.15.0 | 13 ต.ค. | release สุดท้ายที่เป็นสาย macOS 15 แก้จอดำบนการ์ดที่ไม่มี Resizable BAR, เพิ่ม T-series laptop GPU |
| **2.0.0** | **15 ต.ค.** | **"supports macOS 15 Sequoia and macOS 26 Tahoe"** + security fixes ชุดใหญ่ + แก้ไดรเวอร์หลายจุด |
| 2.0.1 | 15 ต.ค. | 1401 (Windows) ให้เครื่องที่มีการ์ด NVIDIA build Tahoe ได้ ซึ่ง 2.0.0 ยังบล็อกอยู่ |
| 2.0.2 | 15 ต.ค. | แก้ 1401 ฝั่ง Windows เท่านั้น ไดรเวอร์ไม่เปลี่ยน |

ข้อความใน 2.0.0: "Tahoe ships the macOS 26 accelerator built for this release." (1.15 ยังใช้ตัวเก่าที่ทำให้จอดำบน Tahoe)
→ **ปิดคำถามข้อ 2 แล้ว: Tahoe รองรับทางการตั้งแต่ 2.0.0**

### เรื่องที่ตรงกับเครื่องเรา (RTX 3060 Laptop, จอในตัวต่อกับ AMD iGPU)

| หัวข้อ | สิ่งที่ release 2.0.0 บอก | ผลต่อเรา |
| --- | --- | --- |
| โน้ตบุ๊ก | Known issue: "Laptops with the screen on the **Intel** GPU: the built-in screen is not accelerated" | กล่าวถึงแค่โน้ตบุ๊ก Intel ไม่พูดถึง AMD iGPU เลย คาดว่าจอในตัวของเราก็ไม่ได้ acceleration เหมือนกัน (ยังไม่ยืนยัน) |
| muxless | "Muxless Turing GPUs get the startup settle they need" | ระบุเฉพาะ Turing ส่วน RTX 3060 ของเราเป็น Ampere |
| RTX 30 / 3060 | ไม่มีบรรทัดไหนพูดถึง | README ยังบอกว่าทดสอบหลักบน RTX 5060 |
| sleep/wake | ไม่ได้พูดถึง (ครั้งสุดท้ายคือ 1.14.7: "remain open") | ถือว่ายังเป็นปัญหาค้าง |
| SMBIOS | ไม่ได้พูดถึง | README ยังเขียนว่า `iMacPro1,1` และยังไม่ได้อัปเดตเรื่อง Tahoe (ขัดกับ release) ใช้ข้อมูลจาก release เป็นหลัก |
| **ใหม่: AMD/Intel GPU (NMXGPU)** | ฟีเจอร์ทดลอง ปิดไว้เป็นค่าเริ่มต้น: "AMD and Intel GPU support (NMXGPU) and the NPU driver for macOS 15 and 26" | **อาจเป็นทางเลือกแทน NootedRed สำหรับ iGPU Vega ของเรา** แต่ยังไม่รู้ว่ารองรับ Cezanne หรือเปล่า ต้องตรวจต่อ |
| Known issue อื่น | เสียงผ่าน HDMI/DP ยังไม่ทำงาน, eGPU ผ่าน Thunderbolt ไม่มีภาพ, Chrome decode วิดีโอด้วย CPU | — |

### อัปเดตเงื่อนไข G3

**G3 บน Tahoe: จาก "ไม่ผ่าน" เปลี่ยนเป็น "ผ่านในระดับทางการ"** แต่ RTX 3060 Laptop ยังไม่มีผลทดสอบ
ข้อสรุปเรื่องจอยังเหมือนเดิม: จอในตัวที่ต่อกับ iGPU จะไม่ได้ acceleration ต้องใช้จอนอกที่ต่อกับพอร์ตของ NVIDIA
**G4 (พอร์ต HDMI ต่อกับ GPU ตัวไหน) ยังคงเป็นการทดลองชี้ขาด**

### อื่น ๆ บนบัญชี nullmoth

- `1401-probe` (repo ใหม่) — เครื่องมือสแกนฮาร์ดแวร์แบบ offline บน USB อ่านอย่างเดียว ไม่เขียนลงดิสก์
- `docs/MULTI-GPU.md` — เป็นวิธีแก้สำหรับเครื่องที่ใส่ RTX 4090 สี่ใบ ไม่เกี่ยวกับโน้ตบุ๊ก
- `CARD-SUPPORT.md` ที่ root ของ repo ตอนนี้เปิดแล้วได้ 404 (ถูกย้ายหรือเปลี่ยนชื่อ)

### ค้น Discord หาเคสที่คล้ายเครื่องเรา (2026-10-15)

อ่านอย่างเดียว ค้นด้วยคำว่า `3060 laptop`, `nitro`, `muxless`, `muxless amd`, `nootedred`, `5800H`, `internal display`

| ใคร (ระดับแหล่ง) | วันที่ | ข้อความ / ข้อมูล | ผลต่อเรา |
| --- | --- | --- | --- |
| **`nullmoth` (ผู้พัฒนา)** | 12 ต.ค. | "AMD iGPU support is coming but **not with NootedRed** since i cant redistribute his work" | ไดรเวอร์ NVIDIA จะไม่ทำงานคู่กับ NootedRed ส่วน iGPU AMD จะมีไดรเวอร์ของตัวเอง (น่าจะเป็น NMXGPU ใน 2.0.0) |
| `Jult` (สมาชิก) กระทู้ it-boots "Booted on R7-5800H + RTX 3060 Mobile" | 12 / 15 ต.ค. | รูป About This Mac: Ryzen 7 5800H + RTX 3060 Laptop 6 GB บน **Sequoia 15.8.1** ใช้ไดรเวอร์ 1.13 "apps and games is smooth" แต่ "**you need to disable the nootedred kext** after install nullmoth driver" และต้องปิด SSDT ที่ปิด dGPU | ฮาร์ดแวร์ตรงกับเรามากที่สุดเท่าที่เจอ **แต่ไม่ได้บอกว่าภาพออกจอในตัวหรือจอนอก** และไม่ได้บอกว่ามี MUX หรือเปล่า |
| `zaelggk` / repo `aquanjsw/R9000P-2021H-OC-EFI` (สมาชิก + GitHub) | 15 ต.ค. | Legion R9000P 2021H (5800H + 3060 Laptop) บน **Tahoe 26.7.1 + ไดรเวอร์ 2.0.0** จอในตัว 2560×1600@165Hz และ HDMI ใช้ได้ ตอนติดตั้งใช้ hybrid mode แล้วสลับเป็น "**dGPU only mode**" หลังลงไดรเวอร์ | **Legion รุ่นนี้มี MUX** (dGPU-only ทำให้จอในตัวไปต่อกับ RTX) แต่ AN515-45 ไม่มี MUX เลยนำมาใช้ตรง ๆ ไม่ได้ ส่วนที่ยังใช้อ้างอิงได้คือ kext, ACPI และ Tahoe + 2.0.0 บน 5800H |
| `Mido T.` (สมาชิก) | 12 ต.ค. | ถามตรงกับเคสเรา "Does the driver work on muxless amd? (Nvidia on HDMI, AMD iGPU with NootedRed)" | **ยังไม่มีใครตอบ** (คำตอบที่เกี่ยวข้องคือข้อความของ nullmoth ด้านบน) |
| `Batu` (สมาชิก) | 15 ต.ค. | ไม่มี MUX, 3060 ต่อ HDMI, iGPU (Intel) ต่อจอในตัว ถามว่าจอในตัวจะใช้ได้ไหม | ยังไม่มีคำตอบ |
| `azucar` (สมาชิก) | 15 ต.ค. | ถาม nullmoth ว่ามีแผนให้ dGPU ขับจอในตัวของโน้ตบุ๊ก MUXless ไหม | ยังไม่มีคำตอบ |
| `Sealsealy` (Admin) | 15 ต.ค. | "do muxless laptop works now with internal display" | ยังไม่มีคำตอบ และแอดมินเองก็ยังไม่รู้ |
| `ist` (สมาชิก) #tahoe | 15 ต.ค. | "didn't work for me cuz of internal display" | เป็นสัญญาณลบสำหรับโน้ตบุ๊กที่ไม่มี MUX |
| Big Brother (บอต) ประกาศ 2.0 | 15 ต.ค. | changelog มี "correct DPI for your panel, **muxless laptops**" และ "AMD RX 9070 display and **MediaTek Wi-Fi drivers** are now opt-in" | มีไดรเวอร์ **MediaTek Wi-Fi** แบบทดลองแล้ว อาจเกี่ยวกับ MT7921 ของเรา (ยังไม่ได้ตรวจว่ารองรับชิปไหนบ้าง) |

**สรุปจาก Discord:**

1. **ไม่พบใครยืนยันว่าโน้ตบุ๊กที่ไม่มี MUX ใช้จอในตัวผ่าน RTX ได้** แม้แต่แอดมินก็ยังถามอยู่ (15 ต.ค.)
2. เคสที่จอในตัวใช้ได้จริง (Legion R9000P) **มี MUX** ส่วนเคส 5800H + 3060 ของ Jult ไม่ได้บอกว่าภาพออกทางไหน
3. **ลงไดรเวอร์ NVIDIA แล้วต้องปิด NootedRed** (ทั้ง Jult และ nullmoth พูดตรงกัน) แปลว่าบนเครื่องที่ไม่มี MUX จอในตัว (ต่อกับ iGPU) จะไม่มีไดรเวอร์เร่งความเร็ว
4. ทางที่เป็นไปได้สำหรับ AN515-45 ยังเหมือนเดิม: ใช้จอนอกที่ต่อกับพอร์ต NVIDIA (ต้องตรวจ G4 ก่อน) หรือรอไดรเวอร์ iGPU AMD (NMXGPU) ที่ใช้คู่กันได้

### G4 ตอบแล้วจาก Windows (2026-10-15) — ใช้วิธีเดียวกับที่ 1401 ใช้

1401 (`panel_guard.py`, `nullmoth.mux_help`) ดูจาก Windows ว่าจอไหนต่อกับ GPU ตัวไหน ตรวจแบบเดียวกันบนเครื่องนี้ (อ่านอย่างเดียว, `Get-PnpDevice -Class Monitor` + `DEVPKEY_Device_Parent`):

| จอ | GPU ที่ขับ |
| --- | --- |
| Integrated Monitor (แผง CMN1521, internal) | **AMD Radeon (1002:1638, Cezanne iGPU)** → ยืนยันว่า muxless |
| Generic Monitor (SAMSUNG) — จอนอกที่เคยเสียบ | **NVIDIA RTX 3060 Laptop (10DE:2520)** |

→ **พอร์ตที่เคยเสียบจอ Samsung เดินตรงจาก RTX 3060** — ผู้ใช้ยืนยันว่าเป็น**พอร์ต HDMI** (2026-10-15) → **HDMI ต่อตรงกับ RTX 3060**
เส้นทาง NVIDIA บน macOS จึงเป็นไปได้ผ่านจอนอกที่พอร์ตนั้น

### สิ่งที่อยู่ในแพ็กเกจ 1401 2.0.2 (โฟลเดอร์ `1401/` ที่ root, ไม่เข้า git)

- `NullMoth/nullmoth-nvidia-2.0.2.tar.gz`: ไดรเวอร์ NVIDIA + **NMXGPU 1.0.0** แยกรุ่น macOS 15 และ 26; NMXGPU จับคู่อุปกรณ์ AMD ทุกตัว (`0x00001002&0x0000ffff`) และ Intel ทุกตัว — **ยังไม่รู้ว่ารองรับ Cezanne จริงหรือไม่** (ตัดสินในโค้ด)
- `amd_gpu.py`: จัด 1002:1638 เป็น "Cezanne (Vega iGPU)" ใช้ firmware framebuffer, ไม่รวม NootedRed (ติดเรื่องสัญญาอนุญาต)
- `engine.py`: หมายเหตุว่า build NVIDIA 15 ชุดบน Ryzen 4800H/5800H/5600H เคยลง Ventura/Sonoma ซึ่งไดรเวอร์ไม่โหลด
- `known_machines.json`: มีแค่ 2 เครื่อง (เดสก์ท็อป) ไม่มีโน้ตบุ๊ก

---

## แหล่งอ้างอิง

- https://github.com/aquanjsw/R9000P-2021H-OC-EFI (tahoe branch) — ตรวจ 2026-10-15
- Discord NullMoth Systems ช่อง general, it-boots, nvidia-driver-laptop-help-1, tahoe, driver-updates — อ่านผ่านแอป Discord 2026-10-15
- https://github.com/nullmoth/nvidia-macos-driver/releases/tag/v2.0.0 — ตรวจ 2026-10-15 (รองรับ Tahoe, known issues)
- https://github.com/nullmoth/nvidia-macos-driver/releases — v1.15.0, v2.0.1, v2.0.2

- https://nullmothsystems.com/downloads — ตรวจ 2026-10-13 (1.14.7, Sequoia เท่านั้น)
- https://github.com/nullmoth/nvidia-macos-driver/releases/tag/v1.14.7 — release notes ระบุว่าไม่ประกาศรองรับ Tahoe
- https://github.com/nullmoth/nvidia-macos-driver — README และ `CARD-SUPPORT.md`
- Discord ของ NullMoth Systems: ช่อง start-here, driver-updates, #tahoe, bug-reports,
  it-boots, nvidia-driver-help, 1401-laptop-help — อ่านผ่านส่วนขยายเบราว์เซอร์ 2026-10-13

ข้อความใน Discord เป็น **เบาะแส** ทุกข้อที่จะนำไปใช้ตัดสินใจแก้ EFI ต้องยืนยันกับ
หน้าเว็บทางการ README หรือ release ก่อน การค้นครั้งนี้อ่านไม่ครบ (คำว่า Tahoe มี 935 ผลลัพธ์
อ่านเฉพาะหน้าแรก) และไม่ได้กรองเฉพาะข้อความของผู้พัฒนา
