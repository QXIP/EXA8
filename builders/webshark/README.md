# webShark on EXA8

### Setup
```
git clone https://bitbucket.org/jwzawadzki/webshark
cd webshark
```
#### Build `sharkd` for aarch64 using Docker
```
docker run -ti --rm --name armbuilder -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static -v $(pwd)/sharkd:/scripts -v $(pwd):/out --entrypoint=/scripts/build.sh arm64v8/ubuntu:xenial
```
