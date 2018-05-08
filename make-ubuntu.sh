#!/bin/bash

# Ubuntu 16.04 build script

for pkg in nsis nsis-pluginapi mingw-w64; do
  if ! dpkg -s "$pkg" > /dev/null 2> /dev/null; then
    need_pkg="$need_pkg $pkg"
  fi
done

if [ ! -z "$need_pkg" ]; then
  echo "The following packages need to be installed: $need_pkg..."
  sudo apt install $need_pkg -y
fi

if [ ! -z "$REBUILD_CJDNS" ]; then
  # Set REBUILD_CJDNS=1 to rebuild
  ([ ! -e cjdns ] && git clone git@github.com:cjdelisle/cjdns) || git -C cjdns pull # clone to cjdns or pull if already cloned
  pushd cjdns
  git checkout cjdns-v20.2
  SYSTEM=win32 CROSS_COMPILE=i686-w64-mingw32- ./cross-do
  cp *.exe ../installation
  popd
fi

bash ./make-install-local-plugins.sh
