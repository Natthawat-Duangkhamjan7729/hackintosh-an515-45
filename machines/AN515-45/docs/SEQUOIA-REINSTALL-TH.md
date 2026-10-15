# ติดตั้ง macOS Sequoia 15.8.1 ใหม่ (รอบ 2026-10-14)

คู่มือนี้ทำซ้ำเส้นทางที่เคยติดตั้งสำเร็จเมื่อ 2026-10-09 (บันทึกใน `PROGRESS-2026-10-09.md`) โดยแก้จุดที่เคยติดไว้ล่วงหน้าแล้ว

> ⚠️ **ห้าม Erase ดิสก์ทั้งลูกใน Disk Utility เด็ดขาด** — Apacer มี Windows อยู่ การ Erase ทั้งลูกจะลบ Windows ทั้งหมด
> ⚠️ **หมายเลขดิสก์ (`diskN`) เปลี่ยนได้ทุกครั้งที่บูต** — ใช้ค่าที่เห็นบนจอรอบนั้นเสมอ ถ้าไม่แน่ใจ ถ่ายรูปส่งมาก่อนรันคำสั่งที่เขียนดิสก์

## สถานะ USB KINGSTON (เตรียมและตรวจแล้ว)

| Partition | เนื้อหา | ตรวจ |
| --- | --- | --- |
| E: `OPENCORE` (FAT32) | `EFI` = `private-build/sequoia-install` — ชุดที่บูต Sequoia ได้จริง, PlatformInfo จริง, **NootedRed ปิด** (ช่วงติดตั้ง), `SecureBootModel=Disabled` | ocvalidate 1.0.8 ผ่าน, `diff -rq` ตรง |
| E: | `com.apple.recovery.boot` = Recovery 15.4.1 | `cmp` ตรงทุกไบต์ |
| F: `UnPlugged` (exFAT) | `InstallAssistant.pkg` 15.8.1 (24H32) | SHA256 `E4532E33…E44781` ตรง |
| F: | `UnPlugged.command` | `cmp` ตรง |
| F: | `Tahoe-26.7.1-25G241.pkg.old` | เปลี่ยนชื่อไว้เพื่อไม่ให้ UnPlugged หยิบผิด ไม่ต้องสนใจ |

ของเดิมบน USB (EFI Tahoe, OpenCore logs) เก็บไว้ที่ `private-build/usb-backup-2026-10-14/`

---

## ขั้นที่ 1 — ย่อ C: ใน Windows (ทำครั้งเดียว)

1. ปิด BitLocker ถ้าเปิดอยู่ (Settings → Privacy & security → Device encryption) — รอบก่อนปิดไว้แล้ว
2. คลิกขวาปุ่ม Start → **Terminal (Admin)** หรือ **Windows PowerShell (Admin)**
3. วางคำสั่งนี้ (C: จะเหลือ 236.1 GB และมีพื้นที่ว่าง 256 GiB ต่อท้าย):
   ```powershell
   $s = Get-PartitionSupportedSize -DriveLetter C; $t = 236118663168; if ($t -lt $s.SizeMin) { "ย่อไม่ได้: C: ต้องเหลืออย่างน้อย {0:N1} GB" -f ($s.SizeMin/1GB) } else { Resize-Partition -DriveLetter C -Size $t; "OK" }
   ```
4. ขึ้น `OK` = สำเร็จ **ไม่ต้องสร้าง partition ใน Windows** ปล่อยเป็น Unallocated
   - ถ้าขึ้น "ย่อไม่ได้" → ส่งข้อความมา (มักเกิดจาก pagefile/hiberfil ขวางอยู่ แก้ได้ด้วยการปิด pagefile ชั่วคราว + `powercfg /h off` แล้วรีสตาร์ต)
5. บอกผมว่าเสร็จแล้ว ผมจะตรวจ layout ให้ว่ามีช่องว่าง ~256 GiB อยู่ระหว่าง C: กับ Windows Recovery

## ขั้นที่ 2 — เตรียมเครื่อง

1. Shut down (ไม่ใช่ Restart) แล้ว**ถอด Micron 2200V ออก** (ใส่ไว้จะ panic ที่ ~75 วินาที)
2. เสียบ USB KINGSTON
3. เปิดเครื่อง กด **F2** เข้า BIOS ตรวจว่า **Secure Boot = Disabled** แล้ว Save & Exit
   (ถ้าเมนู F12 ไม่ขึ้น ต้องเปิด F12 Boot Menu ใน BIOS ด้วย)

## ขั้นที่ 3 — บูต Recovery จาก USB

1. เปิดเครื่อง กด **F12** รัว ๆ → เลือก **USB HDD: KINGSTON**
2. จะเห็นหน้า OpenCore picker (มีเวลา 5 วินาที — กดลูกศรเพื่อหยุดนับ)
3. **กด Space bar** เพื่อแสดงรายการที่ซ่อนอยู่ จะมีรายการ Recovery (`macOS Base System` / Recovery 15.4.1 dmg) → เลือก แล้ว Enter
4. หน้าจอจะเป็นข้อความ verbose วิ่ง (ปกติ เพราะเปิด `-v`) รอ 1–3 นาที
   - ถ้าค้างนาน > 5 นาที, รีบูตเอง หรือขึ้น panic → **ถ่ายรูปบรรทัดล่างสุด** แล้วหยุด
5. เลือกภาษา → ถึงหน้า macOS Utilities (ภาพช้า/ไม่มี acceleration เป็นเรื่องปกติ ทัชแพดใช้ได้)

## ขั้นที่ 4 — สร้าง APFS "Macintosh HD" ในพื้นที่ว่าง

1. เมนูบน **Utilities → Terminal**
2. ดูดิสก์ (อ่านอย่างเดียว):
   ```
   diskutil list physical
   ```
3. หา **Apacer (512.1 GB)** ควรเห็นประมาณ:
   ```
   /dev/diskX (internal, physical):
      1: EFI                     EFI           209.7 MB   diskXs1
      2: Microsoft Reserved                    16.8 MB    diskXs2
      3: Microsoft Basic Data                  236.1 GB   diskXs3   ← C:
      4: Windows Recovery                      886.0 MB   diskXs4
   ```
   **ถ่ายรูปส่งมาก่อน** เพื่อยืนยันตัวเลข X (รอบก่อน Apacer เป็น disk1 แล้วกลายเป็น disk2)
4. สร้าง APFS ต่อท้าย C: ให้เต็มพื้นที่ว่าง (`0` = ใช้ช่องว่างทั้งหมดหลัง partition นั้น) — แทน `diskXs3` ด้วยตัวระบุของ **C: (Microsoft Basic Data 236.1 GB)** จากข้อ 3:
   ```
   diskutil addPartition diskXs3 APFS "Macintosh HD" 0
   ```
   คำสั่งนี้ไม่แตะข้อมูลใน C: — แค่ใช้ช่องว่างหลังมัน
5. ตรวจ:
   ```
   diskutil list physical
   ```
   ต้องเห็น `Apple_APFS Container diskY 274.9 GB` อยู่ระหว่าง C: กับ Windows Recovery, C: ยัง 236.1 GB, และมี volume `Macintosh HD` ใน `diskY`

## ขั้นที่ 5 — Mount USB และรัน UnPlugged

1. หา partition `UnPlugged` ของ USB ใน `diskutil list` (บรรทัด `Windows_NTFS UnPlugged 57.9 GB` → ตัวระบุ เช่น `disk4s2`)
2. รัน (แทน `diskNsM` ด้วยตัวระบุที่เห็น; Recovery ไม่มีคำสั่ง `clear`):
   ```
   mkdir -p /Volumes/UnPlugged
   /sbin/mount_exfat /dev/diskNsM /Volumes/UnPlugged
   cd /Volumes/UnPlugged
   ls
   ```
   ต้องเห็น `InstallAssistant.pkg` และ `UnPlugged.command` (ถ้าขึ้น `No such file or directory` = ตัวระบุผิด)
3. รัน:
   ```
   bash UnPlugged.command
   ```
4. ตอบคำถาม (เหมือนรอบที่สำเร็จ):
   | คำถาม | ตอบ |
   | --- | --- |
   | `Could not extract required info from InstallAssistant.pkg` | ปกติบน Recovery 15.4.1 (pkg ตรวจ SHA256 แล้ว) → **ดำเนินการต่อ** |
   | approach | **1 — Fully expand InstallAssistant.pkg** (ห้ามเลือกตัวติดตั้ง 15.4.1 ใน Recovery) |
   | volume ที่จะติดตั้ง | **Macintosh HD** เท่านั้น (ห้าม UnPlugged / OPENCORE / Untitled) |
   | copy approach | **2 — Copy (cp)** (ไม่ใช้ symlink เพราะหลังรีบูต USB exFAT ไม่ถูก mount) |
   | สรุปงาน → ยืนยัน | ตรวจว่าเป็น `/Volumes/Macintosh HD` แล้วพิมพ์ `y` |
5. รอ expand + copy (หลายนาที) แล้วตัวติดตั้งจะเปิดเอง — **อย่าปิด Terminal**
6. ในตัวติดตั้ง: Continue → Agree → เลือก **Macintosh HD** → Continue
   ช่วงแรก "About 12 minutes remaining" แล้วเครื่องจะรีบูต

## ขั้นที่ 6 — รีบูตระหว่างติดตั้ง (หลายรอบ)

ทุกครั้งที่เครื่องรีบูต:
1. กด **F12** → USB KINGSTON
2. ใน OpenCore เลือก **macOS Installer** (ไม่ใช่ Recovery, ไม่ใช่ Windows)
3. รอ — จะเห็น Apple logo + "About 28 minutes remaining" แล้วรีบูตอีก 1–2 รอบ
4. เมื่อรายการ **macOS Installer หายไป เหลือ `Macintosh HD`** → เลือก `Macintosh HD`

ถ้าวนกลับมาที่ "macOS Installer" เกิน 3 รอบโดยไม่คืบหน้า (รอบก่อนเกิดจาก SecureBootModel ซึ่งรอบนี้แก้แล้ว) → ถ่ายรูป/วิดีโอช่วงก่อนรีบูต แล้วหยุด

## ขั้นที่ 7 — Setup Assistant

1. เลือกประเทศ ภาษา ฯลฯ ไปตามปกติ
2. **ข้าม Apple ID / iCloud ไปก่อน** (Set Up Later)
3. Keyboard Setup Assistant ขึ้น = ปกติ (คีย์บอร์ดไม่ใช่ของ Apple)
4. ตอนนี้ UI ช้า/หน่วง เพราะ NootedRed ปิดอยู่ — ปกติ ไม่ต้องแก้อะไร

**ถึงขั้นนี้ = ติดตั้งสำเร็จ** บอกผมได้เลย

## ขั้นที่ 8 — เปิดกราฟิก (NootedRed) และย้าย OpenCore ไป Apacer

ทำหลังเข้า desktop ได้แล้ว (ผมจะช่วยทำทีละขั้น):
1. กลับเข้า Windows (ถอด USB → F12 → Windows Boot Manager) ยืนยันว่า Windows ยังบูตได้
2. ลง OpenCore ชุดเต็ม (NootedRed เปิด = ชุด `OC.bak-20261012-135345` ที่เคยใช้ได้) ลง ESP ของ Apacer ด้วย `tools/Install-OpenCore-ESP.ps1` (แบ็กอัป ESP ก่อนเขียน, ไม่แตะไฟล์ Windows, สร้าง boot entry "OpenCore" ต่อท้าย)
3. F12 → OpenCore → `Macintosh HD` — ควรได้ภาพลื่น จอติดปกติ

## ถ้าไม่ผ่าน

- **Recovery ค้าง/panic** → ถ่ายรูปบรรทัดสุดท้าย อย่าแก้ config เอง
- **mount_exfat ไม่ได้** → ตรวจตัวระบุดิสก์อีกครั้ง (`diskutil list`)
- **กลับ Windows ได้ทุกเมื่อ**: ถอด USB → F12 → Windows Boot Manager
- **Windows บูตไม่ขึ้นหลังติดตั้ง** → ไฟล์บน C: ไม่หาย ซ่อม bootloader ได้ด้วย `bcdboot` หรือจาก `Desktop\ESP-backup`
