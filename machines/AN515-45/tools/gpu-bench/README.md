# GPU measurement tool (macOS, Metal)

`metalbench.swift` measures, on the default Metal device:

- FP32 FMA throughput with a float4 kernel (4 chains) and a scalar kernel (8 independent chains);
- copy bandwidth over two 256 MiB private buffers (read + write counted).

Each dispatch takes roughly 2–12 ms, because the same GPU drives the display. Timing uses `gpuStartTime`/`gpuEndTime`.

Build: `swiftc -O -o metalbench metalbench.swift`. Run: `./metalbench <seconds-per-test>`.

GPU temperature and utilization come from `ioreg -r -c NVAccel -l -d1` (`PerformanceStatistics`). NullMoth 2.7.2 exposes no clock or power values. Results are in `../../docs/PROGRESS-2026-10-09.md`.
