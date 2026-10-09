# MT7921: ผลการลองแก้โจทย์และชุดเตรียม build

ตรวจเมื่อ 2026-10-09 — ยังไม่มี kext ที่ build/boot ผ่านจากงานนี้

## ข้อค้นพบที่เปลี่ยนแนวทาง

brief ระบุว่ายังไม่รู้จักไดรเวอร์ macOS สำหรับ MT7921 แต่พบ
[SimpleMtkWlan](https://github.com/laobamac/SimpleMtkWlan) ซึ่งมุ่งพัฒนา PCIe
MT7921/MT7922 จริง ผู้พัฒนายังระบุว่าเป็น experimental และกำลังแก้ association/authentication TX
จึงควรประเมินและต่อยอดโครงการนี้ก่อนเริ่ม port Linux ใหม่ทั้งหมด
การมีซอร์สไม่ยืนยันว่า Wi-Fi ใช้ได้กับ Acer เครื่องนี้

ข้อมูลเครื่องและ macOS ใน brief เป็นข้อมูลที่ผู้จัดทำเอกสารรายงานมา
งานนี้ไม่ได้ตรวจเครื่องขณะรัน macOS ไม่ได้ยืนยัน Sequoia build/Darwin version
และไม่ได้ใช้ข้อความในเอกสารเป็นคำสั่งให้ติดตั้งไดรเวอร์หรือเขียน EFI

## ตรวจจากซอร์สที่ล็อกเวอร์ชันแล้ว

SimpleMtkWlan commit `37ba676ad18273b7e622ec6db45afc25db238109`:

- [Info.plist](https://github.com/laobamac/SimpleMtkWlan/blob/37ba676ad18273b7e622ec6db45afc25db238109/SimpleMtkWlan/Info.plist) มี `IOPCIPrimaryMatch=0x796114c3` ตรงกับ `14c3:7961`; ไม่ได้จำกัด subsystem เฉพาะเครื่องนี้
- [MtkMwx.cpp](https://github.com/laobamac/SimpleMtkWlan/blob/37ba676ad18273b7e622ec6db45afc25db238109/SimpleMtkWlan/hal_mwx/MtkMwx.cpp) มีทางเดิน attach, DMA, firmware, scan, newstate และ TX ให้ศึกษาต่อ
- [SimpleMtkWlan.cpp](https://github.com/laobamac/SimpleMtkWlan/blob/37ba676ad18273b7e622ec6db45afc25db238109/SimpleMtkWlan/SimpleMtkWlan.cpp) ใน `start()` เปิด bus mastering, I/O และ memory decoding แล้วเขียน PCI config ก่อนเรียก HAL attach: baseline นี้ไม่ใช่ M0 แบบ passive และไม่ควรโหลดเพื่อเพียงอ่าน BAR/IRQ
- [project.pbxproj](https://github.com/laobamac/SimpleMtkWlan/blob/37ba676ad18273b7e622ec6db45afc25db238109/SimpleMtkWlan.xcodeproj/project.pbxproj) อ้าง path SDK ของผู้พัฒนาแบบ absolute 4 จุด; สำเนาที่เตรียมเปลี่ยนเป็น `$(PROJECT_DIR)/MacKernelSDK/Headers` และใส่ SDK ที่ล็อก commit แล้ว
- มี `include/FwBinary.cpp` พร้อม firmware MT7961 สองก้อนและอยู่ใน Sources build phase แม้ไม่พบ scripts generator ที่ README กล่าวถึง จึงไม่ถือว่าการขาด generator อย่างเดียวทำให้ build ไม่ได้
- ยังไม่ยืนยัน provenance/ใบอนุญาตแยกของ firmware ที่ฝังอยู่ ไม่รวม upstream หรือ firmware ในไฟล์ที่จะ commit ของ repository นี้

MacKernelSDK commit `3f750085caa17ec3a7880f11c11bf4f48cd6a164` ใช้ตาม
[แนวทาง upstream](https://github.com/acidanthera/MacKernelSDK/blob/3f750085caa17ec3a7880f11c11bf4f48cd6a164/README.md)
การมี headers และ libkmod ไม่ได้พิสูจน์ runtime compatibility กับ Sequoia

## สิ่งที่ทำไว้

- `sources.lock.json`: URL และ commit ของ driver/SDK
- `prepare.py`: ตรวจ checkout, PCI match, SDK และขนาด/แฮช firmware; เตรียมสำเนาใหม่ใต้ `work/` เท่านั้น
- `evidence.json`: ผลตรวจ static ของ input ที่ใช้จริง
- `work/baseline-001/`: source workspace พร้อม SDK ที่เตรียมบน Windows; เป็นไฟล์ local ที่ถูก ignore
- `EXPERIMENTS.md`: แยกสิ่งที่ตรวจแล้วออกจาก milestone ที่ยังไม่ทดสอบ

ไม่แก้ upstream checkout ไม่แก้ EFI/config ไม่ส่งข้อมูลเครื่องออกไป และไม่ได้สร้าง binary kext

## ทำซ้ำบน macOS

ต้องมี Xcode, Git และ Python 3.10 ขึ้นไป คัดลอกโฟลเดอร์นี้ไปยังพื้นที่พัฒนา
หากไม่มี `upstream/` ให้ดึงซอร์สและ checkout ตาม lock:

```sh
mkdir -p upstream
git clone https://github.com/laobamac/SimpleMtkWlan.git upstream/SimpleMtkWlan
git -C upstream/SimpleMtkWlan checkout --detach 37ba676ad18273b7e622ec6db45afc25db238109
git clone https://github.com/acidanthera/MacKernelSDK.git upstream/MacKernelSDK
git -C upstream/MacKernelSDK checkout --detach 3f750085caa17ec3a7880f11c11bf4f48cd6a164
python3 prepare.py
python3 prepare.py --prepare work/mac-build-001 --build
```

ใช้ชื่อ output ใหม่ทุกครั้ง สคริปต์ไม่ทับของเดิม ผล build อยู่ใต้
`work/mac-build-001/DerivedData/Build/Products/Debug/` และ log อยู่ที่
`work/mac-build-001/build.log` คำสั่ง build ยังไม่ได้ทดสอบด้วย Xcode ใน session นี้
ถ้าคอมไพล์ไม่ผ่าน ให้ใช้ error จริงเป็นจุดเริ่ม ไม่ตีความว่าผ่านเพราะ static check ผ่าน

## เส้นทางทดลองต่อ

1. Build baseline บน macOS ให้ได้ก่อน เก็บ Xcode/SDK version, `sw_vers` และ `uname -r`
2. ก่อนโหลด kernel: ตรวจ cleanup, DMA/interrupt teardown, error paths และ IOUserClient; การอ่านซอร์สครั้งนี้ยังไม่ใช่ safety audit เต็มรูปแบบ
3. หากต้องการรักษาลำดับ M0 ตาม brief ให้แยก passive probe target ซึ่งอ่าน PCI config/BAR metadata เท่านั้น ไม่มี bus mastering, IRQ handler, MMIO access หรือ HAL attach; target นี้ยังไม่ได้เขียนในงานนี้
4. ทดสอบเฉพาะ USB OpenCore โดยเตรียม candidate แยกและ validate ด้วย ocvalidate release ตรงกับ OpenCore จริง ห้ามเอา baseline นี้ลง Apacer เป็นค่าเริ่มต้น
5. M0 ต้องมีหลักฐาน 10 boots และ clean stop/reboot จากเครื่องจริง; M1–M3 ต้องมี ownership/firmware/scan logs ตามลำดับ การมีฟังก์ชันอยู่ในซอร์สไม่นับว่าผ่าน
6. M4 ต้องเห็น WPA2 association และ 4-way handshake สำเร็จ; M5 ต้องมี DHCP, ping gateway และ traffic 5 นาที; ตรวจ protocol ของ companion app ก่อนอ้างว่าใช้ HeliPort ได้

เก็บ raw log ไว้ local และลบ SSID/BSSID/MAC/serial/UUID/credentials ก่อนแชร์
ยังไม่มี milestone M0–M6 ใดผ่าน acceptance criteria บนเครื่องเป้าหมายจากงานนี้
