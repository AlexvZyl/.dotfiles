#!/bin/bash -e


FILE_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
TAG="nixos_host_ubuntu_container"


Main() {
    local cmd="$1" args="$2"

    docker build -t "${TAG}" "${FILE_DIR}"
    if [[ -z "$args" ]]; then
        #shellcheck disable=2068
        docker run "${TAG}" ${cmd[@]}
    else
        #shellcheck disable=2068
        docker run ${args[@]} "${TAG}" ${cmd[@]}
    fi
}


Main "$@"
