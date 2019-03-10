<img src="http://cubro.org/images/EXA8_Banner.jpg" width=500>

# CUBRO EXA8
## Cross-Compiling for EXA8
The EXA8 ships by default with OS Ubuntu Xenial for ARM64. Developers can easily cross-compile software for the platform using Docker and the `arm64v8/ubuntu:xenial` image

### QEMU
QEMU is required on the Docker host in order to execute arm64/aarch64 code:
```
apt-get install -y qemu-user-static qemu-user
```
### Build Pipeline
The following pipeline can be used as example to map quemu and launch any script within the Arm64 container: 
```
docker run --rm \
  -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static \
  -v $(pwd)/:/tmp/build \
  --entrypoint=/scripts/builder.sh \
  arm64v8/ubuntu:xenial
```

Create a script (`builder.sh`) to build your application inside the running container and saving to `/tmp/build`

### FPM Packaging
FPM can be used to produce `deb` packages for the EXA8 OS in a few simple steps
##### Install `fpm` inside the container
```
apt-get -y install ruby ruby-dev rubygems build-essential
gem install --no-ri --no-rdoc fpm
```
##### Compile and Install
```
mkdir /tmp/mycode
make && make DESTDIR=/tmp/mycode install```
```

##### Create a Package
```
fpm -s dir -t deb -C /tmp/mycode \
	--name ${VERSION_NAME} --version ${VERSION_PROJECT}  -p "${VERSION_NAME}_${VERSION_PROJECT}-${INV}.${OS}.${ARCH}.deb" \
	--iteration 1 --deb-no-default-config-files --depends ${DEPENDENCY} --description "rtpagent" .
  
cp -v *.deb /tmp/build
```
