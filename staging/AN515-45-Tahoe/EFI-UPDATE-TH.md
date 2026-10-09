# ติดตั้งและอัปเดต OpenCore บน EFI ของ Apacer

## ติดตั้งครั้งแรก

1. เปิด **Terminal (Admin)** แล้วรันแบบทดลองก่อน (ไม่เขียนอะไร แค่ตรวจและแสดงพื้นที่ว่าง):
   ```
   powershell -ExecutionPolicy Bypass -File "D:\Hackintosh\staging\AN515-45-Tahoe\tools\Install-OpenCore-ESP.ps1" -WhatIf
   ```
2. ถ้าไม่มี error ให้รันจริง:
   ```
   powershell -ExecutionPolicy Bypass -File "D:\Hackintosh\staging\AN515-45-Tahoe\tools\Install-OpenCore-ESP.ps1"
   ```
3. รีบูต → F12 → เลือก **OpenCore** (เสียบ USB ไว้ด้วยในการทดสอบครั้งแรก เผื่อต้องกลับไปใช้ USB)
4. ถ้าใช้ได้ทั้ง macOS และ Windows ผ่าน OpenCore แล้ว ถอด USB ได้

สคริปต์จะ:
- ตรวจ config ด้วย ocvalidate 1.0.8 ก่อน
- สำรอง EFI partition ทั้งหมดไว้ที่ `D:\Backup-ESP-<วันเวลา>`
- คัดลอกเฉพาะ `EFI\OC` และตรวจ SHA256 ทุกไฟล์
- **ไม่แตะ** `EFI\Microsoft` และ `EFI\BOOT` ของ Windows
- เพิ่มรายการ boot ชื่อ "OpenCore" **ไว้ท้ายสุด** — Windows ยังเป็นค่าเริ่มต้น
  ถ้าอยากให้บูต OpenCore อัตโนมัติ ให้เพิ่ม `-MakeDefault` หรือเลื่อนลำดับใน BIOS (F2)

## อัปเดต EFI ภายหลัง (เพิ่ม kext, แก้ config, อัปเดต OpenCore)

ทำตามลำดับนี้ทุกครั้ง:

1. **แก้ใน staging เท่านั้น** — แก้ `tools/build_candidate.py` หรือ config ใน candidate ใหม่ (เช่น `candidate-v5`) ห้ามแก้ไฟล์บน EFI partition ตรงๆ
2. **build + ตรวจ** — `py -3.12 -I tools/build_candidate.py . candidate-v5` แล้ว ocvalidate (สคริปต์ติดตั้งจะตรวจซ้ำอีกครั้ง)
3. **ทดสอบจาก USB ก่อน** — วาง config/kext ใหม่ลง USB (`E:\EFI\OC`) แล้ว F12 → USB ถ้าบูตไม่ขึ้น ระบบบน Apacer ยังใช้ได้ตามเดิม
4. **ติดตั้งลง Apacer เมื่อ USB ผ่านแล้ว**:
   ```
   powershell -ExecutionPolicy Bypass -File "D:\Hackintosh\staging\AN515-45-Tahoe\tools\Install-OpenCore-ESP.ps1" -Source "D:\Hackintosh\staging\AN515-45-Tahoe\candidate-v5\EFI\OC"
   ```
   ของเดิมจะถูกเก็บเป็น `EFI\OC.bak-<วันเวลา>` และสำรองทั้ง EFI partition ไว้ใน D: อีกชั้น
5. **บันทึก** — อัปเดต PROGRESS แล้ว commit/push

> อัปเดต OpenCore เป็นเวอร์ชันใหม่: ต้องใช้ OpenCore.efi, drivers, Sample.plist และ ocvalidate จาก **เวอร์ชันเดียวกัน** และอ่าน Configuration.pdf ของเวอร์ชันนั้น (ใช้ skill `update-efi`) ห้ามผสมเวอร์ชัน

> อัปเดต macOS (เช่น 15.8.x): แนะนำให้ตรวจ release notes ของ NootedRed/Lilu และ AMD Vanilla ว่ารองรับก่อนกดอัปเดต และมี USB OpenCore สำรองไว้เสมอ

## ถ้าบูต OpenCore บน Apacer ไม่ขึ้น

- F12 → **Windows Boot Manager** — Windows ไม่ขึ้นกับ OpenCore
- F12 → **USB** — ใช้ OpenCore บน USB บูต macOS ได้เหมือนเดิม
- ย้อน EFI: ใน Windows (Admin) mount EFI partition แล้วเปลี่ยนชื่อ `EFI\OC.bak-<วันเวลา>` กลับเป็น `EFI\OC` หรือคัดลอกจาก `D:\Backup-ESP-<วันเวลา>` (บอก Claude ให้ช่วยทำได้)
