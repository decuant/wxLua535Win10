# Project Description

## 0.0.1 (16-Apr-2020)

**wxLua535** is a container for **Lua 5.3.5**.

## Features

Compiled with Visual Studio Pro. 2015, version 14.0.25431.01 update 3.

Uses sources from:

Lua 5.3.5
wxWidgets-3.1.3
wxLua 3.0.0.8

Uses CMake for building wx.dll

CMake 3.17.0

## wxWidgets and Lua installation

Only the steps for installation on Windows will be listed. although it shall 
run on Linux and MacOs too.  

3. Copy files to a directory of choice (something like. c:\wxLua535\bin).  
4. Open the Windows' control panel and the Advanced System Settings.  
5. Open the Environment Variables editor.
6. Create an entry for the User with the following line: 
	``LUA_CPATH=c:\wxLua535\bin\?.dll``
7. Add c:\wxLua535\bin to the System's PATH variable:

![Windows Environment](/doc/Environment.png)


## Author

The autor can be reached at decuant@gmail.com


## License

The standard MIT license applies.
