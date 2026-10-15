# สรุปงาน Hackintosh: Acer Nitro 5 AN515-45-R375 → macOS Sequoia

อัปเดต: 2026-10-09 · รายละเอียดเต็ม: `PROGRESS-2026-10-09.md` · ประวัติ: git log ใน `D:\Hackintosh`

## สถานะตอนนี้

**บูต macOS Recovery ได้เสถียรแล้ว** แต่ **ยังไม่ได้ติดตั้ง macOS** เพราะยังไม่มีพื้นที่ดิสก์ที่ใช้ได้

| เรื่อง | สถานะ |
| --- | --- |
| บูตเข้า Recovery 15.4.1 | ✅ ได้ ไม่ panic (config `candidate-v3-test-noNR`, ถอด Micron แล้ว) |
| คีย์บอร์ด / ทัชแพด | ✅ ใช้ได้ |
| mount พาร์ทิชันตัวติดตั้ง (exFAT) | ✅ ได้ (ต้องสั่ง `mkdir` ใหม่ทุกครั้งที่บูต) |
| ตัวติดตั้ง Sequoia 15.8.1 บน USB | ✅ ขนาดและ SHA256 ตรงกับ Apple |
| จอเมื่อเปิด NootedRed (กราฟิก iGPU) | ❌ จอดำ จะแก้หลังติดตั้ง |
| ดิสก์สำหรับติดตั้ง | ⏳ กำลังเตรียม (ย่อ C: บน Apacer) |

## เครื่องและเวอร์ชัน

- Ryzen 7 5800H (8 คอร์/16 เธรด), iGPU Vega (Cezanne), RTX 3060 Laptop (macOS ไม่รองรับ)
- OpenCore 1.0.8 DEBUG, SMBIOS MacBookPro16,2 (serial ยังเป็นค่าตัวอย่าง)
- เป้าหมาย: macOS Sequoia 15.8.1 (24H32) ติดตั้งแบบ offline ผ่าน UnPlugged

## ปัญหาที่เจอและแก้แล้ว

### 1. ค้างที่ `pci (build ...)` ✅ แก้แล้ว
- **อาการ:** บูตแล้วค้างนิ่งหลังบรรทัด `pci (build 18:19:28 Apr 11 2025)`
- **ลองแล้วไม่ใช่สาเหตุ:** ปิด NootedRed, ตัด kext เหลือ 5 ตัว, ถอด XOSI, `npci=0x3000`, debug log ของ PCI, `SetupVirtualMap=false`
- **สาเหตุจริง:** ACPI ของ Acer ประกาศ CPU เป็น `Device (ACPI0007)` อย่างเดียว ไม่มี `Processor` ที่ macOS ต้องการ (แบบเดียวกับบอร์ด B550/A520)
- **วิธีแก้:** `SSDT-CPUR` ทำเฉพาะเครื่องนี้ (16 Processor, แสดงเฉพาะ macOS, P_BLK = 0 เพราะ PM base ของเครื่องนี้คือ 0x400)

### 2. Kernel panic ใน IONVMeFamily ✅ ระบุสาเหตุแล้ว
- **อาการ:** panic ที่ประมาณ 75 วินาทีหลังบูต (NVMe ไม่ตอบคำสั่ง)
- **สาเหตุ:** SSD ใหม่ **Micron 2200V** อยู่ในตระกูล Micron 2200 ที่ Dortania ระบุว่าใช้กับ macOS ไม่ได้
- **ลองแล้วไม่หาย:** NVMeFix 1.1.3, ปิด APST
- **ยืนยัน:** ถอด Micron ออกแล้วไม่ panic

## ปัญหาที่ยังค้าง

### 3. จอดำเมื่อเปิด NootedRed ❌
- ระบบยังทำงาน (ไฟ Caps Lock ติดดับตามที่กด) แต่จอไม่มีภาพ
- ตอนนี้ปิด NootedRed ไว้เพื่อติดตั้งด้วยภาพจากเฟิร์มแวร์ (ช้าแต่ใช้ได้)
- สิ่งที่จะลองหลังติดตั้ง: SSDT-PNLF/ALS0 ของ NootedRed (ความสว่างจอ), เพิ่ม UMA เป็น 1 GB ขึ้นไป

### 4. พื้นที่ติดตั้ง ⏳ (กำลังทำ)
- เลือกทำ dual-boot บน **Apacer 512 GB** (ดิสก์ Windows)
- Windows ย่อ C: ได้แค่ประมาณ 34 GB เพราะข้อมูลระบบ NTFS (`$Mft::$BITMAP`) ย้ายไม่ได้
- **แผนที่เลือก (ทาง B):**
  1. ทำ System Image ลง D: ← **กำลังทำ**
  2. ปิด BitLocker (decrypt)
  3. ย่อ C: ด้วย MiniTool Partition Wizard ให้เหลือที่ว่าง 150–200 GB
  4. เปิด pagefile กลับ (**ตอนนี้ปิดอยู่**)
- ทางเลือกอื่นที่ความเสี่ยงต่ำกว่า: ซื้อ NVMe ที่ macOS รองรับมาใส่แทน Micron

## สิ่งที่สำรองไว้แล้ว

- โฟลเดอร์ผู้ใช้ (ยกเว้น OneDrive/AppData): `D:\Backup-C-2026-10-09\arika` คัดลอก 35,439 ไฟล์ (14.2 GB) ไม่มีไฟล์ล้มเหลว
- OneDrive (Desktop/Documents/Pictures) มีสำเนาอยู่บน cloud
- config ทุกรอบที่ทดสอบอยู่บน USB เป็น `E:\EFI\OC\config-*.plist` และใน `staging/`

## ไฟล์สำคัญ

| ไฟล์ | คืออะไร |
| --- | --- |
| `candidates/candidate-v3/EFI` | EFI ชุดล่าสุด (v1 + SSDT-CPUR + NootedRed + NVMeFix) |
| `candidates/candidate-v3-test-noNR/config.plist` | config ที่บูตเสถียร (ปิด NootedRed) อยู่บน USB ตอนนี้ |
| `components/ACPI/SSDT-CPUR.dsl` | SSDT ที่แก้ปัญหา CPU |
| `tools/build_candidate.py` | สคริปต์สร้าง EFI ใหม่ได้ทุกครั้ง |
| `docs/USB-INSTALL-TH.md` | ขั้นตอนติดตั้งแบบ offline |
| `firmware-evidence/FIRMWARE-FINDINGS.md` | ผลวิเคราะห์เฟิร์มแวร์ |

## ขั้นต่อไปหลังมีพื้นที่ว่าง

1. บูต USB → Recovery → Disk Utility สร้าง APFS ในพื้นที่ Unallocated ของ Apacer (ผมจะช่วยเช็คก่อนกดทุกขั้น)
2. Terminal: `mkdir` + `mount_exfat` → `bash UnPlugged.command` → เลือก Fully expand InstallAssistant.pkg
3. ติดตั้ง macOS
4. หลังติดตั้ง: สร้าง serial ด้วย GenSMBIOS, แก้จอ NootedRed, เสียง, Wi-Fi, ย้าย EFI ลงดิสก์ภายใน

> ไม่มีขั้นไหนที่ทดสอบบูต macOS ที่ติดตั้งแล้วจริง สถานะ EFI คือ "บูต Recovery ได้" ยังไม่ใช่ "ใช้งาน macOS ได้"
