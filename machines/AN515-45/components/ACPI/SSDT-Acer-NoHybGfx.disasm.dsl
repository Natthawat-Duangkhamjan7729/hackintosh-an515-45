/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20200925 (64-bit version)
 * Copyright (c) 2000 - 2020 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of SSDT-Acer-NoHybGfx.aml, Mon Oct 12 14:02:02 2026
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x0000012B (299)
 *     Revision         0x02
 *     Checksum         0x3F
 *     OEM ID           "ACER"
 *     OEM Table ID     "NoHybGfx"
 *     OEM Revision     0x00000001 (1)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20200925 (538970405)
 */
DefinitionBlock ("", "SSDT", 2, "ACER", "NoHybGfx", 0x00000001)
{
    External (_SB_.PCI0.GPP0.PEGP._DSM, MethodObj)    // 4 Arguments
    External (_SB_.PCI0.GPP0.PEGP._PS3, MethodObj)    // 0 Arguments

    Device (DGPO)
    {
        Name (_HID, "RMD0001")  // _HID: Hardware ID
        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If (_OSI ("Darwin"))
            {
                Return (0x0F)
            }

            Return (Zero)
        }

        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            If (_OSI ("Darwin"))
            {
                If (CondRefOf (\_SB.PCI0.GPP0.PEGP._DSM))
                {
                    If (CondRefOf (\_SB.PCI0.GPP0.PEGP._PS3))
                    {
                        \_SB.PCI0.GPP0.PEGP._DSM (ToUUID ("a486d8f8-0bda-471b-a72b-6042a6b5bee0") /* Unknown UUID */, 0x0100, 0x1A, Buffer (0x04)
                            {
                                 0x01, 0x00, 0x00, 0x03                           // ....
                            })
                        \_SB.PCI0.GPP0.PEGP._PS3 ()
                    }
                }
            }
        }
    }
}

