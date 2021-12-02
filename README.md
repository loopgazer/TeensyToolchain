# The Latest GNU Arm Embedded Toolchain for Teensy 4.x via PlatformIO

> The main intention of this script is to enable nested namespacing capabilities...

> GNU Arm Embedded Toolchain 10.3-2021.10

Before using the script, ensure that [PlatformIO's CLI] `platformio` is installed locally and available through the `$PATH` variable. 

On execution, this script initially downloads the lastest [GNU Arm Embedded Toolchain] found at Arm's homepage.

Since it's a bare-metal toolchain, some libraries are missing to use it with PJRC's Teensy.

Therefore, *_math.a libraries are extracted from the current toolchain, to be injected into the downloaded one.

Added with further metadata required to be used by PlatformIO, the toolchain is copied into PIO's local repository, where it replaces the toolchain supplied by PIO.

[PlatformIO's CLI]: https://docs.platformio.org/en/latest/core/installation.html#installation-methods

[GNU Arm Embedded Toolchain]: https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm?utm_source=platformio.org&utm_medium=docs