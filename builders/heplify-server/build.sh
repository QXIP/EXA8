#!/bin/bash

GO="1.10"
INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="1.08"
VERSION_MINOR="0"
PROJECT_NAME="heplify-server"
TMP_DIR="/tmp/$PROJECT_NAME"

echo "Initiating builder..."


apt-get update
apt-get install -y golang-$GO git curl libpcap-dev

export GOARCH=arm64
export GOROOT="/usr/lib/go-$GO"
export PATH=$PATH:$GOROOT/bin
go version

echo "Initiating compiler..."
cd /usr/src
git clone https://github.com/sipcapture/heplify-server
cd heplify-server
go get -u -d -v github.com/sipcapture/heplify-server/...
CGO_ENABLED=1 GOOS=linux GOARCH=arm64 go build -a -o heplify-server -v cmd/heplify-server/*.go
chmod +x heplify-server

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
	mkdir -p $TMP_DIR/usr/bin
	cp heplify-server $TMP_DIR/usr/bin
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


