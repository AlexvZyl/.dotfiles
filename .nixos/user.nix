{ pkgs, ... }:

{
  users.groups.alex = {};
  users.users.alex = {
    shell = pkgs.fish;
    description = "Alexander van Zyl";
    group = "alex";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      gnome.adwaita-icon-theme
      xfce.thunar
      xournalpp
      shared-mime-info
      slack
      discord
      wireshark
      zulu8
      loc
      flameshot
      onlyoffice-bin
      newsboat
      vlc
      kalker
      obs-studio
      rofi
      gource
      rofi-pass
      thunderbird
      inkscape
      pavucontrol
      gparted
      pinta
      speedtest-cli
      pfetch
      scrcpy
      lazygit
      lazydocker
      zoxide
      zathura
      ranger
      glab
      awscli2
      feh
      gh
      arandr
      rustdesk
      gnome.nautilus
      starship
      cava
      tree-sitter
      wezterm
      chromium
      dua
      (python311.withPackages(ps: with ps; [pytz]))
      signal-desktop
      gimp
      thunderbird-bin
      birdtray
      dig
      sshs
      termshark
      ventoy-bin-full
      tshark
      vscode
      godot_4
      android-tools
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
