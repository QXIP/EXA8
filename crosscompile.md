<img src="http://cubro.org/images/EXA8_Banner.jpg">

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
  -v $(pwd)/:/scripts \
  --entrypoint=/scripts/builder.sh \
  arm64v8/ubuntu:xenial
```
