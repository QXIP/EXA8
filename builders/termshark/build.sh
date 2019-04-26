#!/bin/bash

GO="1.11"
INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="1.0"
VERSION_MINOR="0"
PROJECT_NAME="termshark"
TMP_DIR="/tmp/$PROJECT_NAME"

echo "Initiating builder..."


apt update
apt install -y software-properties-common
add-apt-repository ppa:gophers/archive
apt update
apt  install -y golang-$GO git curl

export GOARCH=arm64
export GOROOT="/usr/lib/go-$GO"
export PATH=$PATH:$GOROOT/bin
export GO111MODULE=on
go version

echo "Initiating compiler..."
cd /usr/src
git clone https://github.com/gcla/termshark
cd termshark
go build cmd/termshark/termshark.go
chmod +x termshark

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
	mkdir -p $TMP_DIR/usr/bin
	cp termshark $TMP_DIR/usr/bin
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
cp -v *.deb /scripts


