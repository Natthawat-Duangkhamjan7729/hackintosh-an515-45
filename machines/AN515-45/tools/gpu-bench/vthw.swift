// Decodes up to 600 frames of a movie through a VTDecompressionSession that requires a
// hardware decoder, and reports fps and process CPU time.
// Creates a Metal device first, because NullMoth registers its decoders only after that.
// Build: swiftc -O -o vthw vthw.swift     Run: ./vthw <movie>
import AVFoundation
import VideoToolbox
import Metal

_ = MTLCreateSystemDefaultDevice()
let url = URL(fileURLWithPath: CommandLine.arguments[1])
let asset = AVURLAsset(url: url)
let sem = DispatchSemaphore(value: 0); var track: AVAssetTrack?
Task { track = try? await asset.loadTracks(withMediaType: .video).first; sem.signal() }; sem.wait()
guard let t = track else { print("no video track"); exit(1) }
let fmt = (t.formatDescriptions as! [CMFormatDescription]).first!
let codec = CMFormatDescriptionGetMediaSubType(fmt)
let dims = CMVideoFormatDescriptionGetDimensions(fmt)
print("codec \(String(format: "%c%c%c%c", (codec >> 24) & 255, (codec >> 16) & 255, (codec >> 8) & 255, codec & 255)) \(dims.width)x\(dims.height)")

let reader = try! AVAssetReader(asset: asset)
let out = AVAssetReaderTrackOutput(track: t, outputSettings: nil)   // compressed samples
reader.add(out); reader.startReading()

var session: VTDecompressionSession?
let spec = [kVTVideoDecoderSpecification_RequireHardwareAcceleratedVideoDecoder: true] as CFDictionary
let attrs = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] as CFDictionary
let st = VTDecompressionSessionCreate(allocator: nil, formatDescription: fmt, decoderSpecification: spec,
                                      imageBufferAttributes: attrs, outputCallback: nil, decompressionSessionOut: &session)
guard st == 0, let s = session else { print("hardware-required session failed: \(st)"); exit(1) }
var usingHW: CFTypeRef?
VTSessionCopyProperty(s, key: kVTDecompressionPropertyKey_UsingHardwareAcceleratedVideoDecoder, allocator: nil, valueOut: &usingHW)
print("UsingHardwareAcceleratedVideoDecoder: \(String(describing: usingHW))")

var done = 0, errs = 0
let c0 = clock(); let w0 = Date(); var n = 0
while n < 600, let sb = out.copyNextSampleBuffer() {
    if CMSampleBufferGetNumSamples(sb) == 0 { continue }
    n += 1
    VTDecompressionSessionDecodeFrame(s, sampleBuffer: sb, flags: [._EnableAsynchronousDecompression], infoFlagsOut: nil) { status, _, img, _, _ in
        if status == 0 && img != nil { done += 1 } else { errs += 1 }
    }
}
VTDecompressionSessionWaitForAsynchronousFrames(s)
let wall = Date().timeIntervalSince(w0); let cpu = Double(clock() - c0) / Double(CLOCKS_PER_SEC)
print(String(format: "submitted %d, decoded %d, errors %d in %.2f s = %.0f fps; process CPU %.2f s", n, done, errs, wall, Double(done) / wall, cpu))
