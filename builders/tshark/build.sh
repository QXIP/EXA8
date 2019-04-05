#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="3.0"
VERSION_MINOR="0"
PROJECT_NAME="tshark"
TMP_DIR=/tmp/$PROJECT_NAME

echo "Initiating builder..."
apt update
apt -y install git wget curl python3
apt -y install build-essential automake autoconf libglib2.0-dev libpcap0.8-dev flex bison cmake libgcrypt11-dev zlib1g-dev

cd /usr/src
git clone https://github.com/wireshark/wireshark

echo "Compiling $PROJECT_NAME ..."
cd wireshark
mkdir build
cd build
cmake -DBUILD_wireshark=0 ../

make
make DESTDIR=$TMP_DIR install

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
else
    echo "Failed! Exiting..."
    exit 1;
fi

apt-get -y install ruby ruby-dev rubygems build-essential
gem install --no-ri --no-rdoc fpm

fpm -s dir -t deb -C ${TMP_DIR} \
	--name ${PROJECT_NAME} --version ${VERSION_PROJECT}  -p "${VERSION_NAME}_${VERSION_PROJECT}-${INV}.${OS}.${ARCH}.deb" \
	--iteration 1 --deb-no-default-config-files --description ${PROJECT_NAME} .

ls -alF *.deb
cp -v *.deb ${TMP_DIR}


