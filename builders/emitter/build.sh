#!/bin/bash

GO="1.10"
INV=3
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="2.679"
VERSION_MINOR="3"
PROJECT_NAME="emitter"
TMP_DIR="/tmp/$PROJECT_NAME"

echo "Initiating builder..."


apt-get update
apt-get install -y golang-$GO git curl libpcap-dev

export GOARCH=arm64
export GOROOT="/usr/lib/go-$GO"
export PATH=$PATH:$GOROOT/bin
go version

echo "Initiating compiler..."
go get -u github.com/emitter-io/emitter
cd /root/go/src/github.com/emitter-io/emitter/
go get -d -v ./...
CGO_ENABLED=1 GOOS=linux GOARCH=arm64 go build -a -ldflags '-extldflags "-static"' -o emitter -v
chmod +x emitter

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
	mkdir -p $TMP_DIR/usr/bin
	cp emitter $TMP_DIR/usr/bin
	mkdir -p $TMP_DIR/etc
	cp emitter.conf $TMP_DIR/etc/emitter.conf
	mkdir -p $TMP_DIR/etc/systemd/system
	cat > $TMP_DIR/etc/systemd/system/emitter.service << EOL
[Unit]
Description=Emitter-io
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
ExecStart=/usr/bin/emitter -c /etc/emitter.conf

[Install]
WantedBy=multi-user.target
EOL

else
    echo "Failed! Exiting..."
    exit 1;
fi

apt-get -y install ruby ruby-dev rubygems build-essential
gem install --no-ri --no-rdoc fpm

fpm -s dir -t deb -C ${TMP_DIR} \
	--name ${PROJECT_NAME} --version ${VERSION_MAJOR}  -p "${PROJECT_NAME}_${VERSION_MAJOR}.${VERSION_MINOR}-${INV}.${OS}.${ARCH}.deb" \
	--iteration 1 --deb-no-default-config-files --description ${PROJECT_NAME} .

ls -alF *.deb
cp -v *.deb /scripts


