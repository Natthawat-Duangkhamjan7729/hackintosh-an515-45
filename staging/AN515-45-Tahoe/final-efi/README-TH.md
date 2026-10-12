# EFI Final (AN515-45) — ชุดที่บูต macOS ได้จริง

ส่งออกจากโฟลเดอร์ `Final/` (สำเนา USB/ESP ของผู้ใช้) เมื่อ 2026-10-12

## หลักฐานว่าใช้งานได้

- OpenCore log ล่าสุดของชุดนี้ (2026-10-11 05:14) แสดง `OCAK: Read kernel version 24.6.0`
  และ `OCB: Perform boot Macintosh HD` = macOS Sequoia (Darwin 24.6) บน NVMe ภายใน
- ไม่ใช่ชุดสำหรับ Tahoe: AppleALC เปิดอยู่ (Tahoe ไม่มี AppleHDA) — ดู `../TAHOE-PLAN-TH.md`

## ข้อมูลชุด

| รายการ | ค่า |
| --- | --- |
| OpenCore | 1.0.8 DEBUG (`ocvalidate` 1.0.8: No issues found กับ config ที่ commit) |
| SMBIOS | MacBookPro16,2 |
| boot-args | `-v keepsyms=1 debug=0x100` |
| SIP | `csr-active-config` = 00000000 (เปิด) |
| ACPI | SSDT-EC-USBX, XOSI, CPUR, PNLF, ALS0, Acer-NoHybGfx |
| Kexts | ดู `MANIFEST.md` (เวอร์ชัน + SHA256) |

## สิ่งที่ไม่ได้ commit

- **PlatformInfo จริง**: `config.plist` ที่นี่ใส่ serial/MLB/UUID/ROM เป็นค่าตัวอย่าง
  ต้องใส่ค่าส่วนตัวเอง (`tools/New-PlatformInfo.ps1` หรือ `build_candidate.py --private`) ก่อนใช้งาน
- ไฟล์ `.efi` และ kext ทั้งหมด (ยกเว้น `USBMap.kext`) — โหลดตามเวอร์ชันใน `MANIFEST.md`
  แล้วตรวจ SHA256 ให้ตรง
- OpenCore logs, Recovery (`com.apple.recovery.boot`), rescue configs (มีข้อมูล identity)

USBMap.kext ทำมาสำหรับ AN515-45 เครื่องนี้เท่านั้น เครื่องอื่นต้องทำ USB map เอง
