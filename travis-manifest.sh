#!/bin/bash

set -x

for docker_arch in ${docker_archs}; do
    case ${docker_arch} in
        i386 )    image_arch="386"     ;;
        amd64   ) image_arch="amd64"   ;;
        arm32v6 ) image_arch="arm32v6" ;;
        arm32v8 ) image_arch="arm32v8" ;;
        arm32v7 ) image_arch="arm32v7" ;;
        arm64v8 ) image_arch="arm64"   ;;
        ppc64le ) image_arch="ppc64le" ;;
        s390x )   image_arch="s390x"   ;;   
    esac

    docker pull ${repo}:${docker_arch}-${ver}

    # Generate Dynamic Manifest Image List
    manifest_images="${manifest_images} ${repo}:${docker_arch}-${ver}"
done


# Create version specific docker manifest
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ${repo}:${ver} ${manifest_images}

# Create latest docker manifest
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ${repo}:latest ${manifest_images}

for docker_arch in ${docker_archs}; do
    case ${docker_arch} in
        i386 )    image_arch="386"     ;;
        amd64   ) image_arch="amd64"   ;;
        arm32v6 ) image_arch="arm32v6" varient="v6";;
        arm32v7 ) image_arch="arm32v7" varient="v7";;
        arm32v8 ) image_arch="arm32v8" varient="v8";;
        arm64v8 ) image_arch="arm64"   varient="v8";;
        ppc64le ) image_arch="ppc64le" ;;
        s390x )   image_arch="s390x"   ;;   
    esac


# Annotate arch/ver docker manifest
    if [ ! -Z ${varient} ]; then
        # Annotate version specific docker manifest
        DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:${ver} ${repo}:${docker_arch}-${ver} --os linux --arch ${image_arch} --varient ${varient}

        # Annotate latest docker manifest
        DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:latest ${repo}:${docker_arch}-${ver} --os linux --arch ${image_arch} --varient ${varient}

    else
        # Annotate version specific docker manifest
        DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:${ver} ${repo}:${docker_arch}-${ver} --os linux --arch ${image_arch}

        # Annotate latest docker manifest
        DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:latest ${repo}:${docker_arch}-${ver} --os linux --arch ${image_arch}
    fi
done

# Push version specific docker manifest
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:${ver}

# Push latest docker manifest
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:latest