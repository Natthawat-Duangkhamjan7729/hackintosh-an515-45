# การส่งภาพข้าม GPU บน macOS — มีอยู่จริงหรือไม่

ตรวจเมื่อ 2026-10-12 · **แก้ไขครั้งใหญ่ 2026-10-13 หลังการรีวิว** · สถานะ: **งานวิจัยเอกสาร ยังไม่ได้ทดสอบบนเครื่องแม้แต่ข้อเดียว**

คำถามตั้งต้น: เป้าหมายระยะยาวคือให้ RTX 3060 Laptop เรนเดอร์แล้วภาพออกจอในตัว
ซึ่งต่อกับ Vega iGPU (เครื่องนี้ไม่มี MUX switch) — macOS มีกลไกรองรับหรือไม่

> **บันทึกการแก้ไข 2026-10-13:** ฉบับแรกของเอกสารนี้ตีความเอกสาร Apple เกินจริงหลายจุด
> และอ้างคำพูดผิดหน้า การรีวิวจับได้และแก้แล้วด้านล่าง รวมถึงเพิ่มอุปสรรคสองข้อที่ฉบับแรกมองข้าม
> และข้อเท็จจริงเรื่องเวอร์ชัน macOS ที่ทำให้เส้นทางนี้ถูกปิดอยู่ในขณะนี้

---

## ข้อสรุปสั้น

กลไกคัดลอกเฟรมข้าม GPU **มีอยู่จริงในชั้น presentation ของ macOS** — ข้อนี้ยืนยันได้จากเอกสาร Apple
แต่ **ไม่ได้แปลว่าเส้นทางนี้ใช้กับเครื่องเราได้** และตอนนี้ถูกปิดด้วยเหตุผลที่ง่ายกว่าเรื่องเทคนิคมาก
คือ **เวอร์ชัน macOS ไม่ตรงกัน** (ดูหัวข้อ "ตัวปิดเส้นทางที่ใหญ่ที่สุด")

---

## สิ่งที่เอกสาร Apple พูดจริง ๆ

แหล่ง: *Selecting device objects for graphics rendering* (metadata ระบุ macOS 10.13.0 ขึ้นไป)
หน้านี้เป็น **บทความประกอบ sample code** ไม่ใช่เอกสารสถาปัตยกรรม

**ข้อความหลัก** อยู่ในหัวข้อ *Drawables, displays, and GPUs* — อยู่ในเนื้อหาจริง:

> "If your app renders with a GPU that isn't driving your view's display, the system needs to copy
> the drawable from the rendering GPU to the displaying GPU before presenting it. This transfer can
> be expensive because the bandwidth between GPUs is limited by the bus that connects them. This
> expense is more severe with external GPUs because their Thunderbolt 3 bus has much less bandwidth
> than an internal PCI Express bus."

**ข้อความเรื่อง discrete → integrated → built-in display** มาจาก **alt text ของรูปไดอะแกรม**
(`FastestDrawablePath_BuiltIn.png`) ไม่ใช่ย่อหน้าหลักของหน้า:

> "The not recommended pathway renders a drawable with a discrete GPU and transfers it to an
> integrated GPU before presenting it on a built-in display."

### บริบทที่ต้องติดมาด้วยเสมอ

- หน้านี้เขียนสำหรับ **MacBook Pro ที่มี Automatic Graphics Switching** คือเครื่อง **muxed**
  และใช้ **ไดรเวอร์ของ Apple เอง** ทั้งสองฝั่ง
- กรณีในรูปคือช่วงที่ iGPU กำลังขับจอในตัวอยู่ ไม่ใช่เครื่อง muxless
- หน้านี้ **ไม่พูดถึงไดรเวอร์บุคคลที่สาม** และ **ไม่ได้อธิบายว่าการคัดลอกเกิดที่ชั้นไหน**
- ประโยคเรื่อง Thunderbolt กับ PCIe เป็นแค่ **การเทียบ bandwidth** — ฉบับแรกของเอกสารนี้
  ตีความว่า "Apple ถือว่าการคัดลอกผ่าน PCIe ภายในเป็นกรณีปกติ" ซึ่ง **เกินกว่าที่ข้อความบอก**

**คำพูด "either GPU can drive the built-in display"** ไม่ได้อยู่ในหน้าข้างบน แต่อยู่ในหน้า
*Assessing multi-GPU and multidisplay setups on an Intel-based Mac* ซึ่งเป็นคนละหน้า
ฉบับแรกอ้างรวมในตารางเดียวโดยไม่แยกที่มา — แก้แล้ว

---

## ตัวปิดเส้นทางที่ใหญ่ที่สุด (ใหม่ 2026-10-13)

| รายการ | ค่า |
| --- | --- |
| เป้าหมายปัจจุบันของโปรเจกต์ | **macOS Tahoe 26.7.1 (build 25G241)** ตาม `TARGET.json` |
| ไดรเวอร์ `nullmoth/nvidia-macos-driver` รองรับ | **macOS 15 Sequoia เท่านั้น** (README ระบุทดสอบบน 15.7.x และ 15.8.1) |

**บนเป้าหมายปัจจุบัน ไดรเวอร์ NVIDIA ใช้ไม่ได้เลย** ไม่ใช่เรื่อง "ยังไม่ได้ทดสอบ"
แต่คือคนละเวอร์ชัน OS ดังนั้นการทดลอง dGPU ทุกอย่างต้องเลือกอย่างใดอย่างหนึ่ง:

1. รอให้ไดรเวอร์รองรับ macOS 26 (ไม่มีกำหนด ไม่อยู่ในมือเรา)
2. ทำ candidate แยกที่ยังอยู่บน Sequoia 15.8.1 เพื่อการทดลองนี้โดยเฉพาะ

ข้อนี้ควรตัดสินใจก่อนลงแรงกับเรื่องอื่น เพราะมันเปลี่ยนว่าแผนทั้งหมดคุ้มหรือไม่

---

## อุปสรรคที่ฉบับแรกมองข้าม

### 1. แนวทางของ Apple เองจะทำให้แอปไม่เลือก RTX

sample code หน้าเดียวกันแนะนำให้แอปเรียก `CGDirectDisplayCopyCurrentMetalDevice()`
เพื่อหา GPU ที่ขับจออยู่ แล้วเรนเดอร์ด้วยตัวนั้น — **ซึ่งจะได้ Vega เสมอ**
แอปที่ทำตามแนวทาง Apple จึง **ไม่เลือก RTX โดยธรรมชาติ** และไม่มีสวิตช์ระดับระบบมาบังคับ
"Prefer External GPU" ก็มีเฉพาะ GPU ที่เป็น external/removable เท่านั้น

นี่คืออุปสรรคเชิงโครงสร้าง ไม่ใช่แค่เรื่องไดรเวอร์

### 2. SSDT-Acer-NoHybGfx อาจเป็นตัวที่ทำให้ sleep ทำงาน

การปิด SSDT ตัวนี้เพื่อให้เห็น dGPU อาจทำให้ sleep/wake พัง
ต้องถือว่าเป็นการแลก ไม่ใช่การ "ปิดสวิตช์ที่ไม่ใช้"

### 3. ต้องเป็น Metal device ที่ทำงานได้ทั้งสองฝั่ง

ไม่ใช่แค่ RTX — **Vega ต้องเป็น Metal device ที่ทำงานจริงผ่าน NootedRed ด้วย**
เพราะเป็นปลายทางที่รับเฟรม ถ้าฝั่งรับไม่พร้อม เส้นทางก็ไม่มีปลายทาง

และ **ไม่มีเอกสารใดรับประกันว่าการคัดลอกจะทำงานระหว่างไดรเวอร์บุคคลที่สามสองตัว**

---

## เงื่อนไขก่อนพิจารณาสร้าง candidate (G1–G4)

ทุกข้ออ่านอย่างเดียว รันบน boot ปัจจุบันได้ ไม่แตะ EFI หรือ ESP
**ต้องผ่าน G1–G3 ครบทุกข้อ** ถ้าข้อไหนไม่ผ่านให้หยุด ไม่ต้องสร้าง candidate

| รหัส | ตรวจอะไร | เกณฑ์ผ่าน |
| --- | --- | --- |
| **G1** | macOS เห็น dGPU บนบัส PCI และได้ device-id | พบรายการ vendor-id ของ NVIDIA ใน `ioreg -l -w0 -r -c IOPCIDevice` และจด device-id ได้ (ตอนนี้ SSDT สั่งปิดอยู่ ถ้าไม่เจอให้ดู device-id จากฝั่ง Windows แทน **ห้ามแก้ EFI เพื่อให้เจอ**) |
| **G2** | Vega เป็น Metal device ที่ใช้งานได้ (ฝั่งรับเฟรม) | Vega อยู่ใน `MTLCopyAllDevices()` และมี Metal Support ใน `system_profiler SPDisplaysDataType` |
| **G3** | ไดรเวอร์รองรับ device-id จาก G1 บน **เวอร์ชัน macOS ที่เราจะใช้จริง** | README หรือโค้ดระบุ device-id นั้นหรือ GA106 Laptop พร้อมเวอร์ชัน macOS ที่ชัดเจน — **"อาจจะใช้ได้" ไม่นับว่าผ่าน** |
| **G4** | พอร์ต HDMI ต่อกับ GPU ตัวไหน (ไม่ใช่เงื่อนไขผ่าน/ไม่ผ่าน แต่บอกว่าจะทดลองเส้นทางไหน) | เสียบจอนอกแล้วดู `system_profiler SPDisplaysDataType` — ถ้าจอนอกขึ้นใต้ Vega แปลว่า HDMI ต่อกับ iGPU |

สคริปต์ลิสต์ Metal device สำหรับ G2:

```swift
import Metal
for d in MTLCopyAllDevices() {
  print(d.name, "loc=\(d.location.rawValue)", "headless=\(d.isHeadless)",
        "lowPower=\(d.isLowPower)", "removable=\(d.isRemovable)")
}
```

**ผ่าน G1–G3 ครบ = คุ้มที่จะออกแบบ candidate เท่านั้น ไม่ใช่การอนุมัติให้แก้ EFI**
candidate ต้องอยู่ใน `candidates/` แยกจาก ESP ที่ใช้งานอยู่
และต้องแก้ปัญหา SMBIOS ที่ขัดกันก่อน (NootedRed ต้องใช้ MacBookPro16,2 ส่วนไดรเวอร์ NVIDIA ทดสอบบน iMacPro1,1)

---

## สรุปที่ปรับแล้ว

สิ่งที่เคยคิดว่าเป็นกำแพง — "macOS แสดงภาพที่เรนเดอร์บน GPU อื่นไม่ได้เลย" — **ตัดทิ้งได้**
เส้นทางนี้มีอยู่ในชั้น presentation ของ macOS และ RTX ไม่จำเป็นต้องขับจอเอง

แต่กำแพงที่เหลือมีมากกว่าที่ฉบับแรกเขียนไว้ และกำแพงที่ใกล้ที่สุดไม่ใช่เรื่องเทคนิคเลย
คือ **เป้าหมายโปรเจกต์อยู่บน Tahoe 26.7.1 ส่วนไดรเวอร์อยู่บน Sequoia 15** — คนละเวอร์ชันกัน

ขั้นถัดไปคือตัดสินใจเรื่องเวอร์ชันก่อน แล้วค่อยเก็บหลักฐาน G1–G4 **ยังไม่ใช่การเขียนโค้ดหรือแก้ EFI**

---

## แหล่งอ้างอิง (ตรวจ 2026-10-12 / 2026-10-13)

- Apple — Metal: *Selecting device objects for graphics rendering* (availability: macOS 10.13.0 –)
  https://developer.apple.com/documentation/Metal/selecting-device-objects-for-graphics-rendering
  หน้า HTML ต้องใช้ JavaScript — ดึงเนื้อหาจริงด้วยการต่อท้าย `.md`
  (ประโยค copy drawable อยู่ในเนื้อหา · ข้อความ discrete → integrated อยู่ใน alt text ของรูป)
- Apple — Metal: *Assessing multi-GPU and multidisplay setups on an Intel-based Mac*
  https://developer.apple.com/documentation/Metal/assessing-multi-gpu-and-multi-display-setups-on-an-intel-based-mac
  (ที่มาของ "either GPU can drive the built-in display")
- Apple — Metal: *Multi-GPU systems*
  https://developer.apple.com/documentation/metal/multi-gpu-systems
- Apple Support — *Use an external graphics processor with your Mac*
  https://support.apple.com/en-us/102363
- https://github.com/nullmoth/nvidia-macos-driver — รองรับ macOS 15 Sequoia เท่านั้น
- `staging/AN515-45-Tahoe/TARGET.json` — เป้าหมายปัจจุบัน Tahoe 26.7.1 build 25G241

**ยังไม่มีการทดสอบบนเครื่องจริงแม้แต่ข้อเดียว** ทุกข้อสรุปข้างบนเป็นสมมติฐานที่รอการพิสูจน์
