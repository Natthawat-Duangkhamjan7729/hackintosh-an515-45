# GPU measurement tool (macOS, Metal)

`metalbench.swift` measures, on the default Metal device:

- FP32 FMA throughput with a float4 kernel (4 chains) and a scalar kernel (8 independent chains);
- copy bandwidth over two 256 MiB private buffers (read + write counted).

Each dispatch takes roughly 2–12 ms, because the same GPU drives the display. Timing uses `gpuStartTime`/`gpuEndTime`.

Build: `swiftc -O -o metalbench metalbench.swift`. Run: `./metalbench <seconds-per-test>`.

GPU temperature and utilization come from `ioreg -r -c NVAccel -l -d1` (`PerformanceStatistics`). NullMoth 2.7.2 exposes no clock or power values. Results are in `../../docs/PROGRESS-2026-10-09.md`.

Other tools (2026-11-07):

- `gpucaps.swift`: hardware video encoders and decoders, then Metal families and features. NullMoth registers its VideoToolbox codecs inside a process only after that process creates a Metal device, so call `MTLCreateSystemDefaultDevice()` before querying VideoToolbox (in this file the encoder list is queried first, so it reports 0 hardware encoders; see `vthw.swift`).
- `vthw.swift <movie>`: creates a Metal device, then decodes up to 600 frames through a VTDecompressionSession that requires hardware. It reports fps and process CPU time.
- `displaymodes.swift`: online displays and their modes and refresh rates.
