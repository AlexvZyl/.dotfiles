{ config, pkgs, ... }:

{
  users.users.alex = {
    isNormalUser = true;
    description = "Alexander van Zyl";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      discord
      librewolf
      flameshot
      dunst
      newsboat
      rofi
      rofi-pass
      thunderbird
      gparted
      pinta
      pfetch
      lazygit
      audacity
      zoxide
      zathura
      ranger
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
    ];
  };
}
