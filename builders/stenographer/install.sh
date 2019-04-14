#!/bin/bash

# Copyright 2014 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This is not meant to be a permanent addition to stenographer, more of a
# hold-over until we can get actual debian packaging worked out.  Also, this
# will probably guide the debian work by detailing all the actual stuff that
# needs to be done to install stenographer correctly.

ROOT="${ROOT-}"
BINDIR="${BINDIR-$ROOT/usr/bin}"

cd "$(dirname $0)"
source lib.sh

set -e
Info "Making sure we have sudo access"
sudo cat /dev/null

apt install -y libaio-dev
apt install -y libleveldb-dev
apt install -y libsnappy-dev
apt install -y g++
apt install -y libcap2-bin
apt install -y libseccomp-dev
apt install -y jq
apt install -y openssl

Info "Building stenographer"
go get -v
go build -v


Info "Building stenotype"
pushd stenotype
make
popd

Info "Installing to path: $ROOT"
set +e

mkdir -p $ROOT/etc/security/limits.d
if [ ! -f $ROOT/etc/security/limits.d/stenographer.conf ]; then
  Info "Setting up stenographer limits"
  sudo cp -v configs/limits.conf $ROOT/etc/security/limits.d/stenographer.conf
fi

mkdir -p $ROOT/etc/init
if [ -d $ROOT/etc/init/ ]; then
  if [ ! -f $ROOT/etc/init/stenographer.conf ]; then
    Info "Setting up stenographer upstart config"
    sudo cp -v configs/upstart.conf $ROOT/etc/init/stenographer.conf
    sudo chmod 0644 $ROOT/etc/init/stenographer.conf
  fi
fi

mkdir -p $ROOT/lib/systemd/system
if [ -d $ROOT/lib/systemd/system/ ]; then
  if [ ! -f $ROOT/lib/systemd/system/stenographer.service ]; then
    Info "Setting up stenographer systemd config"
    sudo cp -v configs/systemd.conf $ROOT/lib/systemd/system/stenographer.service
    sudo chmod 644 $ROOT/lib/systemd/system/stenographer.service
  fi
fi

mkdir -p $ROOT/etc/stenographer
if [ ! -d $ROOT/etc/stenographer/certs ]; then
  Info "Setting up stenographer /etc directory"
  sudo mkdir -p $ROOT/etc/stenographer/certs
  if [ ! -f $ROOT/etc/stenographer/config ]; then
    sudo cp -vf configs/steno.conf $ROOT/etc/stenographer/config
    sudo chmod 644 $ROOT/etc/stenographer/config
  fi
fi

mkdir -p $BINDIR/usr/bin

sudo ./stenokeys.sh stenographer stenographer
sudo cp -vfR /etc/stenographer/certs $ROOT/etc/stenographer/


Info "Copying stenographer/stenotype"
sudo cp -vf stenographer "$BINDIR/stenographer"
sudo chmod 0700 "$BINDIR/stenographer"
sudo cp -vf stenotype/stenotype "$BINDIR/stenotype"
sudo chmod 0500 "$BINDIR/stenotype"
SetCapabilities "$BINDIR/stenotype"

Info "Copying stenoread/stenocurl"
sudo cp -vf stenoread "$BINDIR/stenoread"
sudo chmod 0755 "$BINDIR/stenoread"
sudo cp -vf stenocurl "$BINDIR/stenocurl"
sudo chmod 0755 "$BINDIR/stenocurl"

Info "Completed installing to $ROOT"
ls -alF $ROOT
