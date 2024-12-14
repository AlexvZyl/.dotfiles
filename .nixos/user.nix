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
      pkgs.gnome.adwaita-icon-theme
      pkgs.xfce.thunar
      pkgs.xournalpp
      pkgs.shared-mime-info
      pkgs.slack
      pkgs.discord
      pkgs.wireshark
      pkgs.zulu8
      pkgs.loc
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
      pkgs.gh
      pkgs.arandr
      pkgs.rustdesk
      pkgs.gnome.nautilus
      pkgs.starship
      pkgs.tree-sitter
      pkgs.wezterm
      pkgs.chromium
      pkgs.dua
      (pkgs.python311.withPackages(ps: with ps; [pytz numpy pandas matplotlib seaborn scipy])) # TODO: Fix the fricken python issues
      pkgs.signal-desktop
      pkgs.gimp
      pkgs.thunderbird-bin
      pkgs.birdtray
      pkgs.dig
      pkgs.sshs
      pkgs.termshark
      pkgs.ventoy-bin-full
      pkgs.tshark
      pkgs.vscode
      pkgs.godot_4
      pkgs.android-tools
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "alex" ];
      commands = [
        { command = "/run/current-system/sw/bin/fail2ban-client"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  system.activationScripts.binbash = {
    deps = [ "binsh" ];
    text = ''
        if [ ! -f "/bin/bash" ]; then
            ln -s "/bin/sh" "/bin/bash"
        fi
    '';
  };

  virtualisation.docker.enable = true;

  programs.fish.enable = true;
}
