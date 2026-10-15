# ลบ Tahoe แล้วติดตั้ง macOS Sequoia 15.8.1 แทน — Acer Nitro 5 AN515-45

เขียน 2026-10-15 · เอกสารนี้อ่านจบในตัว ใช้คุยต่อกับผู้ช่วยคนอื่นได้ (ไม่มี serial/UUID)

## บริบทเครื่อง

| รายการ | ค่า |
| --- | --- |
| เครื่อง | Acer Nitro 5 AN515-45-R375 |
| CPU / iGPU | Ryzen 7 5800H / Radeon Vega (Cezanne, 1002:1638) — ขับจอในตัว |
| dGPU | RTX 3060 Laptop — ปิดใน macOS ด้วย SSDT (ไม่มี MUX, พอร์ต HDMI ต่อกับ RTX) |
| ดิสก์ติดตั้ง | Apacer AS2280P4 512 GB (NVMe) — dual-boot กับ Windows |
| Micron 2200V | ต้อง**ถอดออก** (ใส่ไว้ macOS จะ panic) |
| Bootloader | OpenCore 1.0.8 DEBUG บน USB KINGSTON 60 GB, SMBIOS MacBookPro16,2 |
| Secure Boot | ต้อง Disabled ใน BIOS |

## สถานะตอนเริ่ม

Apacer มี 5 partition:

| # | ชนิด | ขนาด (macOS นับฐาน 10) | หมายเหตุ |
| --- | --- | --- | --- |
| 1 | EFI | 209.7 MB | ESP ของ Windows (ไม่มี OpenCore) |
| 2 | Microsoft Reserved | 16.8 MB | |
| 3 | Microsoft Basic Data | 236.1 GB | **C: ของ Windows — ห้ามแตะ** |
| 4 | Apple_APFS Container | 274.9 GB (256 GiB) | **Tahoe 26 ที่ติดตั้งไว้ — จะลบ** |
| 5 | Windows Recovery | 886.0 MB | ห้ามแตะ |

USB KINGSTON (เตรียมและตรวจแล้ว):

| Partition | เนื้อหา |
| --- | --- |
| OPENCORE (FAT32 2 GB) | `EFI` = ชุดติดตั้ง Sequoia (NootedRed **ปิด**, AppleALC เปิด, PlatformInfo จริง) · `com.apple.recovery.boot` = Recovery 15.4.1 · `EFI.tahoe-bak` = ชุด Tahoe สำรอง |
| UnPlugged (exFAT ~54 GB) | `InstallAssistant.pkg` = Sequoia 15.8.1 (24H32) ขนาด 15,664,523,626 bytes ตรวจ SHA256 แล้ว · `UnPlugged.command` · `Tahoe-26.7.1-25G241.pkg.old` (ไม่ใช้) |

เส้นทางนี้ (Recovery 15.4.1 + UnPlugged) เคยติดตั้ง Sequoia บนเครื่องนี้สำเร็จเมื่อ 2026-10-09

## กฎความปลอดภัย

- ⚠️ **ห้าม Erase ดิสก์ทั้งลูก** ใน Disk Utility — Apacer มี Windows อยู่
- ⚠️ **เลข `diskN` เปลี่ยนได้ทุกครั้งที่บูต** — ใช้ค่าจากจอรอบนั้นเสมอ
- ⚠️ **ก่อนรันคำสั่งที่เขียนดิสก์ (`eraseVolume`) ต้องถ่ายรูป `diskutil list physical` ให้คนตรวจตัวระบุก่อน**
- ทุกอย่างใน Tahoe จะหาย — สำรองข้อมูลก่อนถ้ามี

---

## ขั้นที่ 1 — บูต Recovery จาก USB

1. Shut down (ไม่ใช่ Restart) → ตรวจว่า**ถอด Micron 2200V แล้ว** → เสียบ USB KINGSTON
   - ถ้ายังไม่แน่ใจเรื่อง Secure Boot: เปิดเครื่องกด **F2** ตรวจว่า Disabled แล้ว Save & Exit
2. เปิดเครื่อง กด **F12** → **USB HDD: KINGSTON**
3. ในหน้า OpenCore กด **Space** ให้รายการที่ซ่อนขึ้น → เลือก Recovery (`macOS Base System` / 15.4.1) → Enter
   - **อย่าเลือก `Macintosh HD`** (นั่นคือ Tahoe)
4. ข้อความ verbose วิ่ง 1–3 นาทีเป็นปกติ (เปิด `-v` ไว้)
   - ค้าง > 5 นาที / รีบูตเอง / panic → ถ่ายรูปบรรทัดล่างสุด แล้วหยุด
5. เลือกภาษา → หน้า macOS Utilities (ภาพช้า ไม่มี acceleration เป็นเรื่องปกติ)

## ขั้นที่ 2 — ดูดิสก์ (อ่านอย่างเดียว)

**Utilities → Terminal**

```bash
diskutil list physical
```

Apacer ควรออกมาประมาณนี้ (เลข X, Y ใช้ของจริงจากจอ):

```text
/dev/diskX (internal, physical):
   1: EFI                     EFI            209.7 MB   diskXs1
   2: Microsoft Reserved                     16.8 MB    diskXs2
   3: Microsoft Basic Data                   236.1 GB   diskXs3   ← C:
   4: Apple_APFS Container diskY             274.9 GB   diskXs4   ← Tahoe
   5: Windows Recovery                       886.0 MB   diskXs5
```

📸 **ถ่ายรูปทุกดิสก์ส่งให้ตรวจก่อน** ต้องยืนยัน 3 อย่าง:

1. **container ของ Tahoe** = `diskY` ที่อยู่ในบรรทัด `Apple_APFS Container diskY` ของ partition 4 บน Apacer
   - partition นั้นต้องอยู่**หลัง** Microsoft Basic Data 236.1 GB และ**ก่อน** Windows Recovery 886 MB
2. **C:** = ตัวระบุของ `Microsoft Basic Data` 236.1 GB เช่น `disk2s3`
3. ตัวระบุของ partition **UnPlugged** บน USB (บรรทัด exFAT/`Windows_NTFS UnPlugged` ~57.9 GB) เช่น `disk4s2`

## ขั้นที่ 3 — ลบ Tahoe แล้วสร้าง Macintosh HD ใหม่ (เขียนดิสก์ — ทำหลังยืนยันตัวระบุแล้วเท่านั้น)

ใช้ 2 คำสั่ง: ลบ container ของ Tahoe ให้เป็นพื้นที่ว่าง แล้วสร้าง APFS ใหม่ด้วย**คำสั่งเดียวกับที่ใช้สำเร็จเมื่อ 2026-10-09**
(ไม่ใช้ `diskutil eraseVolume` กับ `diskXs4` เพราะ partition นั้นเป็น physical store ของ APFS container และยังไม่ได้ตรวจกับเอกสารว่า `diskutil` ใน Recovery 15.4.1 จัดการกรณีนี้อย่างไร)

**3.1** ลบ container ของ Tahoe — แทน `diskY` ด้วยค่าจากข้อ 2.1 (เป็น `diskY` เลขเดียว **ไม่มี** `sN` ต่อท้าย):

```bash
diskutil apfs deleteContainer diskY
```

ตรวจ (ยังไม่สร้างอะไร):

```bash
diskutil list physical
```

ต้องเห็น Apacer เหลือ EFI, Microsoft Reserved, C: 236.1 GB, Windows Recovery และ **ไม่มี** `Apple_APFS Container` แล้ว (พื้นที่ ~256 GiB ระหว่าง C: กับ Windows Recovery ว่าง)
📸 ถ่ายรูปส่งตรวจอีกครั้ง — ถ้าเห็นเป็น partition อื่นโผล่ขึ้นมาแทน (เช่น `Apple_HFS Untitled`) หรือ C: เปลี่ยน → หยุด

**3.2** สร้าง APFS ต่อท้าย C: — แทน `diskXs3` ด้วยค่าจากข้อ 2.2 (`0` = ใช้ช่องว่างทั้งหมดหลัง C:):

```bash
diskutil addPartition diskXs3 APFS "Macintosh HD" 0
```

- คำสั่งนี้ไม่แตะข้อมูลใน C: แค่ใช้ช่องว่างหลังมัน
- ไม่แตะ EFI, Windows Recovery
- **ห้ามใช้ `diskutil eraseDisk`** (นั่นคือลบทั้งดิสก์)

ตรวจ:

```bash
diskutil list physical
```

ต้องเห็น `Apple_APFS Container diskZ` ~274.9 GB อยู่ระหว่าง C: กับ Windows Recovery, C: ยัง 236.1 GB, และมี volume `Macintosh HD` ใน `diskZ` (ไม่มี volume ของ Tahoe เหลือ)

## ขั้นที่ 4 — Mount USB

แทน `diskNsM` ด้วยตัวระบุ UnPlugged จากข้อ 2.3 (Recovery ไม่มีคำสั่ง `clear`):

```bash
mkdir -p /Volumes/UnPlugged
```

```bash
/sbin/mount_exfat /dev/diskNsM /Volumes/UnPlugged
```

```bash
cd /Volumes/UnPlugged
```

```bash
ls
```

ต้องเห็น `InstallAssistant.pkg` และ `UnPlugged.command` — ถ้าขึ้น `No such file or directory` = ตัวระบุผิด กลับไปดูขั้นที่ 2

## ขั้นที่ 5 — รัน UnPlugged

```bash
bash UnPlugged.command
```

| คำถาม | ตอบ |
| --- | --- |
| `Could not extract required info from InstallAssistant.pkg` | ปกติบน Recovery 15.4.1 → ดำเนินการต่อ |
| approach | **1** — Fully expand InstallAssistant.pkg (ห้ามใช้ตัวติดตั้ง 15.4.1 ใน Recovery) |
| volume ที่จะติดตั้ง | **Macintosh HD** เท่านั้น (ห้าม UnPlugged / OPENCORE) |
| copy approach | **2** — Copy (cp) (ไม่ใช้ symlink เพราะหลังรีบูต USB exFAT ไม่ถูก mount) |
| สรุปงาน | ตรวจว่าเป็น `/Volumes/Macintosh HD` แล้วพิมพ์ `y` |

รอ expand + copy หลายนาที → ตัวติดตั้งเปิดเอง (**อย่าปิด Terminal**) → Continue → Agree → **Macintosh HD** → Continue

## ขั้นที่ 6 — รีบูตระหว่างติดตั้ง (หลายรอบ)

ทุกครั้งที่รีบูต: **F12** → USB KINGSTON → **macOS Installer**
เมื่อ `macOS Installer` หายไป เหลือ `Macintosh HD` → เลือก `Macintosh HD`
วนเกิน 3 รอบไม่คืบหน้า → ถ่ายรูป/วิดีโอช่วงก่อนรีบูต แล้วหยุด

## ขั้นที่ 7 — Setup Assistant

ข้าม Apple ID ไปก่อน · Keyboard Setup Assistant ขึ้นเป็นปกติ · UI ช้าเพราะ NootedRed ปิด — ปกติ
**ถึง desktop = ติดตั้งสำเร็จ**

## ขั้นที่ 8 — หลังติดตั้ง (ทำกับผู้ช่วยในเครื่อง Windows)

1. เปลี่ยน EFI บน USB เป็นชุด Sequoia ที่เปิด NootedRed (`private-build/candidate-v10` ในโปรเจกต์) → บูตจาก USB ให้ภาพลื่น
2. ยืนยัน Windows ยังบูตได้ (ถอด USB → F12 → Windows Boot Manager)
3. ลง OpenCore ลง ESP ของ Apacer ด้วย `tools/Install-OpenCore-ESP.ps1 -Source <private-build ชุดนั้น>\EFI\OC` (แบ็กอัป ESP ก่อนเขียน, ไม่แตะไฟล์ Windows)

## ถ้าไม่ผ่าน

| อาการ | ทำอย่างไร |
| --- | --- |
| Recovery ค้าง / panic | ถ่ายรูปบรรทัดสุดท้าย อย่าแก้ config เอง |
| `mount_exfat` ไม่ได้ | ตรวจตัวระบุ UnPlugged ใหม่ด้วย `diskutil list` |
| ไม่แน่ใจตัวระบุดิสก์ | หยุด ถ่ายรูปถามก่อน |
| `deleteContainer` ขึ้น error | หยุด ถ่ายรูป error + `diskutil list physical` ห้ามลองคำสั่ง erase อื่นเอง |
| อยากกลับ Windows | ถอด USB → F12 → Windows Boot Manager (ได้ทุกเมื่อ) |
| Windows บูตไม่ขึ้น | ไฟล์บน C: ไม่หาย ซ่อม bootloader ด้วย `bcdboot` จาก Windows Recovery |
