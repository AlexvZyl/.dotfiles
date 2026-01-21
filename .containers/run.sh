#!/bin/bash -e

Main() {
    local dockerfile="$1"

    # Validate arguments
    if [[ -z "$dockerfile" ]]; then
        echo "Usage: $0 <dockerfile> [args...]"
        exit 1
    fi

    if [[ ! -f "$dockerfile" ]]; then
        echo "Error: $dockerfile not found"
        exit 1
    fi

    shift

    # Extract distro name from dockerfile (e.g., Dockerfile.debian -> debian)
    local tmp
    tmp="$(basename "$dockerfile")"
    local distro="${tmp#Dockerfile.}"
    # Create distro directory for persistent storage
    mkdir -p "$distro"

    # Parse arguments: split on '--' separator
    local docker_args=()
    local cmd_args=()
    local found_separator=false

    for arg in "$@"; do
        if [[ "$arg" == "--" ]]; then
            found_separator=true
            continue
        fi

        if [[ "$found_separator" == true ]]; then
            cmd_args+=("$arg")
        else
            docker_args+=("$arg")
        fi
    done

    # Build and run container
    local tag="nixos_host_${distro}_container"
    docker build -t "$tag" -f "$dockerfile" .

    #shellcheck disable=2068,2086
    docker run -v "$(pwd)/$distro:/app" ${docker_args[@]} "$tag" ${cmd_args[@]}
}

Main "$@"
