#!/bin/bash

GO="1.10"
INV=1
OS="stretch"
ARCH="mips64le"
INTERCEPTION=0
VERSION_MAJOR="1.47"
VERSION_MINOR="0"
PROJECT_NAME="heplify"
TMP_DIR="/tmp/$PROJECT_NAME"

echo "Initiating builder..."


apt-get update
#apt-get install -y golang-$GO git curl libpcap-dev
apt-get install -y golang git curl libpcap-dev

export GOPATH=/root/gopath
#export GOARCH=mips64
export GOROOT="/usr/lib/go"
export PATH=$PATH:$GOROOT/bin
go version

mkdir -p $GOPATH

echo "Initiating compiler..."
cd /usr/src
git clone https://github.com/sipcapture/heplify
cd heplify
go get -v github.com/google/gopacket/pcap
go get -d -v ./...
sed -i '/github.com\/cespare\/xxhash/d' /root/gopath/src/github.com/VictoriaMetrics/fastcache/bigcache.go
CGO_ENABLED=1 GOOS=linux go build -a -o heplify -v
chmod +x heplify

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
	mkdir -p $TMP_DIR/usr/bin
	cp heplify $TMP_DIR/usr/bin
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


