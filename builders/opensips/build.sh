#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="2.4"
VERSION_MINOR="0"
PROJECT_NAME="opensips"
TMP_DIR="/tmp/$PROJECT_NAME"
ENV DEBIAN_FRONTEND noninteractive
VERSION=2.4

echo "Initiating builder..."
apt update
apt-get update -qq && apt-get install -y build-essential \
		git bison flex m4 pkg-config libncurses5-dev rsyslog

cd /usr/src
git clone https://github.com/OpenSIPS/opensips.git -b $VERSION opensips_$VERSION
cd opensips_$VERSION && make all && make install


mkdir "$TMP_DIR"
make install ${TMP_DIR}

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
else
    echo "Failed! Exiting..."
#    exit 1;
fi

apt-get -y install ruby ruby-dev rubygems build-essential
gem install --no-ri --no-rdoc fpm

fpm -s dir -t deb -C ${TMP_DIR} \
	--name ${PROJECT_NAME} --version ${VERSION_MAJOR}  -p "${PROJECT_NAME}_${VERSION_MAJOR}-${INV}.${OS}.${ARCH}.deb" \
	--iteration 1 --deb-no-default-config-files --description ${PROJECT_NAME} .

ls -alF *.deb
cp -v *.deb ${TMP_DIR}


