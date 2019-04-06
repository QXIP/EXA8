#!/bin/bash

GO="1.10"
INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="1.0"
VERSION_MINOR="0"
PROJECT_NAME="pcapdaemon"
TMP_DIR="/tmp/$PROJECT_NAME"

echo "Initiating builder..."
apt update
apt -y install git wget curl golang-$GO libpcap-dev

export GOARCH=arm64
export GOROOT=/usr/lib/go-$GO
export GOPATH=/usr
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

cd /usr/src
git clone https://github.com/danmia/pcapdaemon
cd pcapdaemon

go get -d -v ./...
#go tool vet -all -v . || true
#go generate -v ./...
go build -v ./...

if [ $? -eq 0 ]
then
     GOBIN=$TMP_DIR/usr/local/bin/ go install
     cp ./pcapdaemon $TMP_DIR/usr/local/bin/
     mkdir "$TMP_DIR"
     mkdir -p $TMP_DIR/usr/local/bin
     mkdir -p $TMP_DIR/etc
     cp pcapdaemon.conf.example $TMP_DIR/etc/pcapdaemon.conf

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


