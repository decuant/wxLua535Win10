# Project Description

## 0.0.3 (20-Apr-2020)

**wxLua535Win10** is a container for **wxWidgets-3.1.3** built against **Lua 5.3.5**.

This project aims to relieve lazy programmmers to recompile the 3 projects.

Project's name uses **Win10** suffix to not overwrite any official name from the wxLua team.

Platforms 32bit and 64bit.

I have added a signature folder to check executables if 32bit or 64bit. Property of SysInternals.

Have fun with Lua!

## Features

Compilation of **lua.exe** with embedded manifest to define the [High DPI Aware] flag, it needs lua53.dll to run. Static link of ``luac.exe``.

The **lua.exe** and **lua53.dll** use the original released sources with no wizardries. This project might differ from other pre-built distributions, it will accept only the new binary operators. You can see it for yourself trying using **bit32**, in case of abort because of deprecation then you are using the original sources, otherwise you have a non-standard distribution. It might not be such a big issue on your side.

The **wxLua 3.0.0.8** in this project is not standard as it has to accomodate for the binary operators issue as said above. Basically, I commented out a few lines of code...

Compiled with Visual Studio Pro. 2015, version 14.0.25431.01 update 3.

Supported platform is Windows 10.0.14393.0 (not Windows 8.1), both 32bit and 64bit.

Build of each project (cascade to subprojects) has full optimization favouring speed.

32bit: C and C++ code generation will profit of [Streaming SIMD Extensions 2 (/arch:SSE2)] instruction set (if applicable).

Uses sources from:

Lua 5.3.5
wxWidgets-3.1.3
wxLua 3.0.0.8

Uses CMake for building wx.dll

CMake 3.17.0

## Installation

1. Copy files to a directory of choice (something like c:\wxLua535\bin).
2. Copy ``exe`` and ``dll`` files in ``bin\32bit`` or ``bin\64bit`` to ``bin`` (a folder up...).
3. Open the Windows' control panel and the Advanced System Settings.
4. Open the Environment Variables editor.
5. Create an entry for the User with the following line: 
	``LUA_CPATH=c:\wxLua535\bin\?.dll``
6. Add c:\wxLua535\bin to the User's PATH variable:

![Windows Environment](/doc/Environment.png)

## Notes

1. If you use ZeroBrane then be aware that by default the Lua 5.3 in use is the one shipped with ZeroBrane, which is ok, but not the original 5.3.5.

2. You can change ZeroBrane's lua53.exe with a 64bit implementation (or original 32bit):

    .a Open a Command Prompt with Admin Privilegies and cd "C:\Program Files (x86)\ZeroBrane\bin"
    .b Rename ``lua53.exe`` to ``__lua53.exe``
    .c Rename ``lua53.dll`` to ``__lua53.dll``
    .d Issue  ``mklink "C:\Program Files (x86)\ZeroBrane\bin\lua53.exe" C:\wxLua535\bin\lua.exe``

    Will work right away. The compile funtion will fail on binary operators (I suppose it uses an older release), and the debugger fails because ``socket.core`` is 32bit.

2. You might have to fix your existing code because of the many deprecated constants and (some) functions in wxWidgets, the latest release I was using was wxWidgets 2.8.12.

3. You cannot mix 32bit and 64bit modules! If unsure run ``sigcheck64.exe`` (see screenshots in doc folder).

4. Provided samples are just a quick test for correct installation.


## Author

The autor can be reached at decuant@gmail.com


## License

The standard MIT license applies.
