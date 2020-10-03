#!/bin/bash
# Exit on any failure
set -e

SECONDS=0

# Get start time
START_TIME=$(date +"%Y%m%dT%H%M%S")
echo "Start Time: ${START_TIME}"
export build_date=${START_TIME}

# Check if running in Travis-CI
if [ -z "$TRAVIS_BRANCH" ]; then 
    echo "Error: this script is meant to run in Travis-CI only"
    exit 1
fi

# Check if GitHub token set
if [[ -z "$DH_USERNAME" || -z "$DH_PASSWORD" ]]; then
    echo "Error: DOCKERHUB environment variables not set"
    exit 2
fi

# Login to dockerhub
echo "${DH_PASSWORD}" | docker login --username $DH_USERNAME --password-stdin

# Run the build
./build.sh

# Get start time
END_TIME=$(date +"%Y%m%dT%H%M")

# Display build time statistics
echo "Build Start Time: ${START_TIME}"
echo "Build End Time: ${END_TIME}"
echo "Build Duration: $(($SECONDS / 60)) minutes $((${SECONDS} % 60)) seconds"

