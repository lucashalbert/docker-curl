#!/bin/bash
curl_ver=${curl_ver:-$(curl -s "https://pkgs.alpinelinux.org/package/edge/main/x86_64/curl" | grep -A3 Version | grep href | sed 's/<[^>]*>//g' | tr -d " ")}
build_date=${build_date:-$(date +"%Y%m%dT%H%M%S")}

for docker_arch in amd64 arm32v6 arm64v8; do
    case ${docker_arch} in
        amd64   ) qemu_arch="x86_64"  image_arch="amd64" ;;
        arm32v6 ) qemu_arch="arm"     image_arch="arm"   ;;
        arm64v8 ) qemu_arch="aarch64" image_arch="arm64" ;;    
    esac
    cp Dockerfile.cross Dockerfile.${docker_arch}
    sed -i "s|__BASEIMAGE_ARCH__|${docker_arch}|g" Dockerfile.${docker_arch}
    sed -i "s|__QEMU_ARCH__|${qemu_arch}|g" Dockerfile.${docker_arch}
    sed -i "s|__CURL_VER__|${curl_ver}|g" Dockerfile.${docker_arch}
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
        sudo docker build -f Dockerfile.${docker_arch} -t lucashalbert/curl:${docker_arch}-${curl_ver} .
        sudo docker push lucashalbert/curl:${docker_arch}-${curl_ver}
    else
        docker build -f Dockerfile.${docker_arch} -t lucashalbert/curl:${docker_arch}-${curl_ver} .
        docker push lucashalbert/curl:${docker_arch}-${curl_ver}

        # Create and annotate arch/ver docker manifest
        DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create lucashalbert/curl:${docker_arch}-${curl_ver} lucashalbert/curl:${docker_arch}-${curl_ver}
        DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate lucashalbert/curl:${docker_arch}-${curl_ver} lucashalbert/curl:${docker_arch}-${curl_ver} --os linux --arch ${image_arch}
        DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push lucashalbert/curl:${docker_arch}-${curl_ver}

    fi
done



# Create version specific docker manifest
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create lucashalbert/curl:${curl_ver} lucashalbert/curl:amd64-${curl_ver} lucashalbert/curl:arm32v6-${curl_ver} lucashalbert/curl:arm64v8-${curl_ver}

# Create latest docker manifest
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create lucashalbert/curl:latest lucashalbert/curl:amd64-${curl_ver} lucashalbert/curl:arm32v6-${curl_ver} lucashalbert/curl:arm64v8-${curl_ver}

for docker_arch in amd64 arm32v6 arm64v8; do
    case ${docker_arch} in
        amd64   ) image_arch="amd64" ;;
        arm32v6 ) image_arch="arm"   ;;
        arm64v8 ) image_arch="arm64" ;;    
    esac

    # Annotate version specific docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate lucashalbert/curl:${curl_ver} lucashalbert/curl:${docker_arch}-${curl_ver} --os linux --arch ${image_arch}

    # Annotate latest docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate lucashalbert/curl:latest lucashalbert/curl:${docker_arch}-${curl_ver} --os linux --arch ${image_arch}
done

# Push version specific docker manifest
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push lucashalbert/curl:${curl_ver}

# Push latest docker manifest
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push lucashalbert/curl:latest
