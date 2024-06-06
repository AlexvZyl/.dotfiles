{ pkgs, ... }:

{
  # Xournal fix.
  environment.pathsToLink = [
    "/share/icons"
    "/share/mime"
  ];

  users.groups.alex = {};
  users.users.alex = {
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
      zulu8
      loc
      librewolf
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
      lazygit
      audacity
      zoxide
      zathura
      ranger
      glab
      dunst
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
      vscodium
      signal-desktop
      sniffnet

      ventoy-full
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "alex" ];
      commands = [
        { command = "/usr/bin/s-tui"; options = [ "NOPASSWD" ]; }
        { command = "/usr/bin/fail2ban-client"; options = [ "NOPASSWD" ]; }
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
}
