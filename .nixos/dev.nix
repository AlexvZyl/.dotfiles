{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rust-analyzer
    lua-language-server
    pyright
    stylua
    shellcheck
    terraform-ls
    gopls
    nixd
    yaml-language-server
    pylint
    python311Packages.flake8
    luajitPackages.luacheck
    nodePackages.bash-language-server
    nodePackages.typescript-language-server
    docker-ls
    dockerfile-language-server-nodejs
    clang-tools
    cmake-language-server
    terraform
    terraform-providers.aws
    cmake
    vscode-langservers-extracted
    nodePackages.vscode-json-languageserver-bin
    nodePackages.eslint
    cppcheck
    ninja
    rocmPackages.llvm.clang
    ccls
    black
  ];
}

