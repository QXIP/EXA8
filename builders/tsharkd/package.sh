#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="3.0"
VERSION_MINOR="2"
PROJECT_NAME="sharkd"
VERSION_PROJECT=$VERSION_MAJOR-$VERSION_MINOR
TMP_DIR=/tmp/$PROJECT_NAME

apt-get -y install ruby ruby-dev rubygems build-essential
gem install --no-ri --no-rdoc fpm

fpm -s dir -t deb -C ${TMP_DIR} \
	--iteration 1 --deb-no-default-config-files --description ${PROJECT_NAME} \
	--name ${PROJECT_NAME} --version ${VERSION_PROJECT}  . \

ls -alF *.deb


