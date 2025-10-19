# How does BootROM work?

While technically not really needed,  as the 6502 system can just load any compatible binary program which uses the correct memory mapped APIs,  I thought it would be both neat and more flexible to use a BootROM which is suppose to be as small as possible at less than 256 bytes in size, which is embedded with the compiled JavaScript program.  This allows the system to get started much sooner than say with loading an external file, and while this has been used throughout testing, that is the direct loading of a file upon application load.  To make each Web6502 system essentially just useable with varying configurations, then a proper start-up system needs to be in place which can easily load the end-user program.

If you are planning on creating a unique website and Web6502 system which aren't going to be compatible with the eventual community created 6502 programs, then you do not need to worry about using the included BootROM, and can instead just start your own 6502 program and code.

# Why create and use a BootROM?

This will allow for much more standardization of the Web6502 systems, if you've been looking through Web6502, you'd notice that it supports different types of virtual output devices, each very unique.  In order to support each of these virtual output devices in Web6502, and allow different outputs to work across different types of 6502 programs, a standard system needs to be put into place.  To be as flexible as possible, this standard will begin at the BootROM level, as this will allow different Web6502 systems to boot entirely different from one another, based on the connected storage.

# Creating a Custom BootROM

The BootROM has a unique header, which must be at the very start of the ROM file.  You can see the provided bootrom.cfg if you'd like an example of the segment map.  The header content is as follows:

  * `Single Byte Offset of RESET VECTOR in ROM Code.`
  * `BootROM Version byte.`  Currently `$01`
  * `JMP code to print string routine`, it should be like, `$4c $11 $f0`
  * The following exact 7 bytes: `WebROM$`

Properly configured Web6502 systems will use that RESET VECTOR offset to configure the Reset Vector for proper system initialization.  If this header is not provided, then the current Web6502 ROM device will set the Reset Vector to the start address of the ROM.

# What does the current BootROM do?

Currently, it will always use the first card as the default output card.  If you do not have an output card in slot 0, be sure it does not have any $80 op codes, which are reserved for output compatible cards.  It will also use the card in slot 6 as the default boot device.

It only supports one compatible storage card at the moment, and it's the `T6502WebDisk`, and in the near future it will support the VFS system from the *Rabit Hole Framework*.  It will try and load a file from the storage called `WEB6502.SYS` into memory and launch it.  This next part of the boot process is still subject to change as it is further developed.

At the moment, programs which are launched from this BootROM can do a `JSR $f002` with A/X filled with a pointer to a string to have that string be effortlessly placed into the output.  Programs can also check the other various header values to determine other useful information about the BootROM.  As the BootROM will soon be expanded with other resources, namely the exporting of various device and card information.  Technically, further into the boot process, this JMP location can be updated to point to a new location with expanded abilities, while still retaining the same API across multiple programs.
