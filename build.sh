#!/bin/bash

set -x

for docker_arch in ${docker_archs}; do
    case ${docker_arch} in
        i386    ) qemu_arch="i386"    image_arch="386"     unset variant ;;
        amd64   ) qemu_arch="x86_64"  image_arch="amd64"   unset variant ;;
        arm32v6 ) qemu_arch="arm"     image_arch="arm"     variant="v6"  ;;
        arm32v7 ) qemu_arch="arm"     image_arch="arm"     variant="v7"  ;;
        arm64v8 ) qemu_arch="aarch64" image_arch="arm64"   variant="v8"  ;;
        ppc64le ) qemu_arch="ppc64le" image_arch="ppc64le" unset variant ;;
        s390x   ) qemu_arch="s390x"   image_arch="s390x"   unset variant ;;
    esac
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

    # Build image
    docker build -f Dockerfile.${docker_arch} -t ${repo}:${docker_arch}-${ver} .
   
    # Check if build should be deployed
    if [ "$TRAVIS_BRANCH" = "master" ] && [ "$DEPLOY" = true ]; then  
        # Create arch/ver docker manifest
        DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ${repo}:${docker_arch}-${ver} ${repo}:${docker_arch}-${ver}
        
        # Annotate arch/ver docker manifest
        if [ ! -z "${variant}" ]; then
            DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:${docker_arch}-${ver} ${repo}:${docker_arch}-${ver} --os linux --arch ${image_arch} --variant ${variant}
        else
            DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:${docker_arch}-${ver} ${repo}:${docker_arch}-${ver} --os linux --arch ${image_arch}
        fi

        # Push image
        docker push ${repo}:${docker_arch}-${ver}

        # Push arch/ver docker manifest
        DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:${docker_arch}-${ver}

        # Generate Dynamic Manifest Image List
        if [ -z "${manifest_images}" ]; then
            manifest_images="${repo}:${docker_arch}-${ver}"
        else
            manifest_images="${manifest_images} ${repo}:${docker_arch}-${ver}"
        fi
    elif [ ! "$TRAVIS_BRANCH" = "master" ] && [ "$DEPLOY" = true ]; then
        # Tag image with travis branch
        docker tag ${repo}:${docker_arch}-${ver} ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH}

        # Push tagged image
        docker push ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH}

        # Create tagged arch/ver docker manifest
        DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH} ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH}
        
        # Annotate tagged arch/ver docker manifest
        if [ ! -z "${variant}" ]; then
            DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH} ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH} --os linux --arch ${image_arch} --variant ${variant}
        else
            DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH} ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH} --os linux --arch ${image_arch}
        fi

        # Push tagged arch/ver docker manifest
        DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH}

        # Generate Dynamic Manifest Image List
        if [ -z "${manifest_images}" ]; then
            manifest_images="${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH}"
        else
            manifest_images="${manifest_images} ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH}"
        fi
    else
        echo "Skipping image deployment... Not configured to deploy images/manifests to DockerHub"
    fi
done

echo "Manifest Images: $manifest_images"

# Check if build should be deployed
if [ "$TRAVIS_BRANCH" = "master" ] && [ "$DEPLOY" = true ]; then 
    # Create version specific docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ${repo}:${ver} ${manifest_images}

    # Create latest version docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ${repo}:latest ${manifest_images}
elif [ ! "$TRAVIS_BRANCH" = "master" ] && [ "$DEPLOY" = true ]; then
    # Create version specific docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ${repo}:${ver}-${TRAVIS_BRANCH} ${manifest_images}

    # Create latest version docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ${repo}:latest-${TRAVIS_BRANCH} ${manifest_images}
else
    echo "Skipping version specific and latest tag docker manifest creation... Not configured to deploy images/manifests to DockerHub"
fi

for docker_arch in ${docker_archs}; do
    case ${docker_arch} in
        i386    ) qemu_arch="i386"    image_arch="386"     unset variant ;;
        amd64   ) qemu_arch="x86_64"  image_arch="amd64"   unset variant ;;
        arm32v6 ) qemu_arch="arm"     image_arch="arm"     variant="v6"  ;;
        arm32v7 ) qemu_arch="arm"     image_arch="arm"     variant="v7"  ;;
        arm64v8 ) qemu_arch="aarch64" image_arch="arm64"   variant="v8"  ;;
        ppc64le ) qemu_arch="ppc64le" image_arch="ppc64le" unset variant ;;
        s390x   ) qemu_arch="s390x"   image_arch="s390x"   unset variant ;;
    esac

    # Check if build should be deployed
    if [ "$TRAVIS_BRANCH" = "master" ] && [ "$DEPLOY" = true ]; then 
        # Annotate arch/ver docker manifest
        if [ ! -z "${variant}" ]; then
            # Annotate version specific docker manifest
            DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:${ver} ${repo}:${docker_arch}-${ver} --os linux --arch ${image_arch} --variant ${variant}

            # Annotate latest docker manifest
            DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:latest ${repo}:${docker_arch}-${ver} --os linux --arch ${image_arch} --variant ${variant}

        else
            # Annotate version specific docker manifest
            DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:${ver} ${repo}:${docker_arch}-${ver} --os linux --arch ${image_arch}

            # Annotate latest docker manifest
            DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:latest ${repo}:${docker_arch}-${ver} --os linux --arch ${image_arch}
        fi
    elif [ ! "$TRAVIS_BRANCH" = "master" ] && [ "$DEPLOY" = true ]; then
        # Annotate arch/ver docker manifest
        if [ ! -z "${variant}" ]; then
            # Annotate version specific docker manifest
            DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:${ver}-${TRAVIS_BRANCH} ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH} --os linux --arch ${image_arch} --variant ${variant}

            # Annotate latest docker manifest
            DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:latest-${TRAVIS_BRANCH} ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH} --os linux --arch ${image_arch} --variant ${variant}

        else
            # Annotate version specific docker manifest
            DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:${ver}-${TRAVIS_BRANCH} ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH} --os linux --arch ${image_arch}

            # Annotate latest docker manifest
            DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:latest-${TRAVIS_BRANCH} ${repo}:${docker_arch}-${ver}-${TRAVIS_BRANCH} --os linux --arch ${image_arch}
        fi
    else
        echo "Skipping version specific and latest tag docker manifest annotation... Not configured to deploy images/manifests to DockerHub"
    fi
done

# Check if build should be deployed
if [ "$TRAVIS_BRANCH" = "master" ] && [ "$DEPLOY" = true ]; then
    # Push version specific docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:${ver}

    # Push latest docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:latest
elif [ ! "$TRAVIS_BRANCH" = "master" ] && [ "$DEPLOY" = true ]; then
    # Push version specific docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:${ver}-${TRAVIS_BRANCH}

    # Push latest docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:latest-${TRAVIS_BRANCH}
else
    echo "Skipping version specific and latest tag docker manifest push... Not configured to deploy images/manifests to DockerHub"
fi