# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      # Auto generated hardware config.
      /etc/nixos/hardware-configuration.nix

      # Custom configs.
      ./system.nix
      ./gpu.nix
      ./services.nix
      ./packages.nix
      ./lsp.nix
      ./user.nix
    ];
  }
