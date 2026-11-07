/*
 * SSDT-PWRL-NOAC2: DIAGNOSTIC ONLY. NOAC plus APU slow limit (ALIB 0x13) and STT power
 * limit (ALIB 0x2E) at 45 W, called through \_SB.ALIB directly (0x13 is not in \CDPC).
 * Base: 45/45/54 W STAPM/slow/fast under macOS
 * on AC and battery, to test whether the SMU accepts limits above ~35 W (DIAG20 showed the path works).
 * Derived from SSDT-PWRL (same objects); do not use both tables together.
 *
 * Original SSDT-PWRL description:
 *
 * Firmware path (DSDT, AN515-45): the EC raises query _Q20 and the DSDT
 * method \CDPC (func, watts) passes the EC's values to \_SB.ALIB (0x0C):
 *   func 0x05 = STAPM limit, 0x07 = slow PPT, 0x06 = fast PPT, 0x03 = Tctl limit.
 * Measured on 2026-11-06 under macOS on AC: package power flat at ~34 W while
 * Tctl was 71-74 C, i.e. a power limit, not a thermal one.
 *
 * This table:
 *  - replaces EC0._Q20 (the DSDT copy must be renamed _Q20 -> XQ20, DSDT only):
 *    it first runs the original XQ20 (EC values), then on AC applies the targets.
 *  - applies the targets once at boot from \_SB.PWRL._INI when on AC.
 * On battery the EC values stay unchanged. The Tctl limit (func 0x03) is never touched.
 * Targets are inside AMD's 35-54 W cTDP range for the Ryzen 7 5800H.
 */
DefinitionBlock ("", "SSDT", 2, "ACER", "PWRLNOA2", 0x00001000)
{
    External (\CDPC, MethodObj)                           // 2 Arguments
    External (\DPMX, MutexObj)
    External (_SB_.ALIB, MethodObj)                       // 2 Arguments
    External (_SB_.PCI0.LPC0.ACAD._PSR, MethodObj)        // 0 Arguments
    External (_SB_.PCI0.LPC0.EC0_, DeviceObj)
    External (_SB_.PCI0.LPC0.EC0_.XQ20, MethodObj)        // 0 Arguments

    Device (_SB.PWRL)
    {
        Name (_HID, "PWRL0000")
        Name (STPW, 45)   // STAPM limit, W
        Name (SLPW, 45)   // slow PPT, W
        Name (FSPW, 54)   // fast PPT, W
        Name (APSW, 45)   // APU slow limit (ALIB 0x13), W
        Name (STTW, 45)   // STT power limit (ALIB 0x2E), W

        // Same buffer layout as DSDT \CDPC: [size 7 (word), id (byte), value mW (dword)]
        Method (ALBC, 2, Serialized)
        {
            Acquire (\DPMX, 0xFFFF)
            Name (XX12, Buffer (0x07){})
            CreateWordField (XX12, Zero, SSZE)
            CreateByteField (XX12, 0x02, SMUF)
            CreateDWordField (XX12, 0x03, SMUD)
            SSZE = 0x07
            SMUF = Arg0
            SMUD = (Arg1 * 0x03E8)
            \_SB.ALIB (0x0C, XX12)
            Release (\DPMX)
        }

        Method (_STA, 0, NotSerialized)
        {
            If (_OSI ("Darwin"))
            {
                Return (0x0B)   // present, enabled, functioning; not shown in UI
            }
            Return (Zero)
        }

        Method (APLY, 0, Serialized)
        {
            If (_OSI ("Darwin"))
            {
                \CDPC (0x05, STPW)   // DIAG: no AC check
                \CDPC (0x07, SLPW)
                \CDPC (0x06, FSPW)
                ALBC (0x13, APSW)
                ALBC (0x2E, STTW)
            }
        }

        Method (_INI, 0, NotSerialized)
        {
            APLY ()
        }
    }

    Scope (_SB.PCI0.LPC0.EC0)
    {
        Method (_Q20, 0, NotSerialized)  // _Qxx: EC Query
        {
            XQ20 ()
            \_SB.PWRL.APLY ()
        }
    }
}
