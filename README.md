# Installer for cjdns on Windows

## About

License: GPLv3

Source code for cjdns is available from the official repository [here](https://github.com/cjdelisle/cjdns).

The installer itself is written in Nullsoft Scriptable Install System script. It also includes a Windows service, CJDNS Watchdog Service, which takes care of starting up cjdns on boot and restarting it if it dies.

## Dependencies

You must have [Nullsoft Scriptable Install System](http://nsis.sourceforge.net/Main_Page) installed on your Windows box in order to build the installer.

You also need to install the [NSIS Simple Service Plugin](http://nsis.sourceforge.net/NSIS_Simple_Service_Plugin) and the [ShellLink plugin](http://nsis.sourceforge.net/ShellLink_plug-in). Make sure to put the proper DLLs into both the x86-ansi and x86-unicode folders of your NSIS installation directory.

To rebuild CjdnsService, you should use [Visual Studio 2022](https://visualstudio.microsoft.com/vs/community/) and [.NET 6](https://dotnet.microsoft.com/en-us/download/dotnet/6.0).

## Installation Dependencies

The installer should run just fine on Windows 7 x64. Nothing else has been tested.

## Building

The repository includes built cjdns binaries, prepared [using this procedure as a guide](https://github.com/hyperboria/docs/blob/master/install/windows.md). 

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

The built cjdns exe files will be in the `/target/x86_64-pc-windows-gnuls/release/` folder, copy them into the repo's `installation` directory.

Try to run cjdroute.exe. If you get the "libssp-0.dll was not found" error, download it from [the LLVM based mingw-w64 toolchain repo](https://github.com/mstorsjo/llvm-mingw/releases) and copy next to the exe files.

To re-build the CJDNS Watchdog Service, open up the `CjdnsService.sln` solution file in Visual Studio, right click on the project, `Publish...` and click `Publish`. Then replace the `cjdnsservice.exe` in the `installation` directory with your new copy.

To build the installer, right-click on `installer.nsi` and hit "Compile NSIS Script".

## Running cjdns

The installer will, by default, install a TAP driver, cjdns, and a Windows service that starts cjdns on boot. It will generate a configuration file at `C:\Program Files (x86)\cjdns\cjdroute.conf`, or wherever you installed it to, and then start cjdns.

To configure cjdns, edit that configuration file, and then issue `net stop cjdns` and `net start cjdns` as administrator (or just reboot).
