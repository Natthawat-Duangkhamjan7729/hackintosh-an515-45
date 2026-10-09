# Experiment ledger

| Experiment | Change/input | Observation | Conclusion |
| --- | --- | --- | --- |
| E00 | Read supplied brief; search primary upstream | Public SimpleMtkWlan source targets PCI 14c3:7961 | Reassess greenfield driver assumption |
| E01 | Pin driver and SDK; run prepare.py | PCI match, SDK files, two embedded firmware sizes/hashes verified | Static inputs consistent; not a build result |
| E02 | Prepare work/baseline-001 | Fresh copy with four header-path substitutions and pinned SDK | Build workspace prepared; upstream unchanged |
| E03 | Compare all tracked upstream driver files with prepared copy; exercise guards | Only intended project file differs; exact replacement verified; existing/outside-work destinations rejected; Windows build exits 2 | Preparation checks pass; both upstream checkouts remain clean |

## Hardware acceptance (all pending)

| Milestone | Evidence required | Status |
| --- | --- | --- |
| M0 | PCI attach + BAR/IRQ log + clean lifecycle + 10 boots without panic | Not tested |
| M1 | Valid chip/revision and ownership handshake | Not tested |
| M2 | Firmware starts and reports version | Not tested |
| M3 | Scan results with channel/RSSI; identifiers redacted before sharing | Not tested |
| M4 | WPA2 association and completed 4-way handshake | Not tested |
| M5 | DHCP, gateway ping, five-minute transfer | Not tested |
| M6 | Native Wi-Fi menu integration | Out of initial scope |

For each future experiment record source commit/patch, firmware hashes, Xcode and
macOS/Darwin versions, kext binary hash, USB candidate identifier, one change,
expected observation, actual result, redacted log location, and next hypothesis.
Keep credentials and personal device identifiers out of this ledger.
