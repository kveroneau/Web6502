# Custom 6502 Emulator for the Web

A almost identical source port of my [Hacker Maker Library MOS 6502 Components](https://github.com/kveroneau/klib/tree/main/HMLib) to Pas2JS, allowing 6502 programs using this kit to be easily shared between a desktop application, and a web-based application.

## Why would you want this?

These classes included in this package allow for the creation of custom 6502 systems, either based on real life systems, or entirely custom systems.  It can be used to create interactive websites which run 6502 machine code, allowing the ability to demonstrate 6502 programming, or for other purposes.

If you are a super duper hard-core 6502 programmer who refuses to code in anything but 6502 Assembly, and always wanted to make your very own website using only 6502 code, then this project is right up your alley.  So no to *32GB* of RAM for your website to use, and say yes to the limitations of building a website in only *64KB* of RAM!  If you love trying to push the limits of older hardware, and wanted to showcase those skills on the Web, so that nobody needs to download anything to see your wonderful 6502 code come to live, then this is also perhaps a project for you!

With this, you can also create custom virtual interface cards with little hassle that can do almost anything you can do on the modern Web, but make those fully accessible to 6502 code.  For example, you could create an `AICard`, which has API integrations to popular AI endpoints, allowing any of your 6502 programs to effortless make calls into these AI APIs, allowing for 6502 programs to do things they could never do back in the 80s.

## Live Demo Site

*What, did someone say they'd like to see this running live?*  Well, you are now in luck, as I recently launched a [website](https://web6502.puter.site/) which will be *100%* powered by this technology.  If you'd even like to see the *ObjectPascal* source of the website, there is a new directory in this repository with the source code, and if you'd like to get up and running without having to compile the Web6502 Emulator yourself, then feel free to download the currently compiled website version, and then supply your own `blog.bin` for booting it.  Although, in future versions the loading of program data will be changed to be much more univeral, like a typical system *bootloader* or *ROM* would be like, where an initial loader system is first loaded in, and then a boot option is detected after some basic virtual hardware checks, like detecting which devices and cards are available in the system.

If you'd like to see how the current `blog.bin` is built, the source code for both a P65Pas Pascal version, and a C cc65 compatible version are provided in this repository as well.
