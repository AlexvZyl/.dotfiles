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
      # GUI
      pkgs.adwaita-icon-theme
      pkgs.xfce.thunar
      pkgs.xournalpp
      pkgs.shared-mime-info
      pkgs.nautilus
      pkgs.papirus-icon-theme
      pkgs.rofi
      pkgs.unclutter-xfixes
      pkgs.onlyoffice-bin
      pkgs.drawio
      pkgs.brave
      pkgs.inkscape
      pkgs.pavucontrol
      pkgs.gparted
      pkgs.pinta
      pkgs.rofi-pass
      pkgs.pfetch
      pkgs.flameshot
      pkgs.scrcpy
      pkgs.obs-studio
      pkgs.vlc
      pkgs.zathura
      pkgs.feh
      pkgs.arandr
      pkgs.chromium
      pkgs.gimp3
      # pkgs.rustdesk # Always breaking...
      # pkgs.ventoy-bin-full

      # Communication
      pkgs.slack
      pkgs.discord
      pkgs.signal-desktop
      pkgs.thunderbird-bin
      
      # Terminal tools
      pkgs.kalker
      pkgs.speedtest-cli
      pkgs.zoxide
      pkgs.starship
      pkgs.newsboat
      inputs.yazi.packages.${pkgs.system}.default
      pkgs.lazygit
      pkgs.lazydocker
      pkgs.vscode
      pkgs.glab
      pkgs.wezterm
      pkgs.codex
      pkgs.gh
      pkgs.tealdeer
      pkgs.tokei
      pkgs.awscli2
      pkgs.dua
      pkgs.dig
      pkgs.sshs
      pkgs.termshark

      # TSN
      pkgs.wireshark
      pkgs.tshark

      # Game dev
      pkgs.blender
      pkgs.godot
      pkgs.renderdoc

      # Dev environment
      pkgs.zulu8
      pkgs.delta
      pkgs.go
      pkgs.gdb
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
      pkgs.dockerfile-language-server
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
      pkgs.tree-sitter (pkgs.python3.withPackages(ps: with ps; [pytz numpy pandas]))
    ];
  };

  system.activationScripts.binbash = {
    deps = [ "binsh" ];
    text = ''
        if [[ ! -f "/bin/bash" ]]; then
            ln -s "/bin/sh" "/bin/bash"
        fi
    '';
  };

  system.activationScripts.python3 = {
    text = ''
        if [[ ! -f "/usr/bin/python3" ]]; then
            ln -s ${pkgs.python3}/bin/python3 /usr/bin/python3
        fi
    '';
  };

  virtualisation.docker.enable = true;
  programs.fish.enable = true;
}
