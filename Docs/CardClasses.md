# Included 6502 Card Classes

These included cards, and any cards which you may wish to create need to be slotted into the **T6502CardSlots** class instance to work.

## T6502Card

This is the main class which every card is sub-classed from, if you choose to make your own custom card, then you will need to sub-class this, and use the following interface to design it's functionality:

```pascal
  T6502Card = class(TComponent)
  protected
    function GetCardType: byte; virtual;
    procedure SetWord(addr: byte; data: word);
    function GetWord(addr: byte): word;
    function GetString(addr: byte): string;
    function GetStringPtr(addr: byte): string;
  public
    property SysMemory: T6502Memory;
    property CardAddr: word;
    property Memory[addr: byte]: byte;
    property CardType: byte;
    property OnRunCard: TNotifyEvent;
    property OnInitCard: TNotifyEvent;
    procedure CardRun; virtual;
  end;
```

Some of these need to be overridden in your sub-class, namely those marked as `virtual`.  This class can also be instanced and used by itself for a Card Type of `$99`.

  * `GetCardType`: This should be overridden in your sub-class to return your card's Card Type.
  * `SetWord`: Used to set a 2-byte value within the Card's memory area.
  * `GetWord`: Used to set a 2-byte value within the Card's memory area.
  * `GetString`: Used to read a null-terminated string from the Card's memory area.
  * `GetStringPtr`: Used to read a null-terminated string pointer from the Card's memory area.
  * `SysMemory`: Allows access to all of the 6502's memory from the card, if needed.
  * `CardAddr`: Used to determine where in memory the Card's memory area is.
  * `Memory[]`: Byte access to the memory page dedicated to the Card's memory area.
  * `OnRunCard`: If used stand-alone without subclass, is used to set a call-back for when the card is run.
  * `OnInitCard`: If used stand-alone without subclass, is used to set a call-back for when the card is initialized.
  * `CardRun`: Should be overridden on a sub-class to implement the card's functionality, called every CPU cycle.

In most cases to add new functionality to the 6502, you should sub-class this.  See other cards as examples.

### T6502DOMOutput

A basic 6502 card which allows the code to set data into an HTML element.  This card will be expanded on in the near future, it is currently MVP.

```pascal
  T6502DOMOutput = class(T6502Card)
  public
    property Target: string write SetElement;
    constructor Create(AOwner: TComponent); override;
  end;
```

  * `Target`: Set's the target HTML div element where output should be written to.

Please see below on the default output API.

### T6502CanvasCard

This is an interface card for the HTML5 Canvas, currently only having text output, but will soon implement a lot of the functionality from the HTML5 Canvas.

```pascal
  T6502CanvasCard = class(T6502Card)
  public
    property CanvasID: string write SetCanvas;
    constructor Create(AOwner: TComponent); override;
  end;
```

  * `CanvasID`: Should be set to the HTML ID of the Canvas element you wish to interface with.

A new document will be created soon regarding the various 6502 APIs which can be used with this card, and the many others.

### T6502TerminalCard

This card is a drop-in replacement for a similar card in the *Hacker Maker Library*, this card requires that you have both jQuery and jQuery-Terminal available in your HTML source file.  It will always use the `terminal` HTML DIV ID.

There is currently no interface to this card, as it uses a default DIV ID for simplicity.

### TVT100Card

This is a card which emulates a VT100 Terminal, you will need the required JavaScript files for this to work correctly.  As with the above card, there is also no public API for this card in ObjectPascal.  It will always use the `vt100` HTML DIV ID.
