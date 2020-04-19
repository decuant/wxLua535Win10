# Project Description

## 0.0.2 (19-Apr-2020)

**wxLua535Win10** is a container for **wxWidgets-3.1.3** built against **Lua 5.3.5**.

This project aims to relieve lazy programmmers to recompile the 3 projects.

Project's name uses **Win10** suffix to not overwrite any official name from the wxLua team.

Have fun with Lua!

## Features

Compilation of **lua.exe** with embedded manifest to define the [High DPI Aware] flag. It needs lua53.dll to run, thus it does not follow the recommendation of including all sources.

The **lua.exe** and **lua53.dll** use the original released sources with no wizardries. This project might differ from other pre-built distributions, it will accept only the new binary operators. You can see it for yourself trying using **bit32**, in case of abort because of deprecation then you are using the original sources, otherwise you have a non-standard distribution. It might not be such a big issue on your side.

The **wxLua 3.0.0.8** in this project is not standard as it has to accomodate for the binary operators issue as said above. Basically, I commented out a few lines of code...

Compiled with Visual Studio Pro. 2015, version 14.0.25431.01 update 3.

Supported platform is Windows 10.0.14393.0 (not Windows 8.1).

These are Release versions with no debug information, **32 bits**.

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

1. If you use ZeroBrane then be aware that by default the Lua 5.3 in use is the one shipped with ZeroBrane, which is ok, but not the original 5.3.5.

2. You might have to fix your existing code because of the many deprecated constants and (some) functions in wxWidgets, the latest release I was using was wxWidgets 2.8.12.

3. I will restructure this project folders' structure, to provide a 64 bits release, since Lua 5.3.5 has a 64 bits mindset, but this is not my priority.

4. Provided samples are just a quick test for correct installation.


## Author

The autor can be reached at decuant@gmail.com


## License

The standard MIT license applies.
