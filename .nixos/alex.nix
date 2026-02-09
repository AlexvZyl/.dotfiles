{ pkgs, ... }:
let
  kotlin-lsp = pkgs.stdenv.mkDerivation rec {
    pname = "kotlin-lsp";
    version = "261.13587.0";

    src = pkgs.fetchzip {
      url = "https://download-cdn.jetbrains.com/kotlin-lsp/${version}/kotlin-lsp-${version}-linux-x64.zip";
      hash = "sha256-EweSqy30NJuxvlJup78O+e+JOkzvUdb6DshqAy1j9jE=";
      stripRoot=false;
    };

    nativeBuildInputs = [ pkgs.makeWrapper pkgs.autoPatchelfHook ];
    buildInputs = [
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib
      pkgs.xorg.libX11
      pkgs.xorg.libXext
      pkgs.xorg.libXrender
      pkgs.xorg.libXtst
      pkgs.xorg.libXi
      pkgs.freetype
      pkgs.alsa-lib
      pkgs.wayland
    ];

    installPhase = ''
      mkdir -p $out
      cp -r * $out/
      chmod +x $out/kotlin-lsp.sh

      # Make JRE binaries executable during build
      find $out/jre/bin -type f -exec chmod +x {} \;

      # Remove the problematic chmod line from the script
      # NOTE: If something break, look here.
      sed -i '/chmod +x.*java/d' $out/kotlin-lsp.sh

      makeWrapper $out/kotlin-lsp.sh $out/bin/kotlin-lsp
    '';
  };
in
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
      pkgs.thunar
      pkgs.xournalpp
      pkgs.shared-mime-info
      pkgs.nautilus
      pkgs.papirus-icon-theme
      pkgs.rofi
      pkgs.unclutter-xfixes
      pkgs.onlyoffice-desktopeditors
      pkgs.drawio
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
      pkgs.rustdesk
      pkgs.vscode-fhs
      pkgs.ventoy-full

      # Communication
      pkgs.slack
      pkgs.discord
      pkgs.signal-desktop-bin
      pkgs.thunderbird-bin

      # Terminal tools
      pkgs.kalker
      pkgs.speedtest-cli
      pkgs.zoxide
      pkgs.starship
      pkgs.newsboat
      pkgs.yazi
      pkgs.lazygit
      pkgs.lazydocker
      pkgs.vscodium-fhs
      pkgs.glab
      pkgs.wezterm
      pkgs.gh
      pkgs.tealdeer
      pkgs.tokei
      pkgs.awscli2
      pkgs.dua
      pkgs.dig
      pkgs.sshs
      pkgs.termshark
      pkgs.opencode
      pkgs.lynx
      pkgs.traceroute
      pkgs.netscanner
      pkgs.impala

      # TSN
      pkgs.wireshark
      pkgs.tshark

      # Game dev
      pkgs.blender
      pkgs.godot
      pkgs.renderdoc

      # Dev environment
      pkgs.jetbrains.idea-oss
      pkgs.docker-language-server
      pkgs.git-filter-repo
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
      pkgs.terraform-providers.hashicorp_aws
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
      kotlin-lsp
      pkgs.w3m
      pkgs.rustc
      pkgs.rustfmt
      pkgs.cargo
      pkgs.tokio-console
      pkgs.cargo-flamegraph
      pkgs.tree-sitter (pkgs.python3.withPackages(ps: with ps; [pytz numpy pandas]))
      pkgs.clang-tools
      pkgs.kotlin
      pkgs.gradle
      pkgs.ktlint
      pkgs.openjdk21

      # Gaming.
      pkgs.lutris
      pkgs.mangohud
      pkgs.protonup-ng
      pkgs.heroic
      pkgs.bottles
    ];
  };

  # Don't have time for this now.
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.10"
  ];

  # TSN.
  services.avahi = {
    enable = true;
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
  programs.noisetorch.enable = true;

  # Gaming stuff.
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "\${HOME}/.steam/root/compatibilitytools.d";
  };
}

