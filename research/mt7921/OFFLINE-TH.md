# เตรียม build บน Hackintosh ที่ไม่มีอินเทอร์เน็ต

## บน Windows

1. เปิด https://developer.apple.com/download/all/?q=Xcode%2016.4
   ลงชื่อเข้าใช้ Apple Account ของคุณ แล้วดาวน์โหลด **Xcode 16.4 ตัวเต็ม (.xip)**
   ไม่ใช่ Command Line Tools อย่างเดียว ไม่ต้องสมัครสมาชิกนักพัฒนาแบบเสียเงิน
2. เลือก 16.4 เป็น toolchain เริ่มต้น เพราะ Apple ระบุว่ารองรับ Sequoia 15.3
   ถึง Tahoe 26.1.x จึงครอบคลุม 15.8.1 ตาม brief แต่ยังไม่ได้ยืนยันว่า driver นี้
   compile ผ่านด้วย toolchain นี้
3. ย้ายไฟล์ Xcode .xip และ MT7921-offline-source.zip ไปยัง USB/ไดรฟ์ที่ macOS อ่านได้
   Xcode มีขนาดใหญ่: FAT32 เก็บไฟล์เดี่ยวเกิน 4 GiB ไม่ได้
   ใช้ไดรฟ์ exFAT ที่มีอยู่หรือพื้นที่ถ่ายไฟล์อื่น อย่าฟอร์แมต USB OpenCore ทิ้ง

## บน macOS

1. คัดลอกไฟล์ทั้งสองลงดิสก์ macOS ก่อนแตกไฟล์ เผื่อพื้นที่สำหรับ .xip,
   Xcode.app, source และผล build; แนะนำมีพื้นที่ว่างอย่างน้อย 50 GB เป็นพื้นที่เผื่อ
2. เปิด .xip เพื่อแตก Xcode แล้ววาง Xcode.app ใน /Applications
3. เปิด Xcode ทำขั้นตอน license/ติดตั้ง components ที่มาพร้อมแพ็กเกจให้เสร็จ
   งานนี้ไม่ต้องใช้ iOS/watchOS/visionOS Simulator จึงไม่ต้องดาวน์โหลด runtime เหล่านั้น
   หาก first launch หรือการตรวจสอบแพ็กเกจร้องขอเครือข่าย ให้เก็บข้อความจริงไว้
   การเตรียมไฟล์ครบช่วยให้ build ออฟไลน์ได้ แต่ยังไม่ได้ทดสอบ first launch บนเครื่องนี้
4. แตก MT7921-offline-source.zip ได้โฟลเดอร์ MT7921-offline
5. เปิด Terminal พิมพ์ `bash ` แล้วลาก build-offline.sh ในโฟลเดอร์นั้นมาวาง กด Enter
   สคริปต์จะ build และเก็บ build.log ใน source/offline-build.<รหัส>/

ชุดนี้เตรียม source และ MacKernelSDK ไว้แล้ว ไม่ต้องติดตั้ง Python หรือ clone Git บน macOS
ไม่รวม Xcode ไม่รวม binary kext ที่ผ่านการทดสอบ และไม่ติดตั้ง/โหลด kext หรือเขียน EFI
เก็บ build.log ไว้สำหรับแก้ compiler error หากเกิดขึ้น ไม่ต้องเปลี่ยน SIP สำหรับการ build
อย่าเพิ่งย้ายผลลัพธ์เข้า EFI จนกว่าจะตรวจผล build และเตรียมการทดสอบ USB แยก

## แหล่งอ้างอิง

- https://developer.apple.com/documentation/xcode-release-notes/xcode-16_4-release-notes
- https://developer.apple.com/xcode/system-requirements
- https://developer.apple.com/xcode/resources/

ตรวจเมื่อ 2026-10-09; ซอร์ส/SDK ล็อก commit ใน source/input-evidence.json
upstream licenses คงอยู่ใน source และ source/MacKernelSDK
แพ็กเกจนี้เป็นสำเนาพัฒนา local ไม่ใช่การอนุมัติให้แจกจ่าย firmware ต่อ
