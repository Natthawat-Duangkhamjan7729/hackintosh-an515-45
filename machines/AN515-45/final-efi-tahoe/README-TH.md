# EFI Tahoe + NullMoth (AN515-45) — ชุดที่ใช้งานอยู่ (sanitized)

ส่งออกจาก `private-build/candidate-tahoe-nullmoth-pwrl2-nmxaudio` เมื่อ 2026-11-07
ชุดนี้คือ config ที่อยู่บน USB KINGSTON ตอนนี้ (`cmp` ตรงกัน)
ส่วน `../final-efi/` เป็นชุด Sequoia 15.8.1 เดิม เก็บไว้อ้างอิง

## หลักฐานว่าใช้งานได้ (2026-11-07)

- บูต macOS Tahoe 26.7.1 (25G241) จาก USB ได้ โดยจอนอก LG ต่อ HDMI และใช้ RTX 3060 ผ่าน NullMoth 2.7.2 (Metal 3)
- ตอนเสียบไฟ CPU ใช้ไฟได้ราว 44 W (SSDT-PWRL) ตอนใช้แบตกลับไปใช้ 18.5 W ตามค่าของ EC
- เสียง: NMXAudio ของ NullMoth ขับ ALC295 (ผู้ใช้ได้ยินเสียงจากลำโพงในเครื่อง) และมีอุปกรณ์ NVIDIA HDMI/DP
- ยังไม่ได้ทดสอบ: ไมค์, ช่องหูฟัง, เสียงผ่าน HDMI, sleep/wake, โหลดหนักนานต่อเนื่อง
- ผลวัดและขั้นตอนทั้งหมดอยู่ใน `../docs/PROGRESS-2026-11.md`

## ข้อมูลชุด

| รายการ | ค่า |
| --- | --- |
| OpenCore | 1.0.8 DEBUG (`ocvalidate` 1.0.8: No issues found กับ config ที่ commit) |
| SMBIOS | MacBookPro16,2 |
| boot-args | `keepsyms=1 debug=0x100 ps2kbdonly=1 nvfb=1 nvaccel=1 nvfbheads=4 -nvkmsnosmooth amfi_get_out_of_my_way=0x1 amfi=0x80 ipc_control_port_options=0 nvrmacpibl=1 -v nvfbhidpi=1` |
| SIP | `csr-active-config` = `430A0000` (ค่าที่ NullMoth ใช้ทดสอบ) |
| SecureBootModel | Disabled |
| Kernel Block | `com.apple.iokit.IONDRVSupport` (Exclude) ตามที่ NullMoth กำหนด |
| ACPI | SSDT-EC-USBX, XOSI, CPUR, PNLF, ALS0, **PWRL** (เปิด) · SSDT-Acer-NoHybGfx (ปิด เพราะต้องใช้ RTX) |
| ACPI patch | `_OSI` → `XOSI` และ `EC0._Q20` → `XQ20` (DSDT เท่านั้น) |
| Kexts | ดู `MANIFEST.md` (เวอร์ชัน, เปิด/ปิดใน config, SHA256) · VoodooHDA, NootedRed, AppleALC ปิดอยู่ |
| นอก EFI | NullMoth 2.7.2: NVRM, NVAccel, NVRMFB, NVRMAGDC, NMXAudio อยู่ใน `/Library/Extensions` |

## สิ่งที่ไม่ได้ commit

- **PlatformInfo จริง**: serial, MLB, UUID และ ROM ใน `config.plist` ที่นี่เป็นค่าตัวอย่างชุดเดียวกับ `final-efi/`
  ส่วนอื่นของ config ตรงกับชุดบน USB ทุก key (ตรวจแล้ว)
  ต้องใส่ค่าส่วนตัวเอง (`tools/New-PlatformInfo.ps1` หรือ `build_candidate.py --private`) ก่อนใช้
- ไฟล์ `.efi` และ kext ทั้งหมด ยกเว้น `USBMap.kext` และ `UTBMap.kext` (เป็น plist อย่างเดียว) ให้โหลดตามเวอร์ชันใน `MANIFEST.md` แล้วตรวจ SHA256
- ไดรเวอร์ NullMoth ติดตั้งด้วยแอป 1401 หรือ `install.sh` ของ NullMoth ไม่ได้ฉีดจาก EFI

USB map ทำมาสำหรับ AN515-45 เครื่องนี้เท่านั้น เครื่องอื่นต้องทำเอง
