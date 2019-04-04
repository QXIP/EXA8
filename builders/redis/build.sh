#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="0.9"
VERSION_MINOR="2"
PROJECT_NAME="redis"
TMP_DIR="/tmp/$PROJECT_NAME"

echo "Initiating builder..."
apt update
apt -y install git wget curl build-essential tcl

echo "Download, Compile, and Install Redis"
cd /usr/src
curl -O http://download.redis.io/redis-stable.tar.gz
tar xzvf redis-stable.tar.gz
cd redis-stable

echo "Build and Install Redis"
make

if [ $? -eq 0 ]
then
     mkdir "$TMP_DIR"
     DEST=${TMP_DIR} make install
else
    echo "Make Failed! Exiting..."
    exit 1;
fi

echo "Configure Redis"
mkdir -p $TMP_DIR/etc/redis
cp /usr/src/redis-stable/redis.conf $TMP_DIR/etc/redis

sed -i -e 's/supervised no/supervised systemd/g' $TMP_DIR/etc/redis/redis.conf
sed -i -e 's/dir .\//dir \/var\/lib\/redis/g' $TMP_DIR/etc/redis/redis.conf

echo "[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
User=redis
Group=redis
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
Restart=always

[Install]
WantedBy=multi-user.target" > $TMP_DIR/etc/systemd/system/redis.service

echo "Create the Redis User, Group and Directories"
mkdir -p $TMP_DIR/var/lib/redis
chmod 770 $TMP_DIR/var/lib/redis

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


