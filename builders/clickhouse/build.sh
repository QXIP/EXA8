#!/bin/bash

INV=1
OS="bionic"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="3.0"
VERSION_MINOR="0"
PROJECT_NAME="clickhouse"
TMP_DIR=/tmp/$PROJECT_NAME
TMP_BUILD=/tmp/build
THREADS=$(grep -c ^processor /proc/cpuinfo)

echo "Initiating builder..."
apt-get update
apt-get install -y git bash cmake ninja-build libicu-dev libreadline-dev libicu-dev libreadline-dev libmysqlclient-dev libssl-dev unixodbc-dev devscripts dupload fakeroot debhelper sudo pbuilder debootstrap devscripts
touch /root/.pbuilderrc

apt-get install software-properties-common -y
apt-add-repository ppa:ubuntu-toolchain-r/test -y
apt-get update
apt-get install gcc-7 g++-7 -y

export CC=gcc-7
export CXX=g++-7
export CMAKE_CXX_COMPILER=`which g++-7| head -n1`
export CMAKE_C_COMPILER=`which gcc-7| head -n1`

cd /usr/src
git clone --recursive --branch stable https://github.com/yandex/ClickHouse.git
cd ClickHouse

# ./release --fast --no-pbuilder

mkdir -p build
cd build
cmake ..
cmake --build .

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
else
    echo "Failed! Exiting..."
#    exit 1;
fi

mkdir -p $TMP_DIR
make DESTDIR=$TMP_DIR install


apt-get -y install ruby ruby-dev rubygems build-essential
gem install --no-ri --no-rdoc fpm

fpm -s dir -t deb -C ${TMP_DIR} \
	--name ${PROJECT_NAME} --version ${VERSION_MAJOR}  -p "${PROJECT_NAME}_${VERSION_MAJOR}-${INV}.${OS}.${ARCH}.deb" \
	--iteration 1 --deb-no-default-config-files --description ${PROJECT_NAME} .

ls -alF *.deb
cp -v *.deb /scripts


