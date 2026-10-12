# การส่งภาพข้าม GPU บน macOS — มีอยู่จริงหรือไม่

ตรวจเมื่อ 2026-10-12 · สถานะ: **งานวิจัยเอกสาร ยังไม่ได้ทดสอบบนเครื่อง**

คำถามตั้งต้น: เป้าหมายระยะยาวคือให้ RTX 3060 Laptop เรนเดอร์แล้วภาพออกจอในตัว
ซึ่งต่อกับ Vega iGPU (เครื่องนี้ไม่มี MUX switch) — macOS มีกลไกรองรับหรือไม่

---

## ข้อสรุป

**มี** และเป็นกลไกที่ Apple เขียนไว้ในเอกสาร Metal อย่างชัดเจน ไม่ใช่การเดา

เอกสาร Metal หัวข้อ *Selecting device objects for graphics rendering* (ระบุ macOS 10.13.0 ขึ้นไป) เขียนว่า:

> "If your app renders with a GPU that isn't driving your view's display, the system needs to copy
> the drawable from the rendering GPU to the displaying GPU before presenting it. This transfer can
> be expensive because the bandwidth between GPUs is limited by the bus that connects them. This
> expense is more severe with external GPUs because their Thunderbolt 3 bus has much less bandwidth
> than an internal PCI Express bus."

และไดอะแกรมในหน้าเดียวกันระบุเส้นทางหนึ่งไว้ตรง ๆ ว่า:

> "The not recommended pathway renders a drawable with a discrete GPU and transfers it to an
> integrated GPU before presenting it on a built-in display."

เส้นทาง dGPU → คัดลอก → iGPU → จอในตัว **คือสิ่งเดียวกับที่ muxless rendering ต้องการ**
Apple ไม่แนะนำเพราะช้า แต่ไม่ได้บอกว่าทำไม่ได้ — ระบบรองรับและจัดการ copy ให้เอง

ที่สำคัญกว่านั้น: ประโยค "more severe with external GPUs ... than an internal PCI Express bus"
แปลว่า Apple ถือว่าการคัดลอกข้าม GPU **ผ่าน PCIe ภายในเครื่อง** เป็นกรณีปกติและเร็วกว่า eGPU
ซึ่งตรงกับสถานการณ์ของเครื่องนี้พอดี

---

## แก้ความเข้าใจผิดที่เคยบันทึกไว้

ก่อนหน้านี้ในการสนทนามีการสรุปว่า "macOS ไม่มีกลไก muxless เลย" — **ไม่ถูกต้อง**
ที่ถูกคือ macOS ไม่มี *Optimus* ในความหมายของ Windows คือไม่มีสวิตช์ระดับระบบที่ทำให้
ทุกอย่างรันบน dGPU โดยอัตโนมัติ แต่กลไก **คัดลอกเฟรมข้าม GPU มาออกจอของอีกตัว มีอยู่จริง**
และทำงานในระดับแอป (ต่อ MTLDevice) ไม่ใช่ระดับทั้งเดสก์ท็อป

ความต่างนี้สำคัญ เพราะสิ่งที่คนส่วนใหญ่ต้องการจริง ๆ คือ "ให้เกม/แอปหนักรันบน dGPU"
ซึ่งเป็นระดับแอป ไม่ใช่ทั้งระบบ

---

## สิ่งที่ Apple รองรับ และไม่รองรับ

| กรณี | สถานะตามเอกสาร Apple |
| --- | --- |
| แอปเรนเดอร์บน GPU ที่ไม่ได้ขับจอ แล้วระบบคัดลอกเฟรมไปให้ GPU ที่ขับจอ | **รองรับ** (ช้ากว่า แต่ทำงาน) |
| Mac ที่มี iGPU + dGPU ในตัว | "either GPU can drive the built-in display" — **Mac จริงมี MUX** |
| eGPU ขับจอในตัว | **ไม่ได้** แต่ "accelerate apps on any display connected to the Mac" ได้ |
| eGPU | ต้อง Intel Mac + Thunderbolt 3 + 10.13.4 ขึ้นไป |
| การ์ดที่รองรับ eGPU | Apple ลงเฉพาะ AMD Radeon และระบุว่า "only graphics cards that use the same GPU architecture as those built into Mac products are supported" |

**จุดที่ต้องเข้าใจให้ตรง:** MacBook Pro สองการ์ดของจริงเป็นเครื่อง **muxed** — dGPU ขับจอในตัวได้เอง
เครื่องเราทำไม่ได้ ดังนั้นเราไม่ได้อยู่ในกรณีที่ Apple ออกแบบไว้ แต่เราอยู่ในกรณี
"เรนเดอร์ที่หนึ่ง แสดงผลอีกที่หนึ่ง" ซึ่งเป็นกรณีที่ Apple รองรับ

---

## ช่องว่างที่เหลือจริง ๆ

กลไกคัดลอกเฟรมไม่ใช่ปัญหา — มันมีอยู่แล้ว ช่องว่างคือสามข้อนี้

| # | ช่องว่าง | ความยาก | สถานะ |
| --- | --- | --- | --- |
| A | RTX 3060 ต้องถูก macOS รู้จักเป็น Metal device ที่ใช้งานได้ | สูง แต่**มีคนทำแล้ว** | ไดรเวอร์ `nullmoth/nvidia-macos-driver` — ยังไม่ทดสอบบนการ์ดโน้ตบุ๊ก/Ampere/แพลตฟอร์ม AMD |
| B | dGPU ที่ไม่มีจอต่อ (headless) ต้องถูกยอมรับและเลือกใช้ได้ | กลาง | ยังไม่ทดสอบ — ดูข้อสังเกตด้านล่าง |
| C | ต้องมีวิธีให้แอปหรือระบบเลือก dGPU | กลาง | "Prefer External GPU" มีเฉพาะ GPU ที่เป็น external/removable เท่านั้น |

### ข้อสังเกตเรื่อง headless (ข้อ B)

วงการ Hackintosh ใช้ GPU แบบ headless เป็นเรื่องปกติอยู่แล้ว — การตั้ง iGPU ของ Intel
เป็น headless เพื่อใช้ QuickSync ขณะที่ dGPU ขับจอ เป็นสูตรที่ใช้กันมานาน
แปลว่า macOS ยอมรับ GPU ที่ไม่มีจอต่อแล้วยังรับงานได้ — **ของเราคือการกลับทิศของสูตรเดียวกัน**
ไม่ใช่เรื่องที่ไม่เคยมีใครทำในเชิงโครงสร้าง

### ข้อสังเกตเรื่องการเลือก GPU (ข้อ C)

Metal มี property `MTLDeviceLocation` (built-in / slot / external / unspecified) และ
`isRemovable`, `isHeadless`, `isLowPower` คำถามวิจัยคือ:
dGPU ภายในที่ถูกมองเป็น `external` จะปลดล็อกตัวเลือก "Prefer External GPU" ให้ผู้ใช้ได้หรือไม่
และ DeviceProperties ของ OpenCore มีผลต่อค่าเหล่านี้แค่ไหน — **ยังไม่มีคำตอบ ต้องทดลอง**

---

## การทดลองที่ถูกที่สุดถัดไป (ไม่ต้องเขียนโค้ด)

ทำบน macOS ที่บูตอยู่ตอนนี้ได้เลย ไม่ต้องแก้ EFI

1. `ioreg -l | grep -i -A5 "PEGP\|GPP0"` — ตอนนี้ macOS มองเห็น dGPU เป็นอะไร
   มี IOAccelerator node ขึ้นไหม หรือเป็นแค่ PCI device เฉย ๆ
2. `system_profiler SPDisplaysDataType` — ระบบรายงาน GPU กี่ตัว
3. ลิสต์ Metal device ทั้งหมด (โค้ด Swift ไม่กี่บรรทัดเรียก `MTLCopyAllDevices()`
   แล้วพิมพ์ `name`, `location`, `isHeadless`, `isRemovable`)
4. ยืนยันว่าพอร์ต HDMI เดินจาก GPU ตัวไหน (ตรวจจากฝั่ง Windows)

ข้อ 1–3 ตอบว่า "ตอนนี้เราอยู่ตรงไหนของเส้นทาง" ข้อ 4 ตัดสินว่าแนวทางจอนอกยังเปิดอยู่ไหม

**หมายเหตุ:** `SSDT-Acer-NoHybGfx` ที่เปิดอยู่ใน EFI ปัจจุบันพยายามสั่งปิด dGPU
ถ้าจะเดินเส้นทางนี้ ต้องปิด SSDT ตัวนั้นใน candidate แยก (ห้ามแตะ ESP ที่ใช้งานได้)

---

## ความเสี่ยงเชิงกลยุทธ์

- **Intel macOS กำลังหมดอายุ** Apple เดินไปทาง Apple Silicon เต็มตัว หน้าต่างที่ทำแล้วได้ใช้จริงแคบลงทุกปี
- eGPU ไม่รองรับบน Apple Silicon เลย และ Apple ระบุว่าไดรเวอร์ GPU จากบุคคลที่สามไม่ compatible
- เส้นทางนี้ต้องให้ไดรเวอร์บุคคลที่สามสองตัว (NootedRed + NVIDIA) ทำงานร่วมกัน
  ในเส้นทางที่ Apple ออกแบบไว้ให้ไดรเวอร์ของตัวเอง
- SMBIOS ที่ NootedRed ต้องการ (MacBookPro16,2) ขัดกับที่ไดรเวอร์ NVIDIA ทดสอบไว้ (iMacPro1,1)

---

## สรุปสำหรับคนที่อ่านต่อ

สิ่งที่คิดว่าเป็นกำแพง (macOS ส่งภาพข้าม GPU ไม่ได้) **ไม่ใช่กำแพง** — Apple ทำไว้แล้ว
กำแพงจริงอยู่ที่ไดรเวอร์ NVIDIA ต้องทำงานบนฮาร์ดแวร์ชุดนี้ก่อน ซึ่งเป็นงานที่มีคนเริ่มแล้ว
และเราช่วยได้ด้วยการเป็นเคสทดสอบ ไม่ต้องเขียนไดรเวอร์เอง

ขั้นถัดไปที่ควรทำคือเก็บหลักฐานจากเครื่องจริง (ข้อ 1–4 ข้างบน) ไม่ใช่เขียนโค้ด

---

## แหล่งอ้างอิง (ตรวจ 2026-10-12)

- Apple — Metal: Selecting device objects for graphics rendering
  https://developer.apple.com/documentation/Metal/selecting-device-objects-for-graphics-rendering
  (ระบุ availability macOS 10.13.0 ขึ้นไป) — ประโยคเรื่อง copy drawable ข้าม GPU
- Apple — Metal: Assessing multi-GPU and multidisplay setups on an Intel-based Mac
  https://developer.apple.com/documentation/Metal/assessing-multi-gpu-and-multi-display-setups-on-an-intel-based-mac
- Apple — Metal: Multi-GPU systems
  https://developer.apple.com/documentation/metal/multi-gpu-systems
- Apple Support — Use an external graphics processor with your Mac
  https://support.apple.com/en-us/102363
- https://github.com/nullmoth/nvidia-macos-driver — ไดรเวอร์ NVIDIA Metal สำหรับ macOS 15

เอกสารนี้เป็นการอ่านเอกสารทางการ **ยังไม่มีการทดสอบบนเครื่องจริงแม้แต่ข้อเดียว**
ทุกข้อสรุปข้างบนเป็นสมมติฐานที่รอการพิสูจน์
