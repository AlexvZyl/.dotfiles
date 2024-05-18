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
    docker-ls
    nixd
    yaml-language-server
    pylint
    python311Packages.flake8
    vscode-extensions.ms-vscode.cpptools
    luajitPackages.luacheck
    nodePackages.bash-language-server
    nodePackages.vscode-html-languageserver-bin
    nodePackages.typescript-language-server
  ];
}

