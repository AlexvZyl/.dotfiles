#!/bin/bash -e


Add_package_to_lib() {
    local package="$1"

    local location
    location="$(nix eval --raw nixpkgs#"${package}")/lib"

    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${location}"
}


Main() {
    Add_package_to_lib "stdenv.cc.cc.lib"
    Add_package_to_lib "zlib"

    "$(which nix-shell)" \
        -p python3 python3Packages.virtualenv zlib \
        --command '
            virtualenv venv;
            source venv/bin/activate;
            pip install --upgrade pip;
            fish;'
}


Main "$@"
