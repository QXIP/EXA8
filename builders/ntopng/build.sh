#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="4.0"
VERSION_MINOR="0"
PROJECT_NAME="ntopng"
TMP_DIR="/tmp/$PROJECT_NAME"

echo "Initiating builder..."
apt update
apt -y install git wget curl
curl -s https://packagecloud.io/install/repositories/qxip/cubro-pub/script.deb.sh | sudo bash
apt -y install build-essential git bison flex libxml2-dev libpcap-dev libtool libtool-bin rrdtool librrd-dev autoconf pkg-config automake autogen redis-server wget libsqlite3-dev libhiredis-dev libmaxminddb-dev libcurl4-openssl-dev libpango1.0-dev libcairo2-dev libnetfilter-queue-dev zlib1g-dev libssl-dev libcap-dev libnetfilter-conntrack-dev libreadline-dev libjson-c-dev libldap2-dev geoipupdate
apt -y install libpng-dev libzmq5-dev default-libmysqlclient-dev geoipupdate
apt -y install libtool-bin libmariadb-client-lgpl-dev libnuma-dev libzmq3-dev

mkdir =p "$TMP_DIR"

cd /usr/src
git clone https://github.com/ntop/nDPI.git
cd nDPI; ./autogen.sh; ./configure; make; cd ..

git clone https://github.com/ntop/ntopng
cd ntopng
./autogen.sh
./configure && make
make install prefix=${TMP_DIR}

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
	--name ${PROJECT_NAME} --version ${VERSION_MAJOR}  -p "${PROJECT_NAME}_${VERSION_MAJOR}-${INV}.${OS}.${ARCH}.deb" \
	--iteration 1 --deb-no-default-config-files --description ${PROJECT_NAME} .

ls -alF *.deb
cp -v *.deb /scripts/


