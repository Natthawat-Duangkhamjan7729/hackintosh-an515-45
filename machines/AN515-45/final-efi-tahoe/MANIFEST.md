# Kext / driver manifest (binaries not committed)

Source: the private set `candidate-tahoe-nullmoth-pwrl2-nmxaudio` that is installed on the USB (checked 2026-11-07). SHA256 is of the kext executable.

| Kext | Version | Enabled in config | SHA256 (executable) |
|---|---|---|---|
| AMDRyzenCPUPowerManagement.kext | 0.7.2 | yes | `9dccfdfc34414bc4ada4de4598e89a1239394b8e150ebf977580ebda9ed41a61` |
| AMFIPass.kext | 1.4.1 | yes | `4c35bc196d35c69b5f9dca83fe733801211c7828716f51585c7f5450039ca884` |
| AppleALC.kext | 1.9.8 | no | `690b96189491b9d6f64aa552da6684714d80ade4ad4ec9027251c3257a2d16e8` |
| BlueToolFixup.kext | 2.7.2 | yes | `f3244382a43866138ff449b14f1e54fb069ad3e4b14cbc753858650efdbbce52` |
| BrightnessKeys.kext | 1.0.3 | yes | `74c5cbc2dbeba0aec76f53582c350d7d2b42dc93f23a81884f288805c7add662` |
| ECEnabler.kext | 1.0.6 | yes | `af2a3a6790a37f5ba71fbeaebc4e4e0d4f44cbbd6966089f0a8f7a454175213a` |
| ForgedInvariant.kext | 1.5.0 | yes | `328beb1265f1fc0c91053fe0308e953f3890ea588183ef2ba7259032ed539f37` |
| Lilu.kext | 1.7.2 | yes | `ff98508b40a1eb5fb477029db8886412520f8e39965279ea331c99e3d2e3b274` |
| NVMeFix.kext | 1.1.3 | yes | `3e2632eaf09c6cb87e88c5681371e194c53b6653ddbf8693f0bbb1ae42470ef8` |
| NootedRed.kext | 0.8.10 | no | `c879e4b84b808b4fb2eb68fb2252160687c87622337c59cb7dcb9f93150fbda0` |
| RealtekRTL8111.kext | 3.0.0 | yes | `a9a99d105518bf2e1905321e35c68d127bb0414bca9ec0d40ad50cc43b55ef16` |
| SMCAMDProcessor.kext | 1.0.1 | yes | `2ec1f27b3198da35b5a299ef9c229fdf081a239260d0825535c401ab1bb46358` |
| SMCBatteryManager.kext | 1.3.8 | yes | `2f0b3525cd85e803b8247ff959f16e3f434d3b8126328e11086b9c0bfddf9216` |
| SMCLightSensor.kext | 1.3.8 | yes | `7e79a2a4cff8a7489bc7ecbde7b64488c1adddd3598647fb5200b03fd9722f07` |
| SimpleMtkBtFw.kext | 1.0.0 | yes | `8079337d3bd2ef9e2d886ca8987272a4823ddb9bfc80502e28f4d075d0fd660b` |
| SimpleMtkBtPatcher.kext | 1.0.0 | yes | `e481fe38552024c7b95b2cf35d8bf498a0bfa32ddcb3264a8c12239afee9e8b2` |
| USBMap.kext | 1.2 | yes | `-` |
| USBToolBox.kext | 1.2.0 | yes | `c5c8dc205a079ee3f90b7875fb5ff622e4f15d32f29cf519123dab2822c422b7` |
| UTBMap.kext | 1.0 | yes | `-` |
| VirtualSMC.kext | 1.3.8 | yes | `b55cd581b0127fe1a0ac050a69129ba5012b4547f6a9d1abfa3ad41849a2a246` |
| VoodooHDA.kext | 3.7.0 | no | `84265aad3f50499363f971b6bc8bd805f849bcaaa1f297b8b68358dce53ab9f2` |
| VoodooI2C.kext | 2.9.1 | yes | `78213b539c31a158bd3fce3fea7bf0da8380c442a94f2b13ddd91d43717c9037` |
| VoodooI2CHID.kext | 1.0 | yes | `65975f7018ef10e2f058f46492f52fe49a5e5e2680dc7cf66af12b167f1d7f0a` |
| VoodooPS2Controller.kext | 2.3.7 | yes | `f78d6bf95fb403eccdebf3590015606d5ce4ea73bb78c3f1f20f03ce037b4e24` |

| OpenCore file | SHA256 |
|---|---|
| OC/OpenCore.efi | `11ba0b763d765fb82187214d1fa2ee5a9330f851461c12e34d532b7b91097875` |
| OC/Drivers/OpenHfsPlus.efi | `ad071af5173d840ad9061a6c62b0f6171fd9f1fda7c44cd95705b432dfdfd1cb` |
| OC/Drivers/OpenRuntime.efi | `cf2df818f7510ca1be321f1ff6481fcbe246c92b16a905ffc5ff654158e05b66` |
| OC/Drivers/ResetNvramEntry.efi | `e89433174be279f16a71cd19da8699baf6bc6f8372b642d3b3ed7eac4222166a` |
| BOOT/.contentFlavour | `5546c5dcc63bda3b1a8a4a732c69fd6fa645cb2b31b16f18e62453318104f3b7` |
| BOOT/.contentVisibility | `75081b593d15cf6e631971bc6768723f593b88b172477e40ae7d363e4829816d` |
| BOOT/BOOTx64.efi | `7b26e33bfd84fbc5025fcb16994f7eda3224d15edcfc004d71c8761e08a766fd` |

NullMoth 2.7.2 is not in `EFI/OC/Kexts`. It installs NVRM, NVAccel, NVRMFB, NVRMAGDC and NMXAudio into `/Library/Extensions`, and its Metal plugin into `/Library/GPUBundles` (see the NullMoth README).
