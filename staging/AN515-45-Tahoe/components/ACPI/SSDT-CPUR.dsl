/*
 * SSDT-CPUR for Acer AN515-45 (Ryzen 7 5800H, 16 threads).
 * Firmware declares CPUs only as \_SB.PLTF.C000-C00F (Device, _HID ACPI0007), no Processor objects.
 * MADT: 16 enabled LAPICs, ACPI Processor IDs 0x00-0x0F. Based on Dortania SSDT-CPUR.dsl,
 * trimmed to 16 entries; P_BLK left empty because this FADT uses PM base 0x400 (Dortania uses 0x810).
 * Processor objects are visible only to Darwin via _STA; other OSes keep the firmware devices.
 */
DefinitionBlock ("", "SSDT", 2, "AN515", "CPUR", 0x00001000)
{

    Scope (\_SB)
    {
        Processor (PR00, 0x00, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR01, 0x01, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR02, 0x02, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR03, 0x03, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR04, 0x04, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR05, 0x05, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR06, 0x06, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR07, 0x07, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR08, 0x08, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR09, 0x09, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR10, 0x0A, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR11, 0x0B, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR12, 0x0C, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR13, 0x0D, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR14, 0x0E, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Processor (PR15, 0x0F, 0x00000000, 0x00)
        {
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin"))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }
    }
}
