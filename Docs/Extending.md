# Extending Web6502

When I say *extending*, I mean the creation of either new **devices** or **cards**, which can either be shared with the community if it can be used in multiple projects, or can just be contained to the website being created.

## Why would you need to extend Web6502?

If you cannot find a built-in device or card which provides the functionality you need, and this functionality cannot be made directly in 6502.  For example, if you need to add integration to a third-party JavaScript library, or provide a connector to a backend server to save and load data from.  Here are some more examples in point form:

  * Integrate external web components, making them access from your 6502 code.
  * Connect to third-party providers over an HTTP connection to load in data that 6502 code can use.
  * Emulate real world 6502 machines on your website for demonstration purposes.

## My Hopes and Dreams

One day, perhaps in an alternate reality, it would be nice if a eco-system of third party developers would create and share a large amount of custom Web6502 devices and cards that Web6502 developers can use on their website with very minimal hassle.  The idea is have Web6502 as a super accessible *abstraction framework*, with a ton of pluggable devices and cards to create any sort of custom website using 6502 programs built for the web.  The more devices and cards that are supported by Web6502, the more useful it will be for people.  I believe that this sort of super simple separation between the system, and the actual programs, and website that runs on it can make maintance, security, and deployment much easier overall.  Perhaps in the future, configuring a Web6502 system can be as simple as updating a configuration file, rather than even having to compile everything to use it.

I am planning on having some *pre-built systems* provided soon with full examples on the [website](https://web6502.puter.site/).  These systems will be ready to download and use Web6502 systems, with pre-configured devices and cards ready to go.  All the developer in this case would need to provide is a compatible 6502 program file to run it.
