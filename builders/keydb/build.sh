#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="0.9"
VERSION_MINOR="2"
PROJECT_NAME="KeyDB"
TMP_DIR="/tmp/$PROJECT_NAME"

echo "Initiating builder..."
apt update
apt -y install git wget curl
apt -y install build-essential automake autoconf uuid-dev

cd /usr/src
git clone https://github.com/JohnSully/KeyDB keydb

echo "Compiling $PROJECT_NAME ..."
cd keydb
#git checkout RELEASE_0_9

# Hot-Patch!
sed -i '/\(\(deprecated\)\)$/d' src/server.h
make

if [ $? -eq 0 ]
then
     mkdir "$TMP_DIR"
     DESTDIR=${TMP_DIR} make install
else
    echo "Make Failed! Exiting..."
    exit 1;
fi

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
else
    echo "Make Install Failed! Exiting..."
    exit 1;
fi

apt-get -y install ruby ruby-dev rubygems build-essential
gem install --no-ri --no-rdoc fpm

fpm -s dir -t deb -C ${TMP_DIR} \
	--name ${PROJECT_NAME} --version ${VERSION_MAJOR}  -p "${PROJECT_NAME}_${VERSION_MAJOR}-${INV}.${OS}.${ARCH}.deb" \
	--iteration 1 --deb-no-default-config-files --description ${PROJECT_NAME} .

ls -alF *.deb
cp -v *.deb /scripts


