// Acer AN515-45, OEM EC is \_SB.PCI0.LPC0.EC0.
// Preserve the real laptop EC. Add a Darwin-only compatibility device.
// USB power values follow Dortania's laptop EC/USBX reference.
DefinitionBlock ("", "SSDT", 2, "ACEROC", "ECUSBX", 0x00000001)
{
    Scope (\_SB)
    {
        Device (EC)
        {
            Name (_HID, "ACID0001")
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin")) { Return (0x0F) }
                Return (Zero)
            }
        }
        Device (USBX)
        {
            Name (_ADR, Zero)
            Method (_STA, 0, NotSerialized)
            {
                If (_OSI ("Darwin")) { Return (0x0F) }
                Return (Zero)
            }
            Method (_DSM, 4, NotSerialized)
            {
                If (Arg2 == Zero) { Return (Buffer (One) { 0x03 }) }
                Return (Package (0x08)
                {
                    "kUSBSleepPowerSupply", 0x13EC,
                    "kUSBSleepPortCurrentLimit", 0x0834,
                    "kUSBWakePowerSupply", 0x13EC,
                    "kUSBWakePortCurrentLimit", 0x0834
                })
            }
        }
    }
}
