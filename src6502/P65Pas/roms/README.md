## Sample / Test ROMs in Pascal

While the main *BootROM* in `ROM0.bin` is built in pure 6502 assembly, for testing and to also make it easier for other people to develop their own test ROMs, I've built a Pascal unit file `rom6502.pas` which can be used in your own Pascal program to generate a compatible ROM image for `ROM1.bin`, and with a small modification, `ROM2.bin` and `ROM3.bin` is more ROMs are required for whatever reason.

The official Web6502 *BootROM* will chainload the rest of the available ROMs in a Web6502 system, so `ROM0.bin` should never be replaced unless you are certain you want to replace it.  Unlike the `ROM0.bin`, the secondary ROMs do not require the full ROM header, and only 2 bytes at the start of the ROM need to be set, similar to `ROM0.bin`'s header, where the first byte will be the low address, and the second byte is used as a version number for the ROM itself.  The first byte when it comes to this Pascal compiler will need to be manually set after this byte is known, please note the two example ROMs provided to understand how the header works.

### Sample ROMs

`romtest.pas` shows an example of how a ROM can initialize some data, such as a vector to some of it's own code, and then returns back to the main ROM.  This vector can be called from any 6502 program, such as in *EhBASIC* via `CALL $F1FD`, and it will return back to BASIC after it completes.

`pasrom.pas` shows how a ROM can check for and if found, run a `.PRG` program file right from the ROM.  Currently all `.PRG` files will function like they do on a Commodore 64, where after the program is complete, it will use the `RTS` 6502 op code to return from the program back to the calling program.  As a result, if the `.PRG` which this ROM is calling decides to return back via a `RTS`, it will then also resume running the code in `ROM0.bin`.  This allows this ROM to run some code early on, or in my current use-cases, to run a full shell application allowing me to test various Web6502 components without needing to load `WEB6502.SYS`.
