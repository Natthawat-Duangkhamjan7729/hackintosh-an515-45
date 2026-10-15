# ติดตั้ง macOS Tahoe 26.7.1 (รอบ 2026-10-15)

ทำซ้ำเส้นทางที่เคยติดตั้ง Tahoe สำเร็จเมื่อ 2026-10-12 (Recovery 15.4.1 + UnPlugged, บันทึกใน `PROGRESS-2026-10-09.md`)
แล้วใช้ `candidate-tahoe10` ซึ่งเป็นชุดที่บูต Tahoe จาก Apacer ได้จริง

> ⚠️ **ห้าม Erase ดิสก์ทั้งลูกใน Disk Utility เด็ดขาด** — Apacer มี Windows อยู่ การ Erase ทั้งลูกจะลบ Windows ทั้งหมด
> ⚠️ **หมายเลขดิสก์ (`diskN`) เปลี่ยนได้ทุกครั้งที่บูต** — ใช้ค่าที่เห็นบนจอรอบนั้นเสมอ ถ้าไม่แน่ใจ ถ่ายรูปส่งมาก่อนรันคำสั่งที่เขียนดิสก์

## สถานะ USB KINGSTON (เตรียมและตรวจแล้ว 2026-10-15)

| Partition | เนื้อหา | ตรวจ |
| --- | --- | --- |
| E: `OPENCORE` (FAT32) | `EFI` = `private-build/candidate-tahoe10-install` — tahoe10 + **NootedRed ปิด** (ช่วงติดตั้ง), PlatformInfo จริง | ocvalidate 1.0.8 ผ่าน, `diff -rq` ตรง |
| E: | `EFI.sequoia-bak` = ชุดติดตั้ง Sequoia เดิม (`private-build/sequoia-install`) | เก็บไว้เฉย ๆ firmware ไม่ใช้ |
| E: | `com.apple.recovery.boot` = Recovery 15.4.1 | ตัวเดิมที่เคยใช้ติดตั้ง Tahoe ได้ |
| F: `UnPlugged` (exFAT) | `InstallAssistant.pkg` = **Tahoe 26.7.1 (25G241)** 18,380,974,544 bytes | ขนาดตรง catalog; SHA256 ดูใน PROGRESS |
| F: | `Sequoia-15.8.1-24H32.pkg.old` | เปลี่ยนชื่อไว้ไม่ให้ UnPlugged หยิบผิด |
| F: | `UnPlugged.command` | ตัวเดิม |

ชุดหลังติดตั้ง (NootedRed เปิด): `private-build/candidate-tahoe10` — ต่างจากชุดติดตั้งแค่ `NootedRed Enabled`

---

## ขั้นที่ 1 — ย่อ C: ใน Windows (ทำครั้งเดียว)

1. BitLocker ต้องปิดอยู่ (Settings → Privacy & security → Device encryption) — รอบก่อนปิดไว้แล้ว
2. คลิกขวาปุ่ม Start → **Terminal (Admin)**
3. วางคำสั่งนี้ (C: จะเหลือ 219.9 GiB และมีพื้นที่ว่าง ~256 GiB ต่อท้าย):
   ```powershell
   try { $t = 236118663168; $s = Get-PartitionSupportedSize -DriveLetter C -ErrorAction Stop; if ($t -lt $s.SizeMin) { "ย่อไม่ได้: C: ต้องเหลืออย่างน้อย {0:N1} GB" -f ($s.SizeMin/1GB) } else { Resize-Partition -DriveLetter C -Size $t -ErrorAction Stop; $n = (Get-Partition -DriveLetter C).Size; if ($n -eq $t) { "OK: C: = {0:N0} bytes" -f $n } else { "ไม่สำเร็จ: C: = {0:N0} bytes" -f $n } } } catch { "ERROR: $($_.Exception.Message)" }
   ```
   (คำสั่งเวอร์ชันเดิมพิมพ์ `OK` ได้แม้จะย่อไม่สำเร็จ เช่น ตอนไม่ได้เปิดแบบ Admin — แก้แล้ว 2026-10-15)
4. ขึ้น `OK: C: = 236,118,663,168 bytes` = สำเร็จ **ไม่ต้องสร้าง partition ใน Windows** ปล่อยเป็น Unallocated
   - ขึ้น `ERROR: ... Access ... denied` หรือ `not available` = ไม่ได้เปิด Terminal แบบ Admin
   - หลังย่อ C: จะเหลือที่ว่างประมาณ 10 GB เท่านั้น (ใช้อยู่ ~209 GiB)
   - ถ้าขึ้น "ย่อไม่ได้" → ส่งข้อความมา (มักเกิดจาก pagefile/hiberfil ขวางอยู่)
5. บอกผมว่าเสร็จแล้ว ผมจะตรวจ layout ให้

## ขั้นที่ 2 — เตรียมเครื่อง

1. Shut down (ไม่ใช่ Restart) — Micron 2200V ต้อง**ไม่ได้ใส่อยู่** (ใส่ไว้จะ panic)
2. เสียบ USB KINGSTON
3. BIOS (F2): **Secure Boot = Disabled**, F12 Boot Menu = Enabled

## ขั้นที่ 3 — บูต Recovery จาก USB

1. เปิดเครื่อง กด **F12** → **USB HDD: KINGSTON**
2. OpenCore picker → **กด Space** ให้รายการที่ซ่อนขึ้น → เลือก Recovery (`macOS Base System` 15.4.1) → Enter
3. ข้อความ verbose วิ่ง (ปกติ) รอ 1–3 นาที
   - ค้าง > 5 นาที / รีบูตเอง / panic → **ถ่ายรูปบรรทัดล่างสุด** แล้วหยุด
4. เลือกภาษา → หน้า macOS Utilities (ภาพช้าเป็นเรื่องปกติ)

## ขั้นที่ 4 — สร้าง APFS "Macintosh HD"

1. **Utilities → Terminal** แล้วรัน `diskutil list physical`
2. หา **Apacer (512.1 GB)** ควรเห็น:
   ```
   /dev/diskX (internal, physical):
      1: EFI                     EFI           209.7 MB   diskXs1
      2: Microsoft Reserved                    16.8 MB    diskXs2
      3: Microsoft Basic Data                  236.1 GB   diskXs3   ← C:
      4: Windows Recovery                      886.0 MB   diskXs4
   ```
   **ถ่ายรูปส่งมาก่อน** เพื่อยืนยันตัวเลข X
3. แทน `diskXs3` ด้วยตัวระบุของ C: (Microsoft Basic Data 236.1 GB):
   ```
   diskutil addPartition diskXs3 APFS "Macintosh HD" 0
   ```
   ไม่แตะข้อมูลใน C: — ใช้แค่ช่องว่างหลังมัน
4. `diskutil list physical` อีกครั้ง: ต้องเห็น `Apple_APFS Container` ~274.9 GB อยู่ระหว่าง C: กับ Windows Recovery

## ขั้นที่ 5 — Mount USB และรัน UnPlugged

1. หา partition `UnPlugged` ของ USB ใน `diskutil list` (เช่น `disk4s2`)
2. รัน (แทน `diskNsM`):
   ```
   mkdir -p /Volumes/UnPlugged
   /sbin/mount_exfat /dev/diskNsM /Volumes/UnPlugged
   cd /Volumes/UnPlugged
   ls
   ```
   ต้องเห็น `InstallAssistant.pkg` และ `UnPlugged.command`
3. `bash UnPlugged.command` แล้วตอบ:
   | คำถาม | ตอบ |
   | --- | --- |
   | `Could not extract required info from InstallAssistant.pkg` | ปกติบน Recovery 15.4.1 → **ดำเนินการต่อ** |
   | approach | **1 — Fully expand InstallAssistant.pkg** |
   | volume ที่จะติดตั้ง | **Macintosh HD** เท่านั้น |
   | copy approach | **2 — Copy (cp)** |
   | สรุปงาน → ยืนยัน | ตรวจว่าเป็น `/Volumes/Macintosh HD` แล้วพิมพ์ `y` |
4. รอ expand + copy แล้วตัวติดตั้งเปิดเอง → Continue → Agree → **Macintosh HD** → Continue

## ขั้นที่ 6 — รีบูตระหว่างติดตั้ง (หลายรอบ)

ทุกครั้งที่รีบูต: **F12** → USB KINGSTON → **macOS Installer**
เมื่อ macOS Installer หายไป เหลือ `Macintosh HD` → เลือก `Macintosh HD`
วนเกิน 3 รอบไม่คืบหน้า → ถ่ายรูปช่วงก่อนรีบูต แล้วหยุด

## ขั้นที่ 7 — Setup Assistant

ข้าม Apple ID ไปก่อน, Keyboard Setup Assistant ขึ้นเป็นปกติ
**UI จะหน่วงมาก** (NootedRed ปิด — รอบ 10-12 ก็เป็นแบบนี้) ค่อย ๆ คลิกให้ผ่านไปถึง desktop
**ถึง desktop = ติดตั้งสำเร็จ** บอกผมได้เลย

## ขั้นที่ 8 — เปิดกราฟิกและย้าย OpenCore ไป Apacer (ผมช่วยทำ)

1. เปลี่ยน config บน USB เป็น `candidate-tahoe10` (NootedRed เปิด) → บูตจาก USB อีกครั้ง ภาพควรลื่น
2. ยืนยัน Windows ยังบูตได้ (ถอด USB → F12 → Windows Boot Manager)
3. ลง tahoe10 ลง ESP ของ Apacer จาก Windows (Admin):
   ```
   powershell -ExecutionPolicy Bypass -File "D:\Hackintosh\machines\AN515-45\tools\Install-OpenCore-ESP.ps1" -Source "D:\Hackintosh\machines\AN515-45\private-build\candidate-tahoe10\EFI\OC" -WhatIf
   ```
   ผ่านแล้วค่อยรันซ้ำโดยไม่มี `-WhatIf`

## ถ้าไม่ผ่าน

- **Recovery ค้าง/panic** → ถ่ายรูปบรรทัดสุดท้าย อย่าแก้ config เอง
- **กลับ Windows ได้ทุกเมื่อ**: ถอด USB → F12 → Windows Boot Manager
- **กลับไปใช้ชุด Sequoia บน USB**: เปลี่ยนชื่อ `E:\EFI` ↔ `E:\EFI.sequoia-bak` และ `F:\InstallAssistant.pkg` ↔ `Sequoia-15.8.1-24H32.pkg.old`
