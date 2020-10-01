#!/bin/bash
docker_archs=(amd64 i386 arm32v6 arm32v7 arm64v8 ppc64le s390x)

for docker_arch in amd64 arm32v6 arm64v8; do
    # Push each of the images to Docker Hub
    docker push ${repo}:${docker_arch}-${ver}

    # Create and annotate arch/ver docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ${repo}:${docker_arch}-${ver} ${repo}:${docker_arch}-${ver}

    # Annotate arch/ver docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:${docker_arch}-${ver} ${repo}:${docker_arch}-${ver} --os linux --arch ${image_arch}

    # Push version and architecture docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:${docker_arch}-${ver}

    # Generate Dynamic Manifest Image List
    manifest_images="${manifest_images} ${repo}:${docker_arch}-${ver}"

done

# Create version specific docker manifest
#DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create lucashalbert/curl:${curl_ver} lucashalbert/curl:amd64-${curl_ver} lucashalbert/curl:arm32v6-${curl_ver} lucashalbert/curl:arm64v8-${curl_ver}
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ${repo}:${ver} ${manifest_images}

# Create latest docker manifest
#DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create lucashalbert/curl:latest lucashalbert/curl:amd64-${curl_ver} lucashalbert/curl:arm32v6-${curl_ver} lucashalbert/curl:arm64v8-${curl_ver}
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ${repo}:latest ${manifest_images}




for docker_arch in ${docker_archs[@]}; do
    case ${docker_arch} in
        i386 )    image_arch="i386"    ;;
        amd64   ) image_arch="amd64"   ;;
        arm32v6 ) image_arch="arm32v6" ;;
        arm32v7 ) image_arch="arm32v7" ;;
        arm64v8 ) image_arch="arm64"   ;;
        ppc64le ) image_arch="ppc64le" ;;
        s390x )   image_arch="s390x"   ;;   
    esac

    # Annotate version specific docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:${ver} ${repo}:${docker_arch}-${ver} --os linux --arch ${image_arch}

    # Annotate latest docker manifest
    DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:latest ${repo}:${docker_arch}-${curl_ver} --os linux --arch ${image_arch}

	# Push version specific docker manifest
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:${curl_ver}

	# Push latest docker manifest
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:latest
done