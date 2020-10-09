#!/bin/bash
ver=${ver:-$(curl -s "https://pkgs.alpinelinux.org/package/edge/main/x86_64/curl" | grep -A3 Version | grep href | sed 's/<[^>]*>//g' | tr -d " ")}
build_date=${build_date:-$(date -u +"%Y-%m-%dT%H:%M:%SZ")}
vcs_ref=${vcs_ref:-$(git rev-parse --short HEAD)}

for docker_arch in ${docker_archs}; do
    case ${docker_arch} in
        i386    ) qemu_arch="i386"    image_arch="386"     variant=""   ;;
        amd64   ) qemu_arch="x86_64"  image_arch="amd64"   variant=""   ;;
        arm32v6 ) qemu_arch="arm"     image_arch="arm"     variant="v6" ;;
        arm32v7 ) qemu_arch="arm"     image_arch="arm"     variant="v7" ;;
        arm64v8 ) qemu_arch="aarch64" image_arch="arm64"   variant="v8" ;;
        ppc64le ) qemu_arch="ppc64le" image_arch="ppc64le" variant=""   ;;
        s390x   ) qemu_arch="s390x"   image_arch="s390x"   variant=""   ;;
    esac
    cp Dockerfile.cross Dockerfile.${docker_arch}
    sed -i "s|__BASEIMAGE_ARCH__|${docker_arch}|g" Dockerfile.${docker_arch}
    sed -i "s|__QEMU_ARCH__|${qemu_arch}|g" Dockerfile.${docker_arch}
    sed -i "s|__CURL_VER__|${ver}|g" Dockerfile.${docker_arch}
    sed -i "s|__BUILD_DATE__|${build_date}|g" Dockerfile.${docker_arch}
    sed -i "s|__VCS_REF__|${vcs_ref}|g" Dockerfile.${docker_arch}
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
        sudo docker build -f Dockerfile.${docker_arch} -t lucashalbert/curl:${docker_arch}-${ver} .
        #sudo docker push lucashalbert/docker-curl:${docker_arch}
    else
        docker build -f Dockerfile.${docker_arch} -t lucashalbert/curl:${docker_arch}-${ver} .
        #docker push lucashalbert/docker-curl:${docker_arch}
    fi
done
