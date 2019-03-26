#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="1.0"
VERSION_MINOR="0"
PROJECT_NAME="stenographer"
TMP_DIR="/tmp/$PROJECT_NAME"

echo "Initiating builder..."
apt update
apt -y install git wget curl sudo

cd /usr/local && \
    curl -sLO https://dl.google.com/go/go1.10.4.linux-armv6l.tar.gz && \
    tar xfz go1.10.4.linux-armv6l.tar.gz && \
    rm go1.10.4.linux-armv6l.tar.gz && \
    cd /root && \
    mkdir -p go/bin go/pkg

GOROOT="/usr/local/go"
GOPATH="/root/go"
PATH="${GOROOT}/bin:${PATH}"
PATH="${GOPATH}/bin:${PATH}"

go version

exit 1;

cd /usr/src
git clone https://github.com/google/stenographer
cd stenographer
cp /scripts/install.sh ./
chmod +x install.sh
export ROOT=$TMP_DIR
./install.sh

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
cp -v *.deb ${TMP_DIR}


