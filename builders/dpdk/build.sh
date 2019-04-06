#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="18.05"
VERSION_MINOR="1"
PROJECT_NAME="dpdk"
TMP_DIR="/tmp/$PROJECT_NAME"

echo "Initiating builder..."
apt update
apt -y install git wget curl build-essential automake autoconf libtool

cd /usr/src

echo "Installing numactl..."
#git clone https://github.com/numactl/numactl.git
#cd numactl
#git checkout v2.0.11 -b v2.0.11
#./autogen.sh
#autoconf -i
#./configure --host=aarch64-linux-gnu CC=aarch64-linux-gnu-gcc --prefix=/usr/numactl
# CAVIUM: --host=aarch64-thunderx-linux CC=aarch64-thunderx-linux-gnu-gcc
#make && make install
#cd ..
apt -y install libnuma-dev

echo "Initiating dpdk..."
wget http://fast.dpdk.org/rel/dpdk-18.05.1.tar.xz
tar -xJf dpdk-18.05.1.tar.xz
cd dpdk-stable-18.05.1

make config T=arm64-armv8a-linuxapp-gcc
# CAVIUM: make config T=arm64-thunderx-linux-gcc
make -j EXTRA_CFLAGS="-isystem /usr/numactl/include" EXTRA_LDFLAGS="-L/usr/numactl/lib -lnuma" CONFIG_RTE_KNI_KMOD=n CONFIG_RTE_EAL_IGB_UIO=n
# make -j CONFIG_RTE_KNI_KMOD=n CONFIG_RTE_EAL_IGB_UIO=n EXTRA_CFLAGS="-isystem /usr/numactl/include" EXTRA_LDFLAGS="-L/usr/numactl/lib -lnuma"

export RTE_SDK=$PWD
export RTE_TARGET=build

#cd examples/helloworld
#make
#cd ..

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
else
    echo "Failed! Exiting..."
    exit 1;
fi

mkdir "$TMP_DIR"
make DESTDIR=${TMP_DIR} install

mkdir "$TMP_DIR"-sdk
mkdir -p "$TMP_DIR"-sdk/usr/share/dpdk
make clean
cp -r ./* "$TMP_DIR"-sdk/usr/share/dpdk/

apt-get -y install ruby ruby-dev rubygems build-essential
gem install --no-ri --no-rdoc fpm

fpm -s dir -t deb -C ${TMP_DIR} \
	--name ${PROJECT_NAME} --version ${VERSION_MAJOR}  -p "${PROJECT_NAME}_${VERSION_MAJOR}-${INV}.${OS}.${ARCH}.deb" \
	--iteration 1 --deb-no-default-config-files --description ${PROJECT_NAME} .

fpm -s dir -t deb -C ${TMP_DIR}-sdk \
	--name ${PROJECT_NAME}-sdk --version ${VERSION_MAJOR}  -p "${PROJECT_NAME}-sdk_${VERSION_MAJOR}-${INV}.${OS}.${ARCH}.deb" \
	--iteration 1 --deb-no-default-config-files --description ${PROJECT_NAME}-sdk .

ls -alF *.deb
cp -v *.deb /scripts


