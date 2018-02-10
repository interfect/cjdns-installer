#!/bin/bash

# Ubuntu 16.04 build script

sudo apt install nsis nsis-pluginapi mingw-w64 -y

if [ ! -z "$REBUILD_CJDNS" ]; then
  # Set REBUILD_CJDNS=1 to rebuild
  ([ ! -e cjdns ] && git clone git@github.com:cjdelisle/cjdns) || git -C cjdns pull # clone to cjdns or pull if already cloned
  cd cjdns
  git checkout cjdns-v20.1
  SYSTEM=win32 CROSS_COMPILE=i686-w64-mingw32- ./cross-do
  cp *.exe ../installation
  cd ..
fi

bash ./make-install-local-plugins.sh
