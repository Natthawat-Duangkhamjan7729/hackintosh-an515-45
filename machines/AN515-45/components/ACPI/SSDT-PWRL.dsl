/*
 * SSDT-PWRL (v2): raise the CPU power limits on AC under macOS only.
 *
 * Firmware path (DSDT, AN515-45): the EC raises query _Q20 and the DSDT
 * method \CDPC (func, watts) passes the EC's values to \_SB.ALIB (0x0C):
 *   func 0x05 = STAPM limit, 0x07 = slow PPT, 0x06 = fast PPT, 0x03 = Tctl limit.
 * Measured on 2026-11-06 under macOS on AC (see docs/PROGRESS-2026-10-09.md):
 *  - EC defaults: package flat at ~34 W, Tctl 71-79 C (a power limit, not thermal).
 *  - STAPM/slow/fast 20 W via \CDPC: 19.5 W  -> the ALIB path works.
 *  - STAPM/slow/fast 45/45/54 W alone: still ~34 W -> another limit.
 *  - plus ALIB 0x13 (APU slow limit) and 0x2E (STT power limit) = 45 W:
 *    43.9 W sustained, 3.48 GHz all-core, ~84 C.
 *
 * This table:
 *  - replaces EC0._Q20 (the DSDT copy must be renamed _Q20 -> XQ20, DSDT only):
 *    it first runs the original XQ20 (EC values), then on AC applies the targets.
 *  - applies the targets once at boot from \_SB.PWRL._INI when on AC.
 * On battery the EC's STAPM/PPT values stay in force. The Tctl limit (0x03) and
 * the current limits (TDC/EDC) are never touched.
 * Targets are inside AMD's 35-54 W cTDP range for the Ryzen 7 5800H.
 */
DefinitionBlock ("", "SSDT", 2, "ACER", "PWRL", 0x00002000)
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
                If (\_SB.PCI0.LPC0.ACAD._PSR () == One)
                {
                    \CDPC (0x05, STPW)
                    \CDPC (0x07, SLPW)
                    \CDPC (0x06, FSPW)
                    ALBC (0x13, APSW)
                    ALBC (0x2E, STTW)
                }
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
