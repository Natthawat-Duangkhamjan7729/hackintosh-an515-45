"""Build a firmware-observation EFI only, never an OS installation config."""
from pathlib import Path
import copy
import json
import plistlib
import shutil

root = Path(__file__).resolve().parents[1]
package = root / 'packages/OpenCore-1.0.8-DEBUG'
output = root / 'firmware-diagnostics'
efi = output / 'EFI'
p = plistlib.loads((package / 'Docs/Sample.plist').read_bytes())
for section, arrays in {'ACPI': ['Add','Delete','Patch'], 'Booter':['MmioWhitelist','Patch'],
                        'Kernel':['Add','Block','Force','Patch'], 'UEFI':['Drivers','ReservedMemory','Unload']}.items():
    for key in arrays:
        p[section][key] = []
for section in ['ACPI','Booter','Kernel','UEFI']:
    for key, value in p[section]['Quirks'].items():
        if isinstance(value, bool):
            p[section]['Quirks'][key] = False
p['Booter']['Quirks']['ResizeAppleGpuBars'] = -1
p['UEFI']['Quirks']['ResizeGpuBars'] = -1
p['DeviceProperties'] = {'Add':{},'Delete':{}}
p['Kernel']['Emulate'].update(Cpuid1Data=bytes(16), Cpuid1Mask=bytes(16), DummyPowerManagement=False)
p['NVRAM'].update(Add={}, Delete={}, LegacySchema={}, LegacyOverwrite=False, WriteFlash=False)
p['PlatformInfo'].update(Automatic=False, CustomMemory=False, UpdateDataHub=False,
                         UpdateNVRAM=False, UpdateSMBIOS=False)
for key in ['MLB','SystemSerialNumber','SystemUUID','SystemProductName']:
    p['PlatformInfo']['Generic'][key] = ''
p['PlatformInfo']['Generic']['ROM'] = bytes(6)
p['Misc']['Entries'] = []
p['Misc']['BlessOverride'] = []
p['Misc']['Boot'].update(Timeout=0, ShowPicker=True, HideAuxiliary=False,
                         LauncherOption='Disabled', PickerMode='Builtin')
p['Misc']['Debug'].update(SysReport=True, Target=67, DisableWatchDog=True, DisplayLevel=0x80000042)
# Lock all filesystem/device scanning: this package offers explicit tools only.
p['Misc']['Security'].update(ScanPolicy=3, SecureBootModel='Disabled', Vault='Optional',
                            AllowSetDefault=False, ExposeSensitiveData=6)
p['UEFI']['APFS']['EnableJumpstart'] = False
template = copy.deepcopy(p['Misc']['Tools'][0])
p['Misc']['Tools'] = []
for filename, name, arguments in [('MmapDump.efi','Save firmware memory map',''),
                                   ('ResetSystem.efi','Restart to firmware boot','')]:
    entry = copy.deepcopy(template)
    entry.update(Path=filename, Name=name, Arguments=arguments, Enabled=True,
                 Auxiliary=False, Comment='OpenCore 1.0.8 firmware diagnostics',
                 Flavour='Auto', TextMode=True, FullNvramAccess=False)
    p['Misc']['Tools'].append(entry)
    dest = efi / 'OC/Tools' / filename
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(package / 'X64/EFI/OC/Tools' / filename, dest)
(efi / 'BOOT').mkdir(parents=True, exist_ok=True)
shutil.copy2(package / 'X64/EFI/BOOT/BOOTx64.efi', efi / 'BOOT/BOOTx64.efi')
shutil.copy2(package / 'X64/EFI/OC/OpenCore.efi', efi / 'OC/OpenCore.efi')
(efi / 'OC/config.plist').write_bytes(plistlib.dumps(p, sort_keys=False))
for entry in p['Misc']['Tools']:
    assert (efi / 'OC/Tools' / entry['Path']).is_file()
(output / 'manifest.json').write_text(json.dumps(dict(
    purpose='Firmware-only diagnostics; not a macOS boot configuration',
    opencore='1.0.8 DEBUG', osScanning=False, platformSpoofing=False,
    source='https://github.com/acidanthera/OpenCorePkg/releases/tag/1.0.8',
    hardwareBootTested=False), indent=2), encoding='utf-8')
print('Firmware diagnostic EFI prepared:', output)
