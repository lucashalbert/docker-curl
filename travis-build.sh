#!/bin/bash
cp Dockerfile.cross Dockerfile.${docker_arch}
sed -i "s|__BASEIMAGE_ARCH__|${docker_arch}|g" Dockerfile.${docker_arch}
sed -i "s|__QEMU_ARCH__|${qemu_arch}|g" Dockerfile.${docker_arch}
sed -i "s|__CURL_VER__|${ver}|g" Dockerfile.${docker_arch}
sed -i "s|__BUILD_DATE__|${build_date}|g" Dockerfile.${docker_arch}
if [ ${docker_arch} == 'amd64' ]; then
    sed -i "/__CROSS__/d" Dockerfile.${docker_arch}
    cp Dockerfile.${docker_arch} Dockerfile
else
    sed -i "s/__CROSS__//g" Dockerfile.${docker_arch}
fi


# Check for qemu static bins
if [[ ! -f qemu-${qemu_arch}-static ]]; then
    echo "Downloading the qemu static binaries for ${docker_arch}"
    wget -q -N https://github.com/multiarch/qemu-user-static/releases/download/v4.0.0-4/x86_64_qemu-${qemu_arch}-static.tar.gz
    tar -xvf x86_64_qemu-${qemu_arch}-static.tar.gz
    rm x86_64_qemu-${qemu_arch}-static.tar.gz
fi

# Build
if [ "$EUID" -ne 0 ]; then
    sudo docker build -f Dockerfile.${docker_arch} -t ${repo}:${docker_arch}-${ver} .
else
    docker build -f Dockerfile.${docker_arch} -t ${repo}:${docker_arch}-${ver} .
fi