{ config, pkgs, ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];
  networking.firewall.enable = false;

  networking.resolvconf.dnsExtensionMechanism = true;
  services.resolved.enable = true;

  services.fail2ban.enable = false;
  services.fail2ban.maxretry = 5;
  services.fail2ban.bantime = "-1";
}

