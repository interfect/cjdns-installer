# Installer for cjdns on Windows

## About

License: GPLv3

Source code for cjdns is available [here](https://github.com/interfect/cjdns) or from the official repository [here](https://github.com/cjdelisle/cjdns).

The installer itself is written in Nullsoft Scriptable Install System script. It also includes a Windows service, CjdnsService, which takes care of starting up cjdns on boot and restarting it if it dies.

## Dependencies

You must have [Nullsoft Scriptable Install System](http://nsis.sourceforge.net/Main_Page) installed on your Windows box in order to build the installer.

You also need to install the [NSIS Simple Service Plugin](http://nsis.sourceforge.net/NSIS_Simple_Service_Plugin). Make sure to put the DLL in the ANSI folder.

To rebuild CjdnsService, you should probably use [SharpDevelop](http://www.icsharpcode.net/opensource/sd/).

## Installation Dependencies

The installer should run just fine on Windows 7 x64. Nothing else has been tested.

The CjdnsService component requires .NET 2 or later in order to work.

## Building

To build the installer, right-click on `installer.nsi` and hit "Compile NSIS Script".

To re-build CjdnsService, open up the solution file in SharpDevelop and hit the build button. Then replace the `CjdnsService.exe` in the `installation` directory with your new copy, and re-build the installer.

To re-build cjdns itself, produce your favorite cjdns build for Windows, and replace all the cjdns EXE files in `installation` with your own. Then re-build the installer.
