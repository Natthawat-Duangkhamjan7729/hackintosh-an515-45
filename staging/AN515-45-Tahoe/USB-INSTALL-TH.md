# วิธีติดตั้ง macOS Sequoia แบบ offline ด้วย USB นี้ (dual-boot บน Apacer)

สถานะ (อัปเดต 2026-10-09): Recovery 15.4.1 บูตได้เสถียรด้วย `candidate-v3-test-noNR` เมื่อถอด Micron 2200V ออก (ทัชแพดใช้ได้ mount exFAT ได้) ปลายทางคือ volume **Macintosh HD** ใน APFS container ขนาด 274.9 GB บน Apacer (เลขดิสก์เปลี่ยนตามการบูต) ซึ่งสร้างไว้แล้ว ยังไม่เคยติดตั้ง macOS จริงบนเครื่องนี้

> ⚠️ **ห้าม Erase ดิสก์ใดๆ ใน Disk Utility** — Apacer มี Windows อยู่ การ Erase ทั้งลูกจะลบ Windows ทั้งหมด

## เนื้อหาใน USB

| Partition | ไฟล์ | ตรวจ |
| --- | --- | --- |
| OPENCORE (FAT32 2 GB) | `EFI/OC/config.plist` = candidate-v3-test-noNR (NootedRed ปิด) พร้อม SSDT-CPUR และ NVMeFix; config รุ่นก่อนเก็บไว้เป็น `config-*.plist` | `cmp` ตรงกับ staging, ocvalidate 1.0.8 ผ่าน |
| OPENCORE | `com.apple.recovery.boot/` = Recovery 15.4.1 (24E263) | ตรงทุกไบต์, chunklist ผ่าน |
| UnPlugged (exFAT) | `InstallAssistant.pkg` 15.8.1 (24H32) | ขนาดและ SHA256 ตรงกับ catalog ของ Apple |
| UnPlugged | `UnPlugged.command` (corpnewt e7e0696) | ตรงทุกไบต์ |

## เตรียมก่อนติดตั้ง

1. (ทำแล้ว) ย่อ C: เหลือ 236.1 GB และสร้าง APFS "Macintosh HD" 274.9 GB ต่อท้าย C: (`diskutil addPartition disk1s3 APFS "Macintosh HD" 0`) ตรวจแล้วว่า C: และ Windows Recovery ขนาดเท่าเดิม
2. (ทำแล้ว) Backup: system image ใน `D:\WindowsImageBackup`, ไฟล์ profile ใน `D:\Backup-C-2026-10-09`; BitLocker บน C: ปิดแล้ว; paging file เปิดกลับแล้ว
3. (แนะนำ) ถอด USB แล้วบูต Windows หนึ่งครั้ง (F12 → Windows Boot Manager) เพื่อยืนยันว่า Windows ยังบูตได้ก่อนเริ่มติดตั้ง
4. ถอด Micron 2200V ไว้ตลอดการติดตั้ง (ใส่แล้วจะ panic ที่ ~75 วินาที)
5. (ทำหลังติดตั้งได้) serial/MLB/UUID ด้วย GenSMBIOS — ไม่ต้องส่งให้ใคร ถ้ายังไม่ทำ ติดตั้งได้แต่ iCloud/iMessage ใช้ไม่ได้

## ขั้นตอน

1. Secure Boot ปิดอยู่ → เสียบ USB → กด F12 เลือก USB KINGSTON
2. ใน OpenCore เลือกรายการ Recovery (macOS Base System) ถ้าค้าง/รีบูต/panic ให้ถ่ายรูปบรรทัดสุดท้ายแล้วหยุด
3. เปิด **Terminal** ตรวจดิสก์ก่อน (คำสั่งอ่านอย่างเดียว):
   ```
   diskutil list physical
   diskutil apfs list
   ```
   ต้องเห็น Apacer (512.1 GB) มี `Apple_APFS` 274.9 GB และ volume **Macintosh HD**; หา partition `UnPlugged` ของ USB (บรรทัด `Windows_NTFS UnPlugged 57.9 GB`)
   > ⚠️ **หมายเลขดิสก์เปลี่ยนได้ทุกครั้งที่บูต** — หลังสร้าง APFS แล้ว Apacer กลายเป็น `disk2`, HDD เป็น `disk1`, USB เป็น `disk4` (UnPlugged = `disk4s2`) ใช้ค่าจากหน้าจอรอบนั้นเสมอ อย่าจำเลขจากรอบก่อน
4. Mount exFAT แล้วรันสคริปต์ (ใน Recovery ไม่มีคำสั่ง `clear`; ต้อง `mkdir` ใหม่ทุกครั้งที่รีบูต) แทน `diskNsM` ด้วยตัวระบุของ UnPlugged ที่เห็นในข้อ 3:
   ```
   mkdir -p /Volumes/UnPlugged
   /sbin/mount_exfat /dev/diskNsM /Volumes/UnPlugged
   cd /Volumes/UnPlugged
   bash UnPlugged.command
   ```
   ถ้าขึ้น `No such file or directory` แปลว่าตัวระบุดิสก์ผิดหรือยังไม่ได้ `mkdir`
5. ตอบคำถามของสคริปต์ตามลำดับ:
   - **Select the volume where you are installing macOS** → หมายเลขของ **Macintosh HD** เท่านั้น (ห้ามเลือก UnPlugged, OPENCORE หรือ volume อื่น)
   - ถ้าถามเรื่อง prior attempts → `y` ได้
   - approach → **Fully expand InstallAssistant.pkg**
   - ตรวจรายการสรุปว่าเป็น `/Volumes/Macintosh HD` แล้วตอบ `y`
6. ตัวติดตั้งจะเปิดขึ้น — **อย่าปิด Terminal** — เลือกติดตั้งลง **Macintosh HD** เครื่องจะรีบูตหลายรอบ ทุกครั้งให้กด F12 → USB → เลือก `macOS Installer` ใน OpenCore จนเหลือรายการ `Macintosh HD`
7. ระหว่างนี้จอแสดงผ่าน framebuffer ของเฟิร์มแวร์ (ไม่มี graphics acceleration) ภาพช้าเป็นเรื่องปกติ

## ถ้าไม่ผ่าน

- Recovery mount exFAT ไม่ได้ → ทางเลือกคือ Recovery Monterey เป็นตัวเริ่ม (ตาม README ของ UnPlugged) — แจ้งก่อน
- ค้างหรือ panic ระหว่างติดตั้ง → ถ่ายรูปหน้าจอ (ให้เห็นบรรทัดบนสุดของ panic ถ้าได้) แล้วหยุด อย่าแก้ config เอง
- กลับ Windows ได้ทุกเมื่อ: ถอด USB แล้ว F12 → Windows Boot Manager
- ถ้า Windows บูตไม่ขึ้นหลังติดตั้ง (EFI partition ใช้ร่วมกัน) → ไฟล์บน C: ไม่ได้หาย ซ่อมไฟล์บูตได้ด้วย `bcdboot` จาก USB ติดตั้ง Windows หรือกู้จาก system image ใน D:

## งานหลังติดตั้ง (ยังไม่ทำ)

PlatformInfo จริง, จอดำของ NootedRed (SSDT-PNLF/backlight, UMA ≥1 GiB), USB map, Wi-Fi/Bluetooth MT7921, และย้าย OpenCore ไปไว้ใน EFI ของ Apacer (ทำเมื่อสั่งเท่านั้น)

อ้างอิง: https://github.com/corpnewt/UnPlugged/tree/e7e0696dcb6dee23d25422678a8bc90ac2597ef5
