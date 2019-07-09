#!/bin/bash

INV=1
OS="xenial"
ARCH="arm64"
INTERCEPTION=0
VERSION_MAJOR="3.0"
VERSION_MINOR="2"
PROJECT_NAME="sharkd"
TMP_DIR=/tmp/$PROJECT_NAME

echo "Initiating builder..."
apt update
apt -y install git wget curl python3
apt -y install build-essential automake autoconf libglib2.0-dev libpcap0.8-dev flex bison cmake libgcrypt11-dev zlib1g-dev libspandsp-dev

curl -s https://packagecloud.io/install/repositories/qxip/cubro-pub/script.deb.sh | bash
apt install libbcg729-dev libbcg729-0

cd /usr/src
git clone https://github.com/wireshark/wireshark
git clone https://bitbucket.org/jwzawadzki/webshark

echo "Compiling $PROJECT_NAME ..."
cd wireshark
cp -r ../webshark/sharkd ./

git reset --hard 711eb94438a031822686958d0dd90adfcf35438f   ## tested with this hash

# Integrate sharkd
patch -p1 < ../sharkd/sharkd.patch
patch -p1 < ../sharkd/sharkd_opt_memory.patch ## optional
cp ../sharkd/*.[ch] ./

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_C_FLAGS_RELEASE="-O3 -pipe" \
	-DENABLE_STATIC=ON -DENABLE_PLUGINS=OFF -DDISABLE_WERROR=ON \
	-DBUILD_wireshark=OFF -DBUILD_tshark=OFF -DBUILD_sharkd=ON -DBUILD_dumpcap=OFF -DBUILD_capinfos=OFF \
	-DBUILD_captype=OFF -DBUILD_randpkt=OFF -DBUILD_dftest=OFF -DBUILD_editcap=OFF -DBUILD_mergecap=OFF \
	-DBUILD_reordercap=OFF -DBUILD_text2pcap=OFF -DBUILD_fuzzshark=OFF \
	-DBUILD_androiddump=OFF -DBUILD_randpktdump=OFF -DBUILD_udpdump=OFF \
	-DENABLE_PCAP=OFF -DENABLE_GNUTLS=OFF \
	../

make -j8
cd run

strip sharkd

# make DESTDIR=$TMP_DIR install

if [ $? -eq 0 ]
then
    echo "Proceeding to packaging..."
    chmod +x sharkd
    mkdir -p ${TMP_DIR}/usr/local/bin ${TMP_DIR}/usr/local/share/wireshark
    cp sharkd ${TMP_DIR}/usr/local/bin/
    cp colorfilters ${TMP_DIR}/usr/local/share/wireshark/
else
    echo "Failed! Exiting..."
    exit 1;
fi

./package.sh

echo "done!"
