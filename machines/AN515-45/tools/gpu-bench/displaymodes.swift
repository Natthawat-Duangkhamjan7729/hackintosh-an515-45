// Lists online displays, the current mode and every available mode with its refresh rate.
// Build: swiftc -O -o displaymodes displaymodes.swift
import CoreGraphics

var n: UInt32 = 0
CGGetOnlineDisplayList(0, nil, &n)
var ids = [CGDirectDisplayID](repeating: 0, count: Int(n))
CGGetOnlineDisplayList(n, &ids, &n)
for d in ids {
    print("display \(d): builtin=\(CGDisplayIsBuiltin(d) != 0) main=\(CGDisplayIsMain(d) != 0) size(mm)=\(CGDisplayScreenSize(d))")
    if let cur = CGDisplayCopyDisplayMode(d) {
        print("  current: \(cur.width)x\(cur.height) @\(cur.refreshRate)Hz pixels \(cur.pixelWidth)x\(cur.pixelHeight)")
    }
    let opts = [kCGDisplayShowDuplicateLowResolutionModes: true] as CFDictionary
    var seen = Set<String>()
    for m in (CGDisplayCopyAllDisplayModes(d, opts) as? [CGDisplayMode]) ?? [] {
        let k = "\(m.pixelWidth)x\(m.pixelHeight)@\(Int(m.refreshRate.rounded()))"
        if seen.insert(k).inserted { print("  mode \(k)\(m.pixelWidth != m.width ? " (HiDPI)" : "")") }
    }
}
