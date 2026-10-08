# วิธีติดตั้ง macOS Sequoia แบบ offline ด้วย USB นี้

สถานะ: USB พร้อม แต่ **ยังไม่เคยบูต macOS บนเครื่องนี้** — ใช้ได้หลังใส่ SSD สำรองแล้วเท่านั้น

## เนื้อหาใน USB (ตรวจแล้ว 2026-10-09)

| Partition | ไฟล์ | ตรวจ |
| --- | --- | --- |
| OPENCORE (FAT32 2 GB) | `EFI/` = candidate-v1 | ตรงกับ staging ทุกไบต์, ocvalidate 1.0.8 ผ่าน |
| OPENCORE | `com.apple.recovery.boot/` = Recovery 15.4.1 (24E263) | ตรงทุกไบต์, chunklist ผ่าน |
| UnPlugged (exFAT) | `InstallAssistant.pkg` 15.8.1 (24H32) | ขนาดและ SHA256 ตรงกับ catalog ของ Apple |
| UnPlugged | `UnPlugged.command` (corpnewt e7e0696) | ตรงทุกไบต์ |

## ก่อนวันติดตั้ง

1. ใส่ SSD สำรอง และจดรุ่นกับขนาดไว้ เพื่อแยกจาก Apacer 512 GB (Windows) และ Toshiba 1 TB
2. (แนะนำ) สร้าง serial/MLB/UUID ด้วย GenSMBIOS บนเครื่องคุณ แล้วใส่ใน `E:\EFI\OC\config.plist` เอง — ไม่ต้องส่งให้ใคร ถ้ายังไม่ทำ ติดตั้งได้แต่ iCloud/iMessage ใช้ไม่ได้
3. (แนะนำ) ตั้ง UMA/VRAM ใน BIOS เป็น 1 GB ขึ้นไปถ้ามีตัวเลือก
4. เก็บ BitLocker Recovery Key ไว้ใกล้มือ

## ขั้นตอน

1. Secure Boot ปิดอยู่ → เสียบ USB → กด F12 เลือก USB KINGSTON
2. ใน OpenCore เลือกรายการ Recovery (macOS Base System) — จะเห็นข้อความ verbose วิ่ง ถ้าค้างหรือ reboot ให้ถ่ายรูปหน้าจอบรรทัดสุดท้ายแล้วหยุด
3. ใน Recovery เปิด **Disk Utility** → View → Show All Devices → เลือก **ตัวดิสก์ SSD สำรอง** (ดูรุ่น/ขนาดให้แน่ใจ ห้ามเลือก Apacer หรือ Toshiba) → Erase เป็น **APFS, GUID Partition Map** → ปิด Disk Utility
4. เปิด **Terminal** แล้วพิมพ์:
   ```
   diskutil list physical
   ```
   หา partition ชื่อ `UnPlugged` (เช่น `disk3s2`) แล้ว:
   ```
   mkdir /Volumes/UnPlugged
   /sbin/mount_exfat /dev/diskXsY /Volumes/UnPlugged
   cd /Volumes/UnPlugged
   bash UnPlugged.command
   ```
   (เปลี่ยน `diskXsY` เป็นค่าที่เห็นจริง; ถ้า UnPlugged mount เองแล้วข้าม mkdir/mount ได้)
5. เมื่อสคริปต์ถาม เลือก **Fully expand InstallAssistant.pkg** → เลือก volume ของ SSD สำรองที่เพิ่ง format → ตอบ `y`
6. ตัวติดตั้งจะเปิดขึ้น — **อย่าปิด Terminal** — ติดตั้งต่อตามปกติ เครื่องจะรีบูตหลายรอบ ให้เลือกรายการ `macOS Installer` / ชื่อดิสก์ใหม่ใน OpenCore ทุกครั้ง

## ถ้าไม่ผ่าน

- Recovery mount exFAT ไม่ได้ → ทางเลือกคือ Recovery Monterey เป็นตัวเริ่ม (ตาม README ของ UnPlugged) — แจ้งผมก่อน
- หยุดตอนต้นบูตหรือ Security Violation → ดูทางแก้ใน `candidate-v1/CANDIDATE-v1.md` (RebuildAppleMemoryMap / SecureBootModel) — เปลี่ยนทีละค่า
- กลับ Windows ได้ทุกเมื่อ: ถอด USB แล้วบูต Windows Boot Manager

อ้างอิง: https://github.com/corpnewt/UnPlugged/tree/e7e0696dcb6dee23d25422678a8bc90ac2597ef5
