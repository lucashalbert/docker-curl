#!/bin/bash
build_date=${build_date:-$(date +"%Y%m%dT%H%M%S")}

for docker_arch in amd64 arm32v6 arm64v8; do
    case ${docker_arch} in
        amd64   ) qemu_arch="x86_64" ;;
        arm32v6 ) qemu_arch="arm" ;;
        arm64v8 ) qemu_arch="aarch64" ;;    
    esac
    cp Dockerfile.cross Dockerfile.${docker_arch}
    sed -i "s|__BASEIMAGE_ARCH__|${docker_arch}|g" Dockerfile.${docker_arch}
    sed -i "s|__QEMU_ARCH__|${qemu_arch}|g" Dockerfile.${docker_arch}
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
        sudo docker build -f Dockerfile.${docker_arch} -t lucashalbert/docker-curl:${docker_arch} .
        #sudo docker push lucashalbert/docker-curl:${docker_arch}
    else
        docker build -f Dockerfile.${docker_arch} -t lucashalbert/docker-curl:${docker_arch} .
        #docker push lucashalbert/docker-curl:${docker_arch}
    fi
done
