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

    # Push each of the images to Docker Hub
	docker push ${repo}:${docker_arch}-${curl_ver}

	# Push version and architecture docker manifest
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:${docker_arch}-${curl_ver}

	# Push version specific docker manifest
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:${curl_ver}

	# Push latest docker manifest
	DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:latest
done