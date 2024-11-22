{ ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # 3128 is for the TSN squid stuff.
  networking.firewall.allowedTCPPorts = [ 80 443 3128 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];
  networking.firewall.enable = true;

  services.fail2ban.enable = true;
  services.fail2ban.maxretry = 5;
  services.fail2ban.bantime = "-1";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  security.pam.sshAgentAuth.enable = true;
  programs.ssh.startAgent = true;
}
