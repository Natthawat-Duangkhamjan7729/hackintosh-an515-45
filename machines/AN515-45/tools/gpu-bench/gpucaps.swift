// Lists hardware video encoders/decoders, then Metal families and features.
// Note: NullMoth registers its VideoToolbox codecs in a process only after that process
// creates a Metal device. This file queries VideoToolbox first, so it reports 0 hardware
// encoders on NullMoth; see vthw.swift for the Metal-first order.
// Build: swiftc -O -o gpucaps gpucaps.swift
import Foundation
import VideoToolbox
import Metal

var list: CFArray?
VTCopyVideoEncoderList(nil, &list)
print("== Video encoders (hardware-accelerated only)")
for e in (list as? [[String: Any]]) ?? [] {
    let hw = (e[kVTVideoEncoderList_IsHardwareAccelerated as String] as? Bool) ?? false
    if hw { print("  HW:", e[kVTVideoEncoderList_DisplayName as String] ?? "?", "codec", e[kVTVideoEncoderList_CodecType as String] ?? "") }
}
let all = (list as? [[String: Any]]) ?? []
print("  total encoders:", all.count, " hardware:", all.filter { ($0[kVTVideoEncoderList_IsHardwareAccelerated as String] as? Bool) == true }.count)
print("== Hardware decode")
for (n, c) in [("H.264", kCMVideoCodecType_H264), ("HEVC", kCMVideoCodecType_HEVC), ("VP9", kCMVideoCodecType_VP9), ("AV1", kCMVideoCodecType_AV1)] as [(String, CMVideoCodecType)] {
    print("  \(n):", VTIsHardwareDecodeSupported(c))
}
if let d = MTLCreateSystemDefaultDevice() {
    print("== Metal:", d.name)
    let fams: [(String, MTLGPUFamily)] = [("Mac2", .mac2), ("Common3", .common3), ("Metal3", .metal3), ("Apple7", .apple7)]
    for (n, f) in fams { print("  family \(n):", d.supportsFamily(f)) }
    // MTLArgumentBuffersTier: raw value 0 = tier 1, 1 = tier 2
    print("  raytracing:", d.supportsRaytracing, " argBufTier(raw):", d.argumentBuffersSupport.rawValue, " readWriteTexTier(raw):", d.readWriteTextureSupport.rawValue)
    print("  recommendedMaxWorkingSet MB:", d.recommendedMaxWorkingSetSize >> 20, " maxBuffer MB:", d.maxBufferLength >> 20, " unified:", d.hasUnifiedMemory, " removable:", d.isRemovable, " headless:", d.isHeadless)
    print("  bc texture:", d.supportsBCTextureCompression, " 32bit float filtering:", d.supports32BitFloatFiltering, " shader barycentric:", d.supportsShaderBarycentricCoordinates)
    print("  all devices:", MTLCopyAllDevices().map { $0.name })
}
