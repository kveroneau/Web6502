## Web6502 Test programs in Pascal

This directory contains various Web6502 test programs I've been writing in Pascal, which includes several working unit files for some of the various Web6502 Interface Cards I've built.  Here is a list of all the current units here:

### Web6502

This unit file will set a basic bootloader, meant for `.PRG` files in the Web6502 system, and as a result, at least unless you change the bootloader should only be used for `.PRG` programs, such as running from the supplied *PasROM* in the `roms/` source directory.  The `ORG` and `DATA_ADDR` should also be updated to reflect your application, if needed.  Here is a list of the currently accessible variables for your use:

`TextAttr`: should really be in `crt6502`, and should only be used to reset the Text attribute system.

`SYS_API`: With Official Web6502 releases, this will point to the system control vector, used to halt the CPU, and to toggle from real-time to timer runtime modes.

`cardio`: Can be used to determine the type of a specific card, used by supplementary units for their detection.

`CRLF`: A convenience constant of sorts, perhaps I should make it a `const`...

The following is a list of all the available procedures and functions:

`procedure SetRealTime(v: Boolean);`: Enables or Disables real-time mode, disable uses timer mode.

`procedure Idle;`: Non-returning Idle procedure, used when the program is only waiting for external interrupts.

`procedure FindCard(cardtyp: byte): byte;`: Used to find a card of a specific type.

`procedure strcmp(s1, s2: pointer): boolean;`: Primitive, but working and compatible to C `strcmp()` function.

`procedure memcpy(src, dest: pointer; size: byte registerY);`: Primitive, but working `memcpy`, can only copy a single page or less at a time.

### crt6502

An attempt at porting the Pascal `crt` unit over, and will be complete soon.  As this unit is meant for testing and not for proper software, it only supports a terminal on interface card slot #0, and does not support detection of output, or swapping the output to a different card.  It contains the following procedures and functions at the moment:

`procedure Write(s: pointer absolute $c002);`: Basic write string, cannot handle anything but strings, also note the direct addressing, and thus is not suited for any card slot other than #0.

`procedure WriteLn(s: pointer register);`: Basic writeln string, same limitations as the above, and in fact uses the above procedure.

`procedure Prompt(s, buf: pointer);`: Yeah yeah, not a `ReadLn`, but is more convenient for testing.  See examples if confused on usage.

`procedure ReadChar: char;`: Reads a single character from the keyboard, only works when terminal is in RAW mode.

`procedure SetRAW;`: Sets the terminal in RAW mode, allowing single character input.

`procedure ClrScr;`: Clears the terminal display.

`procedure GotoXY(x,y: byte);`: Positions the text cursor at X,Y for the next write operation.

`procedure WriteHexByte(b: byte);`: Convenience method as I'm too lazy and I also don't want to take too many CPU cycles for such calculations.  This uses an I/O Card API for output.

`procedure WriteHexWord(w: word);`: Convenience method as I'm too lazy and I also don't want to take too many CPU cycles for such calculations.  This uses an I/O Card API for output.

`procedure ForegroundColour(fg: byte registerA);`: Set the foreground colour of the text.

`procedure BackgroundColour(bg: byte registerA);`: Sets the background colour of the text.

### disk6502

This unit file before a lot of the procedures and functions can be called must be initialized via it's included `SetDiskCard` procedure, passing in the card number where the `T6502WebDisk` is installed into.  Here is a full list of the procedures and functions in this unit:

`procedure SetDiskCard(cardid: byte);`: Initialize a WebDisk on a specific card slot, can be called again later to switch to a different card, say if you have another compatible card in a different slot.  This unit will eventually support all compatible cards, and it will currently work with the `T6502WebDisk` and the `T6502JSONDisk` cards.  Although for the latter, the type cannot be choosen by the program, and the data is handled based on the type available.  Future functionality to see this special type information from the program will be made available soon.

`procedure LoadFile(fname: pointer; dest: pointer): boolean;`: This function will load a filename provided into `fname` into `dest`, and return back either `True` or `False` based on if the file was loaded or not.

`procedure LoadPRG(fname: pointer): pointer;`: Loads a PRG into memory, and returns the memory address of where it was loaded.  Be sure to only load in `.PRG` files which are loaded into locations where you don't have data, or have any active data.  Read the documentation on any third-party `.PRG` files before using, as it could cause the Web6502 to crash if data is loaded into a place where it corrupts another program's data.

`procedure LoadTextFile(fname, dest: pointer): boolean;`: This variant will only work when an HTML DOM page is available, as the `dest` should be a DOM target ID of where this text file should be loaded into.

`procedure LoadMarkdown(fname, dest: pointer): boolean;`: Similar to the above, except loads and then parses the text as Markdown before rendering it into the DOM target ID provided.

`procedure LoadTextFile(fname: pointer): boolean;`: Used to load a text file and then immediately display it to the terminal display, this is a convenience function to allow text files to be easily displayed like they are with the DOM functions above.  If you need to say load a Text file into memory only, and not display it right away, then use the `LoadFile` instead, as it will then place the text file into 6502 memory space.

### cffa1

This unit file allows for both saving and loading of data from 6502 memory with relative ease, for both of these operations, the browser's `localStorage` is used, allowing data to be easily persisted between entire page refreshes, allowing the visitor to retain some sort of saved data, either game progress, or the data of an application in Web6502, which can then be loaded manually by the program later on.  Here is a list of all the available procedures and functions:

`procedure InitCFFA1(cardid: byte);`: Initialize the CFFA1 Card on the specified slot #.  **Required.**

`procedure OpenDir;`: Begin a directory listing operation.

`procedure ReadDir: pointer;`: After performing an `OpenDir` above, use this to obtain a string pointer to the next read in filename, read until the string is `null`.  Will return all `localStorage` keys for the current site, and not just files created by CFFA1, this may change in the future.

`procedure SaveFile(fname, src: pointer; size: word);`: Saves a CFFA1 filename with the name `fname`, from memory location `src` with the exact size of `size`.

`procedure LoadFile(fname, src: pointer): word;`: Loads a CFFA1 file with the name `fname` into memory location `src`, and returns how much data was loaded.  It should be a given, but you should only load in data of which your program specifically created back in to ensure that it does not overwrite data it shouldn't.  If exactly 40 bytes are saved, then exactly 40 bytes will be loaded back.  In most cases, end-users will not have modified localStorage, and the data should be the proper sizes when loaded back.

### env6502

This unit is not yet complete, and has bugs I am still trying to sort out.  Documentation will be written once it's ready for consumption.

## Test Programs

Here is a list of some of the test programs which you can try out yourself!  These all compile into `.PRG` files, but the load address can be changed via the `ORG` directive if you need them to load in differently.

### test.pas

This program here will load into address `$0801` by default, and is designed to be loaded from my *PasROM* located in `roms/pasrom.pas`.  It contains an easy to use shell with various code examples, here are the various shell commands currently available:

`exit`: Exits using an `RTS`, if loaded from *PasROM*, it will resume the boot process.

`regtest`: This shows how registers can be used to pass data around.

`memcpy`: Demos the `memcpy` procedure.

`addr`: Shows a bunch of fun pointer information.

`colour`: A fun example showing the various colours in the VT100 terminal.

`cls`: Used to clear the terminal screen.

`reload`: Reloads the test.prg program by rerunning the code in the *PasROM* triggering it to reload the `.PRG` file, very useful during testing.

`disk6`: Sets the disk slot to #6, required before any of the disk commands can be used.  I will soon be creating a `disk7` so be on a look-out for that command soon.

`load`: Shows the Webdisk loading a binary file in, and confirming that it is correctly loaded.

`loadprg`: Originally used to load and run `test2.prg` during it's development, now it will load in `test3.prg`.

`loadtext`: Example of how to load a pure text file and display it on the terminal.

The shell also supports the running of any program in the currently set disk, so if you still wanted to load `test2.prg`, simply enter in `test2.prg` as your command, and the shell will attempt to load and execute it.  Do not try and execute non-PRG programs, or the system will crash, there isn't any check in place in this test program.

### test2.pas

This is a stand-alone CFFA1 test program, and will exit if it fails to detect the CFFA1 card.  It also has a shell with the following commands:

`exit`: Leaves the shell with an `RTS`, so it will return back to `test1.pas`.

`dir`: Will display the files in the CFFA1 card to the terminal.

`rt`: Used during testing, and will speed up all operations, can show the speed difference between real-time and timer modes.

`save`: Allows a string to be saved into the CFFA1 for later loading.

`load`: Will load back in the string saved using the above command.
