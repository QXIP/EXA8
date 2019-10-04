#!/bin/bash
apt-get install -y qemu-user-static qemu-user

#ARM64 (aarch64)
docker run -ti --rm --name heplify-builder -v /usr/bin/qemu-qemu-mips64el-static:/usr/bin/qemu-mips64el-static -v $(pwd)/:/tmp/build -v $(pwd)/:/scripts --entrypoint=/scripts/build_mips.sh hypnza/qemu_debian_mipsel

