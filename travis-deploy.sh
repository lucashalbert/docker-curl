#!/bin/bash

# Push image to Docker Hub
docker push ${repo}:${docker_arch}-${ver}

# Create arch/ver docker manifest
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest create ${repo}:${docker_arch}-${ver} ${repo}:${docker_arch}-${ver}

# Annotate arch/ver docker manifest
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest annotate ${repo}:${docker_arch}-${ver} ${repo}:${docker_arch}-${ver} --os linux --arch ${image_arch}

# Push version and architecture docker manifest
DOCKER_CLI_EXPERIMENTAL=enabled docker manifest push ${repo}:${docker_arch}-${ver}