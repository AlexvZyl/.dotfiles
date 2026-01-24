#!/usr/bin/env -S bash -e


Main() {
    local dockerfile="$1"

    # Validate arguments
    if [[ -z "$dockerfile" ]]; then
        echo "Usage: $0 <dockerfile>"
        exit 1
    fi

    if [[ ! -f "$dockerfile" ]]; then
        echo "Error: $dockerfile not found"
        exit 1
    fi

    # Create distro directory for persistent storage
    local tmp
    tmp="$(basename "$dockerfile")"
    local distro="${tmp#Dockerfile.}"
    mkdir -p "$distro"

    # Build and run container
    local tag="nixos_host_${distro}_container"
    docker build -t "$tag" -f "$dockerfile" .
    docker run -v "$(pwd)/$distro:/root" -it "$tag"
}


Main "$@"
