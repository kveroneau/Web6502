# 6502 API

This document will go through what a 6502 programmer will need to know if they plan to assemble their own website, over using the supplied C Library.  This docment will outline the existing devices and cards which are available within the package, and explains which memory addresses you will need to use for each one.  The first part of this document will be dedicated to the universal API, that is the API of the base system, which can be enabled by setting the `TMOS6502.HaltVector` address on your main CPU class.

## Hypervisor / HaltVector API

Depending what you configure this vector to be on your class, within most of my tests and examples, I have been using `$FFF0` which the official C Library, and ROM will be set to use.  Becareful on not having this vector set, as various CPU settings cannot be changed from 6502 code, and can only be changed via an external call on the class itself, via say an HTML onclick event or something.  To use this API, let's assume you have your vector set to `$FFF0`, then do the following to say set the CPU into real-time mode:

```
LDA #$41
STA $FFF0
```

That's it!  The API being called is `$41`, and here is a list of the current ones available:

  * `$40`: Set CPU runtime to *Timer* mode, this will drastically slow down the CPU, as it will now rely on a browser timer to call the next CPU step.
  * `$41`: Set the CPU to real-time mode.  If used constantly without the above, it will hang the browser if user interaction is ever needed.
  * `$42`: Halt the CPU entirely, can be resumed via an ObjectPascal call from program code.

If you have an event loop within your 6502 program, and don't have much reliance on user input, then you should place soemthing like this in your event loop to give control back to the browser from time to time:

```
LDA #$40
STA $FFF0
LDA #$41
STA $FFF0
```

Of course, this is only needed if you run the CPU normally in real-time mode.

## Device APIs

Let's start with devices as there is a less of them, and in order to understand the Cards API, it is best to first understand the Devices.

### 6502 Storage

This API allows data to be loaded and saved into a specific memory segment set in the hypervisor code.  The control address to write a single op code in the form of one of the following bytes is `$FFD0`.  Here are the op code bytes which can be set in this address to control this storage device:

  * `$40`: Load data into memory from the backing storage file.
  * `$60`: Save data from memory into the backing storage file.

For example, if you wanted to save any data your program placed into the storage area, perform the following:

```
LDA #$60
STA $FFD0
```

### 6502 Device Hub

As the main CPU class only supports the connection for a single device, if you need more than a single device, then you will need to utilize the *Device Hub* and attach multiple devices to it.  In fact, you can connect additional Hubs to Hubs, although, this will definately impact the overall program performance.

Currently, there is no 6502 API for this device, however, one might be added soon to allow ROMs and other software to detect which devices are available in any specific configuration.

### 6502 Card Slots

This API provides static data to the system, but said data is never refreshed throughout the runtime of the CPU, so there are no op codes to use, making this one of the easiest APIs to use overall.  Cards cannot, or rather should not be hot-plugged during runtime, although, technically it is entirely possible to swap a card, if the application was expecting a different card, it may cause the 6502 to act incorrectly.  Use Hot-plugging with caution.

Programs can determine the type of a specific card by checking the addresses from `$C800-$C807`, where each byte represents the card type of the card in that respective slot.  For example, if you wanted to check if slot 3 had a card of type `$76`, here is the code for that:

```
LDA $C002
CMP #$76`
BEQ GotCard
.... Stuff to do if we don't have the card ....
```

It's a really simple API to use to check if a certain card is available in the running Web6502 system.  This is very useful if you either plan to have multiple front-ends to your Web6502 website, or if you wish to share a program with other people online so that they can use it on their own Web6502 website.  At least it'd be really cool if a community of developers began creating various Web6502 programs that people can connect together on their own Web6502 website, would it?  I think it would be cool, but that's just me.  At least the idea here is to create more of a *platform* on the lines of say a CMS product, where there are just a lot of third party modules people can effortlessly add to their own website.  Imagine running a retro themed website that ran entirely within a *VT100* terminal, all created using Web6502?  One module could be for example a *BBS-style menu in VT100*, and then to enable various door programs, these would essentially be pluggable modules from the community that can now add additional features like a message board and such to your own Web6502 BBS inspired website.  If these 6502 programs are developed correctly, then they should detect which front-end is in use, or otherwise need to provide multiple versions for each front-end.

Each card attached to the card slots has specific attributes based on which slot the card is located in.  For example, in most cases, at least for the current test programs and ROM, the output card should be in slot 0, this ensures that output starts up as soon as possible in the start-up of the 6502 system.  All current APIs in the C Library and ROM also assume slot 0 is the primary output card.  Multiple output cards can be attached to a single 6502 system, for example, if you slot in two DOM Cards, but using different HTML Divs, then you can now set the contents of these DIVs based on which card you are using for your operations.  Each card has a total of *256 bytes* of dedicated memory to use as it's internal registers.  This is where each card will look when checking for any op codes, or other data it requires.  This address space is from `$C000-$C7FF`, with say the memory for card slot 3 being between `$C200-$C2FF`.

## Cards API

The following APIs for each card will instead of using an absolute address, it will use a relative address from the start of the card's dedicated memory area.

### HTML DOM Output Card

**Card Type:** $80

This card is attached to a specific HTML DIV element, and updates it's `.innerHTML` according to how it's API is used.  This is only it's initial API with much more operations to come.

  * `$00`: Card Register used to perform an operation, see op codes below.
  * `$01`: Used to place a single character into an internal Line buffer, send `\n` or `$a` to flush.
  * `$02`: Pointer to a string anywhere in memory that an op code might need.

*Available Op Codes:*

  * `$80`: Print a null-terminated string to the DOM element, the string must be located in `$02-$03` as a pointer.

### HTML5 Canvas Output Card

**Card Type:** $2d

This card is attached to a specific HTML Canvas element, and all operations on it's API will draw onto this canvas.  Currently very bare-bones.

  * `$00`: Card Register used to perform an operation, see op codes below.
  * `$01`: Used to place a single character into an internal Line buffer, send `\n` or `$a` to flush.
  * `$02`: Pointer to a string anywhere in memory that an op code might need.
  * `$04`: Input characters from the user are placed here.

*Available Op Codes:*

  * `$80`: Print a null-terminated string to the Canvas element, the string must be located in `$02-$03` as a pointer.

### jQuery Terminal Output Card

**Card Type:** $42

This card is attached to a jQuery Terminal DIV element, and all operations will operate on this terminal.  It doesn't support everything that jQuery Terminal supports, but new op codes will be added soon.

  * `$00`: Card Register used to perform an operation, see op codes below.
  * `$01`: Used to place a single character into an internal Line buffer, send `\n` or `$a` to flush.
  * `$02`: Pointer to a string anywhere in memory that an op code might need.
  * `$04`: Pointer to a string to hold a line of user input.

*Available Op Codes:*

  * `$80`: Print a null-terminated string to the terminal, the string must be located in `$02-$03` as a pointer.
  * `$81`: Request a line of user input, terminal prompt set to use string pointer from `$02-$03`, and a pointer to a string buffer in memory where the line should go is located in `$04-$05`.
  * `$82`: Clears the terminal.

### VT100 Terminal Output Card

**Card Type:** $76

This card is attached to a JavaScript VT100 Terminal DIV elment, and all operations will operate on this terminal.  It doesn't yet support everything a VT100 does, but will soon, even mouse support!

  * `$00`: Card Register used to perform an operation, see op codes below.
  * `$01`: Used to place a single character into an internal Line buffer, send `\n` or `$a` to flush.
  * `$02`: Pointer to a string anywhere in memory that an op code might need.
  * `$04`: Pointer to a string to hold a line of user input, or a RAW character if terminal is in RAW mode.
  * `$20`: Text Attributes, can affect the colour and background colour of the text.
  * `$21`: Control the X position of the text cursor.
  * `$22`: Control the Y position of the text cursor.

For current efficency reasons, none of these values can be read back yet, and upon application, will reset the values in memory to zero.

*Available Op Codes:*

  * `$80`: Print a null-terminated string to the terminal, the string must be located in `$02-$03` as a pointer.
  * `$81`: Request a line of user input, terminal prompt set to use string pointer from `$02-$03`, and a pointer to a string buffer in memory where the line should go is located in `$04-$05`.
  * `$82`: Clears the terminal screen.
