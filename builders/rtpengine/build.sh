#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="7.3"
VERSION_MINOR="0"
PROJECT_NAME="rtpengine"
TMP_DIR="/tmp/$PROJECT_NAME"
ENV DEBIAN_FRONTEND noninteractive
VERSION=2.4

echo "Initiating builder..."
apt-get update
apt-get install -y build-essential git bison flex pkg-config
apt-get install -y debhelper libmysqlclient-dev gperf iptables-dev libavcodec-dev libavfilter-dev libavformat-dev libavutil-dev libbencode-perl libcrypt-openssl-rsa-perl libcrypt-rijndael-perl libcurl4-openssl-dev libdigest-crc-perl libdigest-hmac-perl libevent-dev libglib2.0-dev libhiredis-dev libio-multiplex-perl libio-socket-inet6-perl libjson-glib-dev libnet-interface-perl libpcap0.8-dev libpcre3-dev libsocket6-perl libssl-dev libswresample-dev libsystemd-dev libxmlrpc-core-c3-dev markdown zlib1g-dev

cd /usr/src
git clone https://github.com/sipwise/rtpengine.git rtpengine
cd rtpengine

#mk-build-deps -i
dpkg-buildpackage -d

#mkdir "$TMP_DIR"
#make install ${TMP_DIR}

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
else
    echo "Failed! Exiting..."
#    exit 1;
fi

ls -alF ../*.deb
cp -v ../*.deb ${TMP_DIR}


