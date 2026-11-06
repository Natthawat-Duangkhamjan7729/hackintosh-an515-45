// Minimal Metal throughput benchmark (FP32 FMA and memory copy bandwidth).
// Each dispatch is kept short (tens of ms) because the same GPU drives the display.
// Usage: metalbench [seconds-per-test]   (default 10)
import Metal
import Foundation

let src = """
#include <metal_stdlib>
using namespace metal;
kernel void fma_k(device float4 *out [[buffer(0)]], constant uint &iters [[buffer(1)]], uint id [[thread_position_in_grid]]) {
    float4 a = float4(id * 1e-7f, 1.0f, 0.5f, 0.25f);
    float4 b = float4(0.9999f), c = float4(1e-4f);
    float4 x0 = a, x1 = a + 1.0f, x2 = a + 2.0f, x3 = a + 3.0f;
    for (uint i = 0; i < iters; i++) {
        x0 = fma(x0, b, c); x1 = fma(x1, b, c); x2 = fma(x2, b, c); x3 = fma(x3, b, c);
        x0 = fma(x0, b, c); x1 = fma(x1, b, c); x2 = fma(x2, b, c); x3 = fma(x3, b, c);
    }
    out[id] = x0 + x1 + x2 + x3;
}
kernel void fma8_k(device float *out [[buffer(0)]], constant uint &iters [[buffer(1)]], uint id [[thread_position_in_grid]]) {
    float b = 0.9999f, c = 1e-4f; float s = id * 1e-7f;
    float x0=s,x1=s+1,x2=s+2,x3=s+3,x4=s+4,x5=s+5,x6=s+6,x7=s+7;
    for (uint i = 0; i < iters; i++) {
        x0=fma(x0,b,c);x1=fma(x1,b,c);x2=fma(x2,b,c);x3=fma(x3,b,c);x4=fma(x4,b,c);x5=fma(x5,b,c);x6=fma(x6,b,c);x7=fma(x7,b,c);
        x0=fma(x0,b,c);x1=fma(x1,b,c);x2=fma(x2,b,c);x3=fma(x3,b,c);x4=fma(x4,b,c);x5=fma(x5,b,c);x6=fma(x6,b,c);x7=fma(x7,b,c);
        x0=fma(x0,b,c);x1=fma(x1,b,c);x2=fma(x2,b,c);x3=fma(x3,b,c);x4=fma(x4,b,c);x5=fma(x5,b,c);x6=fma(x6,b,c);x7=fma(x7,b,c);
        x0=fma(x0,b,c);x1=fma(x1,b,c);x2=fma(x2,b,c);x3=fma(x3,b,c);x4=fma(x4,b,c);x5=fma(x5,b,c);x6=fma(x6,b,c);x7=fma(x7,b,c);
    }
    out[id] = x0+x1+x2+x3+x4+x5+x6+x7;
}
kernel void copy_k(device const float4 *src [[buffer(0)]], device float4 *dst [[buffer(1)]], uint id [[thread_position_in_grid]]) {
    dst[id] = src[id];
}
"""

let secs = CommandLine.arguments.count > 1 ? Double(CommandLine.arguments[1])! : 10
guard let dev = MTLCreateSystemDefaultDevice() else { print("no Metal device"); exit(1) }
print("device: \(dev.name)  lowPower=\(dev.isLowPower)  maxThreadsPerTG=\(dev.maxThreadsPerThreadgroup.width)")
let lib = try! dev.makeLibrary(source: src, options: nil)
let q = dev.makeCommandQueue()!
func pso(_ n: String) -> MTLComputePipelineState { try! dev.makeComputePipelineState(function: lib.makeFunction(name: n)!) }
let fmaP = pso("fma_k"), copyP = pso("copy_k"), fma8P = pso("fma8_k")

func run(_ label: String, _ flopsOrBytes: Double, _ unit: String, _ scale: Double, encode: (MTLComputeCommandEncoder) -> Void) {
    var total = 0.0, gpuT = 0.0, n = 0, best = 0.0
    let t0 = Date(); var lastPrint = Date()
    var windowWork = 0.0, windowT = 0.0
    while Date().timeIntervalSince(t0) < secs {
        let cb = q.makeCommandBuffer()!; let e = cb.makeComputeCommandEncoder()!
        encode(e); e.endEncoding(); cb.commit(); cb.waitUntilCompleted()
        if let err = cb.error { print("\(label): command buffer error \(err)"); return }
        let dt = cb.gpuEndTime - cb.gpuStartTime
        if n > 0 { total += flopsOrBytes; gpuT += dt; windowWork += flopsOrBytes; windowT += dt; best = max(best, flopsOrBytes / dt) }
        n += 1
        if Date().timeIntervalSince(lastPrint) >= 2 && windowT > 0 {
            print(String(format: "  %@ t=%4.0fs  %.2f %@  (dispatch %.1f ms)", label, Date().timeIntervalSince(t0), windowWork / windowT / scale, unit, dt * 1000))
            windowWork = 0; windowT = 0; lastPrint = Date()
        }
    }
    print(String(format: "%@: avg %.2f %@, best %.2f %@ over %d dispatches", label, total / gpuT / scale, unit, best / scale, unit, n - 1))
}

// FP32 FMA: threads * iters * 8 fma * 4 lanes * 2 flops
let threads = 3840 * 64, iters: UInt32 = 2048
let outB = dev.makeBuffer(length: threads * 16, options: .storageModePrivate)!
var it = iters
let flops = Double(threads) * Double(iters) * 8 * 4 * 2
run("FP32 FMA", flops, "TFLOPS", 1e12) { e in
    e.setComputePipelineState(fmaP); e.setBuffer(outB, offset: 0, index: 0); e.setBytes(&it, length: 4, index: 1)
    e.dispatchThreads(MTLSize(width: threads, height: 1, depth: 1), threadsPerThreadgroup: MTLSize(width: 256, height: 1, depth: 1))
}

// Scalar FP32 FMA, 8 independent chains (ILP check): threads * iters * 32 fma * 2 flops
let threads8 = 3840 * 256
let out8 = dev.makeBuffer(length: threads8 * 4, options: .storageModePrivate)!
var it8: UInt32 = 1024
run("FP32 FMA scalar x8", Double(threads8) * 1024 * 32 * 2, "TFLOPS", 1e12) { e in
    e.setComputePipelineState(fma8P); e.setBuffer(out8, offset: 0, index: 0); e.setBytes(&it8, length: 4, index: 1)
    e.dispatchThreads(MTLSize(width: threads8, height: 1, depth: 1), threadsPerThreadgroup: MTLSize(width: 256, height: 1, depth: 1))
}

// Copy bandwidth: read + write 256 MiB each
let bytes = 256 << 20
let a = dev.makeBuffer(length: bytes, options: .storageModePrivate)!, b = dev.makeBuffer(length: bytes, options: .storageModePrivate)!
run("Copy BW", Double(bytes) * 2, "GB/s", 1e9) { e in
    e.setComputePipelineState(copyP); e.setBuffer(a, offset: 0, index: 0); e.setBuffer(b, offset: 0, index: 1)
    e.dispatchThreads(MTLSize(width: bytes / 16, height: 1, depth: 1), threadsPerThreadgroup: MTLSize(width: 256, height: 1, depth: 1))
}
