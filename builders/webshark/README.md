# webShark on EXA8

### Setup
```
./webshark-install.sh
./webshark-start.sh
```

#### Build `sharkd` for aarch64 using Docker
```
docker run -ti --rm --name armbuilder -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static -v $(pwd)/sharkd:/scripts -v $(pwd):/out --entrypoint=/scripts/build.sh arm64v8/ubuntu:xenial
```

#### Run 
```
docker run -ti --rm --name armbuilder -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static -v $(pwd):/scripts -v $(pwd)/pcap:/caps -v --entrypoint=/scripts/webshark-start.sh arm64v8/ubuntu:xenial
```
