# USB ตรวจเฟิร์มแวร์ Acer Nitro 5

ชุดนี้อยู่ที่ E:\EFI ใช้ OpenCore 1.0.8 DEBUG และผ่าน ocvalidate รุ่นเดียวกันแล้ว เป็นชุดเก็บข้อมูลก่อนจัด config สำหรับ macOS ไม่ใช่ตัวติดตั้ง macOS

## วิธีใช้

1. บันทึกงานและปิดโปรแกรมก่อนรีสตาร์ต เก็บ BitLocker Recovery Key ไว้กับตัว (ไม่ต้องส่งให้ใคร)
2. เปิดเครื่อง กด F2 เข้า BIOS ถ้า Secure Boot ยัง Enabled ให้เปลี่ยนเป็น Disabled สำหรับการบูต OpenCore ชุดนี้ เปิด F12 Boot Menu หากมีตัวเลือกนี้แต่ยังปิดอยู่ หากเมนูถูกล็อกหรือไม่พบ ให้ถ่ายภาพเมนูไว้ก่อน ไม่ต้องตั้งรหัส BIOS หรือแฟลช BIOS เพื่อข้ามขั้นนี้
3. บูตใหม่ กด F12 เลือก USB KINGSTON/UGREEN ที่เตรียมไว้
4. เมื่อเห็นเมนู OpenCore เลือก **Save firmware memory map** รอจนกลับมาหน้าเมนู
5. เลือก **Restart to firmware boot** (คำสั่งนี้รีสตาร์ตตามปกติ ไม่ได้บังคับเข้าหน้า BIOS) แล้วเลือก Windows Boot Manager ผ่าน F12
6. กลับเข้า Windows แล้วแจ้งว่าเก็บรายงานแล้ว ให้ USB ต่ออยู่ ผมจะอ่านไฟล์ opencore-*.txt และ SysReport ที่เครื่องสร้างบน E: โดยตรง

SysReport มีข้อมูลระบุตัวเครื่องและอาจมี MSDM/license key เก็บไว้ในเครื่อง ไม่ต้องอัปโหลดทั้งโฟลเดอร์สู่สาธารณะ หาก Windows ขอ BitLocker Recovery Key ใช้คีย์ที่คุณเก็บไว้เอง

## ขอบเขตและการย้อนกลับ

- ScanPolicy=3 จำกัดการสแกนระบบปฏิบัติการ เมนูแสดงเฉพาะเครื่องมือที่ระบุ
- ไม่มี ACPI/kext/CPU patches หรือ SMBIOS spoofing ในชุดนี้
- LauncherOption=Disabled, RequestBootVarRouting=False และ NVRAM Add/Delete ว่าง ไม่มีคำสั่ง Reset NVRAM
- SysReport=True และ Target=67 บันทึกข้อมูลลง USB; MmapDump แสดง memory attributes และ memory map ลง log
- ผ่าน schema และตรวจเส้นทางไฟล์แล้ว ยังไม่ผ่านการบูตจริงบนเครื่องนี้
- ย้อนกลับโดยถอด USB แล้วบูต Windows Boot Manager ตามปกติ ตั้งค่า Secure Boot คืนตามค่าก่อนเปลี่ยนหากเลิกทดลอง; เก็บ Recovery Key ไว้จนยืนยันว่า Windows บูตได้ตามปกติ

อ้างอิง: Docs/Configuration.pdf และ Application/MmapDump/MmapDump.c ของ OpenCore 1.0.8
