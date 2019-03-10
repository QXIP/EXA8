<img src="http://cubro.org/images/EXA8_Banner.jpg" width=500>

# CUBRO EXA8
## Cross-Compiling for EXA8
The EXA8 ships by default with OS Ubuntu Xenial for ARM64. Developers can easily cross-compile software for the platform using Docker and the `arm64v8/ubuntu:xenial` image

### QEMU
QEMU is required on the Docker host in order to execute arm64/aarch64 code:
```
apt-get install -y qemu-user-static qemu-user
```

### Docker pipeline
Create a script (`builder.sh`) with commands to build your application inside the running container.
```
git clone https://github.com/example/my_arm_app.git
cd my_arm_app.git
make
```

The following pipeline can be used as example to map qemu and launch any script within the `arm64v8/ubuntu:xenial` container: 
```
docker run --rm \
  -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static \
  -v $(pwd)/:/tmp/build \
  --entrypoint=/scripts/builder.sh \
  arm64v8/ubuntu:xenial
```


----------

### DEB Packaging
[FPM](https://github.com/jordansissel/fpm) can be used to easily generate `deb` packages for our platform in a few simple steps
##### Install `fpm`
Inside the running container install `fpm` and its requirements before compiling your code
```
apt-get -y install ruby ruby-dev rubygems build-essential
gem install --no-ri --no-rdoc fpm
```
##### Compile
Compile and Install your code to a custom directory, later used to create the package
```
mkdir /tmp/mycode
make && make DESTDIR=/tmp/mycode install```
```

##### Create a Package
Launch fpm using the installation directory and adding your variables for name, version, etc:
```
fpm -s dir -t deb -C /tmp/mycode \
	--name ${VERSION_NAME} --version ${VERSION_PROJECT}  -p "${VERSION_NAME}_${VERSION_PROJECT}-${INV}.${OS}.${ARCH}.deb" \
	--iteration 1 --deb-no-default-config-files --depends ${DEPENDENCY} --description "rtpagent" .
```

##### Copy Package
Last but not least, copy the generated package the the mounted directory on the host:
```
cp -v *.deb /tmp/build
```
