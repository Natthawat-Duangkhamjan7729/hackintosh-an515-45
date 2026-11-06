# CPU measurement tools (macOS, AMD)

Read-only tools used on 2026-11-06 to measure CPU clocks and power on Tahoe.

- `amdread.c` reads AMDRyzenCPUPowerManagement (SMCAMDProcessor 0.7.2f1) through its user client. It calls only read selectors: 1 (P-state clocks), 4 (package power, temperature, P-state, per-core effective clock), 11 (CPB), 13 (PPM), 18 (LPM). Build: `clang -O2 -o amdread amdread.c -framework IOKit -framework CoreFoundation`. Run: `./amdread <samples> <interval-seconds>`.
- `scale.py <path-to-amdread>` runs a SHA-256 load with 1/2/4/8/16 processes for 6 s each and samples clocks/power during each run.
- `load.py <procs> <seconds>` runs a fixed SHA-256 load and prints total MiB/s; run `amdread` beside it.

Run Python with `python3 -I`. Results are in `../../docs/PROGRESS-2026-10-09.md`.
