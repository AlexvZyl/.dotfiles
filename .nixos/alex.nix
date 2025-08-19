{ pkgs, inputs, ... }:

{
  users.groups.alex = {};
  users.users.alex = {
    shell = pkgs.fish;
    description = "Alexander van Zyl";
    group = "alex";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = [
      pkgs.adwaita-icon-theme
      pkgs.xfce.thunar
      pkgs.xournalpp
      pkgs.shared-mime-info
      pkgs.slack
      pkgs.discord
      pkgs.wireshark
      pkgs.zulu8
      pkgs.tokei
      pkgs.flameshot
      pkgs.onlyoffice-bin
      pkgs.newsboat
      pkgs.vlc
      pkgs.kalker
      pkgs.obs-studio
      pkgs.rofi
      pkgs.gource
      pkgs.rofi-pass
      pkgs.thunderbird
      pkgs.inkscape
      pkgs.pavucontrol
      pkgs.gparted
      pkgs.pinta
      pkgs.speedtest-cli
      pkgs.pfetch
      pkgs.scrcpy
      inputs.yazi.packages.${pkgs.system}.default
      pkgs.lazygit
      pkgs.lazydocker
      pkgs.zoxide
      pkgs.zathura
      pkgs.glab
      pkgs.awscli2
      pkgs.feh
      pkgs.lapce
      pkgs.gh
      pkgs.arandr
      pkgs.papirus-icon-theme
      # pkgs.rustdesk # Always breaking...
      pkgs.nautilus
      pkgs.starship
      pkgs.tree-sitter
      pkgs.wezterm
      pkgs.chromium
      pkgs.dua
      (pkgs.python3.withPackages(ps: with ps; [pytz numpy pandas]))
      pkgs.signal-desktop
      pkgs.gimp3
      pkgs.thunderbird-bin
      pkgs.dig
      pkgs.sshs
      pkgs.termshark
      # pkgs.ventoy-bin-full
      pkgs.tshark
      pkgs.vscode
      pkgs.drawio
      pkgs.brave
      pkgs.blender
      pkgs.godot
      pkgs.renderdoc
      pkgs.zed-editor-fhs

      # Devving
      pkgs.pyright
      pkgs.stylua
      pkgs.shellcheck
      pkgs.terraform-ls
      pkgs.gopls
      pkgs.nixd
      pkgs.yaml-language-server
      pkgs.pylint
      pkgs.python3Packages.flake8
      pkgs.luajitPackages.luacheck
      pkgs.nodePackages.bash-language-server
      pkgs.nodePackages.typescript-language-server
      pkgs.docker-ls
      pkgs.dockerfile-language-server-nodejs
      pkgs.clang-tools
      pkgs.cmake-language-server
      pkgs.terraform
      pkgs.terraform-providers.aws
      pkgs.cmake
      pkgs.vscode-langservers-extracted
      pkgs.nodePackages.eslint
      pkgs.cppcheck
      pkgs.ninja
      pkgs.rocmPackages.llvm.clang
      pkgs.ccls
      pkgs.buf
      pkgs.black
      pkgs.protobuf_29
      pkgs.nodejs
      pkgs.grpcurl
      pkgs.subversionClient
      pkgs.nodePackages_latest.vscode-json-languageserver
      pkgs.zig
      pkgs.zls
      pkgs.docker-compose
      pkgs.lua-language-server
      pkgs.difftastic
      pkgs.docker-compose-language-service
      pkgs.rust-analyzer
      pkgs.rustc
      pkgs.rustfmt
      pkgs.cargo
      pkgs.tokio-console
      pkgs.cargo-flamegraph
      pkgs.claude-code
      pkgs.unclutter-xfixes
    ];
  };

  system.activationScripts.binbash = {
    deps = [ "binsh" ];
    text = ''
        if [ ! -f "/bin/bash" ]; then
            ln -s "/bin/sh" "/bin/bash"
        fi
    '';
  };

  system.activationScripts.python3 = {
    text = ''
        if [ ! -f "/usr/bin/python3" ]; then
            ln -s ${pkgs.python3}/bin/python3 /usr/bin/python3
        fi
    '';
  };

  virtualisation.docker.enable = true;
  programs.fish.enable = true;
}
