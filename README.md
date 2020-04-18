# Project Description

## 0.0.1 (16-Apr-2020)

**wxLua535Win10** is a container for **wxWidgets-3.1.3** built against **Lua 5.3.5**.

This project aims to relieve lazy programmmers to recompile the 3 projects.

Project's name uses **Win10** suffix to not overwrite any official name from the wxLua team.

Have fun with Lua!

## Features

Compiled with Visual Studio Pro. 2015, version 14.0.25431.01 update 3.

Supported platform is Windows 10.0.14393.0 (not Windows 8.1).

Since the executables provided by Tecgraf/PUC-Rio are 32 bits then lua53.dll and wx.dll are 32 bits.

These are Release versions with no debug information.

Build of each project (cascade to subprojects) has full optimization favouring speed.

C and C++ code generation will profit of [Streaming SIMD Extensions 2 (/arch:SSE2)] instruction set (if applicable).

Uses sources from:

Lua 5.3.5
wxWidgets-3.1.3
wxLua 3.0.0.8

Uses CMake for building wx.dll

CMake 3.17.0

## Installation

1. Copy files to a directory of choice (something like c:\wxLua535\bin).  
2. Open the Windows' control panel and the Advanced System Settings.  
3. Open the Environment Variables editor.
4. Create an entry for the User with the following line: 
	``LUA_CPATH=c:\wxLua535\bin\?.dll``
5. Add c:\wxLua535\bin to the User's PATH variable:

![Windows Environment](/doc/Environment.png)

## Notes

1. If you use ZeroBrane then be aware that by default the Lua 5.3 in use is the one shipped with ZeroBrane, which is ok.

2. You might have to fix your existing code because of the many deprecated constants and (some) functions in wxWidgets, the latest release I was using was wxWidgets 2.8.12.

3. I will restructure this project folders' structure, to provide a 64 bits release, since Lua 5.3.5 has a 64 bits mindset, but this is not my priority.

4. Provided samples are just a quick test for correct installation.


## Author

The autor can be reached at decuant@gmail.com


## License

The standard MIT license applies.
