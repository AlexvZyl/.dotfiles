{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rust-analyzer
    python311Packages.flake8
    lua-language-server
    pyright
    stylua
    luajitPackages.luacheck
    pylint
    shellcheck
    vscode-extensions.ms-vscode.cpptools
    terraform-ls
    gopls
    docker-ls
    nixd
    nodePackages_latest.bash-language-server
  ];
}

