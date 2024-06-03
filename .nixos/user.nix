{ pkgs, ... }:

{
  # Xournal fix.
  environment.pathsToLink = [
    "/share/icons"
    "/share/mime"
  ];

  users.users.alex = {
    isNormalUser = true;
    description = "Alexander van Zyl";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      gnome.adwaita-icon-theme
      xfce.thunar
      terraform
      terraform-providers.aws
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
}
