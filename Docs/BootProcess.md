# Official Web6502 Boot Process

If using the provided *BootROM* and `WEB6502.SYS` with your Web6502 web application, then this document should get you started with creating your own 6502 programs.

With all official builds of Web6502, it will include the embedded *BootROM*, which source is included in this repo for reference.  The *BootROM* supports the statically loading of a custom 6502 binary of your choice if you wish to not use any externally loaded files at address `$5000`.  There should be no header, and code should begin execution at `$5000`.  The Web6502 framework allows the loading of binary programs, or you can embed your own.  Examples of how this can be done will be provided in the near future.  If the *BootROM* does not detect anything loaded at this address, meaning it is just a `$00`, then it will attempt to detect the `T6502WebDisk` card in slot 6 of the virtual Web6502, and it will attempt to load in the file `files/WEB6502.SYS` from the server it is currently running under.  This does not need to be the official `WEB6502.SYS`, but if you supply your own, then please disregard the rest of this boot process and replace it with your own implementation.

The `WEB6502.SYS` is loaded at address `$400`, which is a flat binary program which it's code execution will start at address `$400`.  The first thing this bootloader will perform is the scanning of all supported Web6502 cards loaded into the framework, and will list each slot it detects to the default output card in slot 0.  It will make note of all potential storage cards which a program could be loaded from, and it will use the final card as the card it will attempt to load the kernel or custom program from.  The reason slot 6 is the default instead of slot 7 for the *BootROM* is for this, so that, if you decide to use a different method to load your application or the kernel from, it becomes possible to slot in an alternative card into slot 7, and once detetected will become the default disk of which this part of the boot process will use to load in the rest of the system from.  This bootloader also has a few extra features, if you wish to just load a program, rather than loading a full system kernel.  Here is an ordered list of how it will detect how to load the program:

  1. Check environment variable `boot=`, if it's set, load it as the program.
    - An example of this in action can be seen with the EhBASIC program, where in the URL, it shows `?boot=basic.bin`.
    - This program will always load into address `$5000`, as a RAW headerless binary program.
  2. Binary filename statically placed into memory via the Web6502 framework at address `$ff00`.
    - An example of this in action can be seen with my Blog program: `FMemory.LoadString('blog.bin'+#0, $ff00);`
    - The stated filename at this location is loaded into address `$5000`, as a RAW headerless binary program.
  3. If none of the above are set, then `KERNEL.SYS` is loaded from the last detected storage card.
    - The kernel is still in active development, and is loaded into `$d100`, as a RAW headerless binary program.
    - Before booting the kernel, several memory addresses are preset for the kernel to use, these include:
      - `$f0`: Vector to current output card.
      - `$f2`: The detected card type of the current output card.
      - `$f3`: Vector to current storage card where the kernel was loaded from.
      - `$f5`: Card type of slot 6(*Currently a bug as it should use the currently detected storage*)
        - Probably why I didn't commit this code last month when I was working on it, as it is incomplete.
