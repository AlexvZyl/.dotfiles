{ config, pkgs, ... }:

{
  # PolyMC.
  nixpkgs.overlays = [
    (import (builtins.fetchTarball "https://github.com/PolyMC/PolyMC/archive/develop.tar.gz")).overlay
  ];
  environment.systemPackages = with pkgs; [ polymc ];

  users.users.alex = {
    isNormalUser = true;
    description = "Alexander van Zyl";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      discord
      librewolf
      flameshot
      polymc
      newsboat
      vlc
      wineWowPackages.stable
      kalker
      obs-studio
      lutris
      rofi
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
    ];
  };

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS =
      "$HOME/.steam/root/compatibilitytools.d";
  };
}
