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
    vscode-extensions.ms-vscode.cpptools
    luajitPackages.luacheck
    nodePackages.bash-language-server
    nodePackages.vscode-html-languageserver-bin
    nodePackages.typescript-language-server
    nodePackages_latest.vscode-json-languageserver-bin
    docker-ls
    dockerfile-language-server-nodejs
    clang-tools
    cmake-language-server
    terraform
    terraform-providers.aws
    cmake
    vscode-langservers-extracted
    nodePackages.eslint
    cppcheck
    ninja
    rocmPackages.llvm.clang
    ccls
  ];
}

