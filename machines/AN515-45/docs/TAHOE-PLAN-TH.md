# แผนติดตั้ง macOS Tahoe 26.7.1 (AN515-45-R375, dual-boot บน Apacer)

อัปเดต 2026-10-12 · สถานะ: **candidate, schema-validated** (ยังไม่เคยบูต Tahoe บนเครื่องนี้)

## ตรวจความเข้ากันได้ (ตรวจเมื่อ 2026-10-12)

| ส่วน | เวอร์ชันที่ใช้ | Tahoe | หลักฐาน |
| --- | --- | --- | --- |
| ตัวติดตั้ง | 26.7.1 (25G241), product 142-28081, 18,380,974,544 bytes | ตัวล่าสุดของ Tahoe | Apple public catalog; support.apple.com/122868 ระบุ 26.7.1 วันที่ 2026-09-28 |
| SMBIOS | MacBookPro16,2 | รองรับ | Apple: MacBook Pro 13" 2020 รุ่น 4 พอร์ต Thunderbolt รองรับ Tahoe |
| OpenCore | 1.0.8 DEBUG | ใช้ได้ (ตัวล่าสุด) | OpenCorePkg release 1.0.8 (2026-09-27) |
| AMD kernel patches | AMD_Vanilla eaf52ef | MaxKernel 25.99.99 ครอบคลุม Darwin 25 | commit c735ede "Add Tahoe beta patches" อยู่ก่อน eaf52ef (ตัวล่าสุด) |
| NootedRed | 0.8.10 | หน้า ChefKiss ระบุ "compatible with macOS 10.15 up to macOS 26" | ยังเป็น release ล่าสุด (2026-05-15) |
| Lilu | 1.7.2 | changelog: "Fixed AMDSupport lockups & panics in macOS 26" | |
| NVMeFix | 1.1.3 | changelog: "Added constants for macOS 26 support" | |
| RealtekRTL8111 | 3.0.0 | changelog: "Added support for AppleVTD under Tahoe" | |
| **เสียง (AppleALC)** | 1.9.8 | **ใช้ไม่ได้**: Tahoe ตัด AppleHDA ออก | maintainer NootedRed (discussion #369): "tahoe dropped applehda so applealc doesn't work, use voodoohda or modified oclp" |
| VirtualSMC 1.3.8, ECEnabler, ForgedInvariant 1.5.0, BrightnessKeys, VoodooPS2 2.3.7, VoodooI2C 2.9.1 | ตัวล่าสุดทั้งหมด | changelog ไม่ได้ระบุ Tahoe โดยตรง ยังไม่ยืนยัน | |
| UnPlugged | e7e0696 | README ไม่ได้พูดถึง Tahoe | สำหรับ Sonoma+ README ให้ใช้ Recovery รุ่นเก่ากว่าเป็นตัวเริ่ม |

## EFI ที่เตรียมไว้

ทั้งสองชุดต่อยอดจาก candidate-v10 (UpdateSMBIOSMode=Custom) ผ่าน ocvalidate 1.0.8 ทั้งชุด public และ private ("No issues found")

| โฟลเดอร์ | ต่างจาก v10 | ใช้ตอน |
| --- | --- | --- |
| `private-build/candidate-tahoe-install` | AppleALC ปิด และ NootedRed ปิด | ช่วงติดตั้ง (ภาพผ่าน framebuffer ของเฟิร์มแวร์ เหมือนตอนติดตั้ง Sequoia) |
| `private-build/candidate-tahoe` | AppleALC ปิด | หลังเข้า desktop ได้ (เปิดเร่งกราฟิก) |

สร้างใหม่ได้ด้วยคำสั่ง `py -3.12 -I tools\build_candidate.py . candidate-tahoe[-install] --tahoe [--install] --private`

## ขั้นตอน

1. **ทดสอบ v10 เรื่องคีย์บอร์ดไปพร้อมกันได้** เพราะ Tahoe candidate มีการแก้ SMBIOS ชุดเดียวกัน
2. **ตัวติดตั้ง**: **โหลดเสร็จและตรวจแล้ว**: `installer\Tahoe-26.7.1-25G241\InstallAssistant.pkg` ขนาดตรงกับ catalog, TOC ตรงกับ Digest และ payload ทั้ง 5 ส่วนตรงกับ SHA-1 (ตรวจด้วย `tools\verify_pkg.py`) ยังไม่ได้ตรวจลายเซ็นของ Apple
3. **USB ใหม่** (ต้องหาเพิ่ม เพราะ KINGSTON ตัวเดิมไม่มีแล้ว) ขนาด ≥ 32 GB แบ่งเป็น FAT32 `OPENCORE` 2 GB + exFAT `UnPlugged` ใช้ `tools\Partition-USB.ps1` ได้ แต่**ต้องแก้เลขดิสก์และตรวจรุ่น USB ก่อนรันทุกครั้ง** ใส่ไฟล์ดังนี้:
   - OPENCORE: `EFI` จาก `private-build\candidate-tahoe-install` และ `com.apple.recovery.boot` = Recovery 15.4.1 ที่มีอยู่แล้ว (เคยพิสูจน์บนเครื่องนี้ว่าบูตได้และ `mount_exfat` ได้)
   - UnPlugged: `InstallAssistant.pkg` 26.7.1 และ `UnPlugged.command`
4. **พื้นที่บน Apacer**: ย่อ C: ใน Windows ให้มีที่ว่างต่อท้าย C: ราว 150–256 GB (ทำ backup และปิด BitLocker ก่อน แบบเดียวกับรอบ Sequoia)
5. บูต USB → Recovery 15.4.1 → `diskutil addPartition <ตัวระบุ C:> APFS "Macintosh HD" 0` (**ตรวจตัวระบุจาก `diskutil list physical` รอบนั้นเสมอ**)
6. mount exFAT → `bash UnPlugged.command` → "Fully expand InstallAssistant.pkg" → ติดตั้งลง Macintosh HD ทุกครั้งที่รีบูต: F12 → USB → `macOS Installer`
7. เข้า desktop ได้แล้ว → เปลี่ยน config บน USB เป็น `candidate-tahoe` (เปิด NootedRed) → ทดสอบ → ถ้าผ่านค่อยลงใน ESP ด้วย `Install-OpenCore-ESP.ps1 -Source private-build\candidate-tahoe\EFI\OC`
8. เสียง: ทำทีหลัง เลือกระหว่าง VoodooHDA (ไม่ต้องพึ่ง AppleHDA) หรือคืน AppleHDA ด้วย root patch (ต้องลด SIP) — ยังไม่เลือก ยังไม่ตรวจกับเครื่องนี้

## ความเสี่ยงที่ทราบ

- ใช้ Recovery 15.4.1 รัน installer ของ 26.7.1: เป็นแนวทาง "Recovery เก่ากว่าเป็นตัวเริ่ม" ตาม README ของ UnPlugged แต่ยังไม่เคยลองคู่นี้ ถ้าไม่ผ่านให้ใช้ Recovery ของ Tahoe จาก macrecovery แทน และต้องลองว่า mount exFAT ได้หรือไม่
- Tahoe ไม่มี AppleHDA ดังนั้นจะไม่มีเสียงจากลำโพงหรือแจ็คจนกว่าจะแก้ (เสียงผ่าน HDMI หรือ USB headset น่าจะยังใช้ได้)
- อาการภาพเพี้ยนในแอป Electron/Safari จาก NootedRed (issue #158) น่าจะยังอยู่บน Tahoe
- APFS ของ Tahoe ยังเป็น APFS แบบเดียวกัน อย่า Erase ดิสก์ Apacer ทั้งลูก (มี Windows อยู่)
- ถ้าจะกลับไป Sequoia: ตัวติดตั้ง 15.8.1 และ candidate-v10 ยังอยู่ครบ

## แหล่งอ้างอิง

- https://support.apple.com/en-us/122868 (Tahoe updates) · https://support.apple.com/122867 (Tahoe compatible Macs)
- https://github.com/AMD-OSX/AMD_Vanilla (commits c735ede, eaf52ef)
- https://chefkiss.dev/applehax/nootedred/ (saved 2026-10-09) · https://github.com/ChefKissInc/NootedRed/discussions/369
- Release notes: acidanthera Lilu 1.7.2, NVMeFix 1.1.3, Mieze RTL8111 v3.0.0, USBToolBox 1.2.0
- https://github.com/corpnewt/UnPlugged
