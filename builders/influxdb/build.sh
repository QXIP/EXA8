#!/bin/bash

GO="1.11"
INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="1.0"
VERSION_MINOR="0"
PROJECT_NAME="influxdb"
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
git clone https://github.com/influxdata/influxdb
cd influxdb
#go get -d -v ./...
#CGO_ENABLED=1 GOOS=linux GOARCH=arm64 go build -a -o pcap_exporter -v
#go build

make

chmod +x influxd
chmod +x influx

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
	mkdir -p $TMP_DIR/usr/bin
	cp influxd $TMP_DIR/usr/bin
	cp influx $TMP_DIR/usr/bin
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


