# Installer for cjdns on Windows

## About

License: GPLv3

Source code for cjdns is available [here](https://github.com/interfect/cjdns) or from the official repository [here](https://github.com/cjdelisle/cjdns).

The installer itself is written in Nullsoft Scriptable Install System script. It also includes a Windows service, CjdnsService, which takes care of starting up cjdns on boot and restarting it if it dies.

## Dependencies

You must have [Nullsoft Scriptable Install System](http://nsis.sourceforge.net/Main_Page) installed on your Windows box in order to build the installer.

You also need to install the [NSIS Simple Service Plugin](http://nsis.sourceforge.net/NSIS_Simple_Service_Plugin) and the [ShellLink plugin](http://nsis.sourceforge.net/ShellLink_plug-in). Make sure to put the DLLs in the ANSI folder.

To rebuild CjdnsService, you should probably use [SharpDevelop](http://www.icsharpcode.net/opensource/sd/).

## Installation Dependencies

The installer should run just fine on Windows 7 x64. Nothing else has been tested.

The CjdnsService component requires .NET 2 or later in order to work.

## Building

The repository includes built cjdns binaries, prepared [using this procedure](https://github.com/hyperboria/docs/blob/4274dbdffbc2f8b83138e4adcfe23d96013eafe7/install/windows.md). 

You can use [Ubuntu 22 on Windows 11](https://apps.microsoft.com/store/detail/ubuntu/9PDXGNCFSCZV?hl=en-us&gl=US) using [WSL](https://ubuntu.com/wsl), and run the following commands:

```
sudo apt install software-properties-common -y

sudo add-apt-repository ppa:deadsnakes/ppa -y

sudo apt update

sudo apt-get install mingw-w64 build-essential nodejs git python3.7

ls /usr/bin/python* -l

sudo ln -vfns /usr/bin/python3.7 /usr/bin/python3

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

rustup target add x86_64-pc-windows-gnuls

git clone https://github.com/cjdelisle/cjdns.git
cd cjdns

# SYSTEM=win32 CROSS_COMPILE=i686-w64-mingw32- ./cross-do

./windows_do
```

The built exe files will be in the `/target/x86_64-pc-windows-gnuls/release/` folder, copy them into the repo's `installation` directory.

Try to run cjdroute.exe. If you get the "libssp-0.dll was not found" error, download it from [the LLVM based mingw-w64 toolchain repo](https://github.com/mstorsjo/llvm-mingw/releases) and copy next to the exe files.

To build the installer, right-click on `installer.nsi` and hit "Compile NSIS Script".

To re-build CjdnsService, open up the solution file in SharpDevelop and hit the build button. Then replace the `CjdnsService.exe` in the `installation` directory with your new copy, and re-build the installer.

To re-build cjdns itself, produce your favorite cjdns build for Windows, and replace all the cjdns EXE files in `installation` with your own. Then re-build the installer.

## Running cjdns

The installer will, by default, install a TAP driver, cjdns, and a Windows service that starts cjdns on boot. It will generate a configuration file at `C:\Program Files (x86)\cjdns\cjdroute.conf`, or wherever you installed it to, and then start cjdns.

To configure cjdns, edit that configuration file, and then issue `net stop cjdns` and `net start cjdns` as administrator (or just reboot).
