#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="18.05"
VERSION_MINOR="0"
PROJECT_NAME="dpdk"
TMP_DIR="/tmp/$PROJECT_NAME"

echo "Initiating builder..."
apt update
apt -y install git
apt -y install build-essential automake autoconf

cd /usr/src

echo "Installing numactl..."
git clone https://github.com/numactl/numactl.git
cd numactl
git checkout v2.0.11 -b v2.0.11
./autogen.sh
autoconf -i
./configure --host=aarch64-linux-gnu CC=aarch64-linux-gnu-gcc --prefix=/usr/numactl
make install
cd ..

echo "Initiating dpdk..."
wget http://fast.dpdk.org/rel/dpdk-18.05.1.tar.xz .
cd dpdk
make -j C EXTRA_CFLAGS="-isystem /usr/numactl/include" EXTRA_LDFLAGS="-L/usr/numactl/lib -lnuma"
cd ..

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
else
    echo "Failed! Exiting..."
    exit 1;
fi

cd src
make

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
else
    echo "Failed! Exiting..."
    exit 1;
fi

mkdir "$TMP_DIR"
make install ${TMP_DIR}


apt-get -y install ruby ruby-dev rubygems build-essential
gem install --no-ri --no-rdoc fpm

fpm -s dir -t deb -C ${TMP_DIR} \
	--name ${PROJECT_NAME} --version ${VERSION_MAJOR}  -p "${PROJECT_NAME}_${VERSION_MAJOR}-${INV}.${OS}.${ARCH}.deb" \
	--iteration 1 --deb-no-default-config-files --description ${PROJECT_NAME} .

ls -alF *.deb
cp -v *.deb ${TMP_DIR}


