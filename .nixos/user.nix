{ pkgs, ... }:

{
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  #programs.steam.gamescopeSession.enable = true;

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "$HOME/.steam/root/compatibilitytools.d";
  };

  # PolyMC and xournalpp.
  nixpkgs.overlays = [
    (import (builtins.fetchTarball "https://github.com/PolyMC/PolyMC/archive/develop.tar.gz")).overlay
  ];
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
      xournalpp
      shared-mime-info
      slack
      polymc
      discord
      zulu8
      loc
      librewolf
      flameshot
      onlyoffice-bin
      newsboat
      vlc
      wineWowPackages.stable
      kalker
      obs-studio
      lutris
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
      mangohud
      protonup
      heroic
      signal-desktop
    ];
  };
}
