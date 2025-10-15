# Main Device Classes

This document will not include the *Cards*, there is another document for those.

## TMOS6502

The main CPU device class, you will always need this to initialize and control your virtual MOS 6502 instance.  Here is the public interface:

```pascal
  E6502Error = class(Exception);

  TRunMode = (rmTimer, rmReal);

  { TMOS6502 }

  TMOS6502 = class(TComponent)
  public
    property Active: Boolean;
    property Memory: T6502Memory;
    property Device: T6502Device;
    property Running: Boolean;
    property RunMode: TRunMode;
    property ResetVector: word;
    property HaltVector: word;
    property PC: word;
    property RegA: byte;
    property RegX: byte;
    property RegY: byte;
    property RegAX: word;
    constructor Create(AOwner: TComponent);
  end;
```

Most of these are there to access the system registers directly, although, you should rarely need those.  I will go through the most important ones here:

  * `Active`: All set-up and ready to activate, set this to True!
  * `Memory`: Must be set to a created instance of **T6502Memory** before activation.
  * `Device`: Must be set to a created instance of a **T6502Device**, a subclass of it, before activation.
  * `Running`: Once you are ready to start the actual CPU core, set this to True!
  * `RunMode`: Can be set before running, or during runtime to change the various run modes.
    - `rmTimer`: This is the default *RunMode*, it is slower, but will not make the website freeze during a bug or infinite loop.
    - `rmReal`: Used to run 6502 code as fast as possible, use with caution on public facing sites, and should only be enabled if all code running in this mode is properly tested.
    - It is a requirement to toggle this during an infinite loop, if you are expecting user input/interaction.
  * `ResetVector`: Should be set before setting **Active** to True.
  * `HaltVector`: Allows so-called *Hypervisor* routines to be enabled at a specific memory address.
    - `$40`: Set this to the vector to set *rmTimer* RunMode.
    - `$41`: Set this to the vector to set *rmReal* RunMode.
    - `$42`: Set this to the vector to suspend the 6502 CPU Code, can be resumed via *Running*.

## T6502Memory

This is the main core memory class for the 6502 CPU core, and it is required to be set on the main CPU above after it's instance has been created.  You can of course sub-class this if you would like to change it's functionality, although in a majority of cases, it shouldn't need to be altered.  Here is the public interface for it:

```pascal
  T6502Memory = class(TComponent)
  public
    property Active: Boolean;
    property Memory[addr: word]: byte;
    property ROM[i: byte]: T6502ROM;
    procedure SetWord(addr, data: word);
    function GetWord(addr: word): word;
    function GetString(addr: word): string;
    function GetStringPtr(addr: word): string;
    procedure LoadInto(strm: TStream; addr: word);
    function LoadPRG(strm: TStream): word;
  end;
```

Unless you are creating a custom device, in most cases, you will never need to use any of these methods.

  * `Active`: Once you are ready to activate the memory, set this to True!
  * `Memory[]`: Access a single byte of the 6502's 64K flat memory.
  * `ROM[]`: Configure a ROM via the **T6502ROM** class instance, not required.
  * `SetWord`: Sets a 2-byte value at a specific memory location.
  * `GetWord`: Gets a 2-byte value at a specific memory address.
  * `GetString`: A Helper function to read a null-terminated string into a string.
  * `GetStringPtr`: Another Helper function to read a null-terminated string from a string pointer into a string.
  * `LoadInto`: If you don't use any ROMs and only raw program code, this can be used to load in data from a stream.
  * `LoadPRG`: Have a 6502 binary program with a *PRG* compatible header?  Load it properly with this!

If you plan on using any ROMs, be sure to set up all the ROMs via `ROM[]` before activating.

## T6502ROM

This class is optional to use, and is more or less just a convenience at the moment to load in static modules at specific locations in memory.  Although it has ROM in it's name, nothing is currently stopping it's memory from being overwritten by a program, it is **not Read-only** in memory at the moment.  Here is the public interface:

```pascal
  T6502ROM = class(TComponent)
  public
    property Active: Boolean;
    property Address: word;
    property ROMFile: string;
    property ROMStream: TBytesStream;
    property OnROMLoad: TNotifyEvent;
    destructor Destroy; override;
  end;
```

Some of these are only needed internally.

  * `Active`: Be sure to set this to True before activing the memory.
  * `Address`: What address should this ROM be loaded into.
  * `ROMFile`: Can either be an embedded resource, or an external file loaded via HTTP.
  * `ROMStream`: Used internally to read the ROM data into memory.
  * `OnROMLoad`: An event which you can set to be notified when the ROM is loaded and ready.

## T6502Device

This should only be sub-classed and never used directly, it is a base class for all 6502 Devices, and if you plan on making your own device, although creating a Card should be enough, this is the class you will need to sub-class.

```pascal
  T6502Device = class(TComponent)
  protected
    FMemory: T6502Memory;
    procedure SetMemory(AValue: T6502Memory); virtual;
    function GetDeviceType: byte; virtual; abstract;
  public
    property DeviceType: byte;
    property Memory: T6502Memory;
    procedure DeviceRun; virtual; abstract;
  end;
```

You should only override the `virtual` methods, and the `abstract` methods are required in your sub-class.

  * `SetMemory`: Should rarely, if ever be overriden, although you can if needed.
  * `GetDeviceType`: Always override and return a byte Result with the type of the device.
  * `DeviceRun`: Always override, it is called each and every CPU cycle, here you can check memory locations.

Okay, and below are a bunch of included **T6502Device** classes you can use, and also reference as an example if you plan on developing your own custom interface device for the 6502.

### T6502DeviceHub

Need to attach more than a single device to your 6502?  Look no further than the aclaimed *6502 Device Hub*!

```pascal
  T6502DeviceHub = class(T6502Device)
  public
    property Device[i: integer]: T6502Device;
    function FindType(devtype: byte): T6502Device;
  end;
```

The Device Hub is fairly simple in it's use, create an instance and add devices to each of it's available ports.

  * `Devive[]`: Set a specific device to a specific port on the hub.
  * `FindType`: Find a specific device by type.

### T6502CardSlots

I created this device as a way to sort of mimic the expansion cards from the *Apple //* line of products.

```pascal
  T6502CardSlots = class(T6502Device)
  public
    property Card[i: Integer]: T6502Card;
  end;
```

There is really only a single property you need to use with the card slots, the 8 slots you have, you can slot in any cards into those, and the device will take care of the rest.  Currently the first slot is reserved to the primary output device, as the cards are generally initialized in order, having the output initialize first just makes sense.  The currently included ROM is made this way, although, nothing is stopping you from setting the output to card 5, and then writing a custom ROM to make slot 5 the default output.  Slot 0 as default is only a limitation of the included ROM.

### T6502Storage

This is a very basic storage device, it works more similar to say how SRAM worked on the NES over how a disc works.  Essentially, you would map an area of RAM to this storage device, then use a special API to have the device read the data in from the storage into this mapped RAM, and an API to have the data saved back out.  In terms of using this on a website, and where that data to be loaded and saved is stored, data is first checked for in the browser's local storage, if the data is not there, then it will load in a URL from the server.  Saving with this storage device will storage into the browser's local storage, the same place which is checked when a load operation is requested.

```pascal
  T6502Storage = class(T6502Device)
  public
    LoadOnStart: Boolean;
    Filename: String;
    Page: Byte;
    Pages: Byte;
  end;
```

Configuring the storage is very easy, you will need all of the options set to a valid value.

  * `LoadOnStart`: Set to `True` if you'd like the storage be loaded immediately after the device starts.
  * `Filename`: A filename to use both when requesting it from the server, and for use in the browser's local storage.
  * `Page`: Which page in memory should be used for this storage.
  * `Pages`: How many pages of memory will this storage use, pages are `$100` in size.

For example, if you wanted memory addresses from say `$EC00` to `$EC3FF` to be stored and loaded from RAM using this device, set the page to `$EC`, and the pages to `$04`.
