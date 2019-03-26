#!/bin/bash
apt-get install -y qemu-user-static qemu-user

#ARM64 (aarch64)
docker run --rm --name builder-rtpengine -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static -v $(pwd)/:/tmp/build -v $(pwd)/:/scripts --entrypoint=/scripts/build.sh arm64v8/ubuntu:xenial

