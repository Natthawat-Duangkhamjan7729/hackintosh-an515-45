# Diagnostic SSDTs (not for daily use)

These tables were used on 2026-11-06 to find what held the CPU at ~35 W on AC. Each one replaces `SSDT-PWRL.aml` for one boot; do not load two of them together. The working table is `../SSDT-PWRL.dsl` (v2). Results are in `../../../docs/PROGRESS-2026-11.md`.

| Table | OEM table id | What it does | Result on AC |
|---|---|---|---|
| `SSDT-PWRL-DIAG20` | PWRLD20 | STAPM/slow/fast = 20 W, no AC check | 19.5 W: the `\CDPC` -> ALIB path works |
| `SSDT-PWRL-NOAC` | PWRLNOAC | STAPM/slow/fast = 45/45/54 W, no AC check | still ~34 W: another limit |
| `SSDT-PWRL-NOAC2` | PWRLNOA2 | NOAC + ALIB 0x13 (APU slow) and 0x2E (STT power) = 45 W, no AC check | 43.9 W sustained |

All of them need the DSDT patch `_Q20` -> `XQ20`, and they apply on battery too because there is no AC check.
