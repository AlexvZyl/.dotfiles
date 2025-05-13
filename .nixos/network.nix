{ ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # 3128 is for the TSN squid stuff.
  networking.firewall.allowedTCPPorts = [ 80 443 3128 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];
  networking.firewall.enable = true;

  # SSH
  services.fail2ban.enable = true;
  services.fail2ban.maxretry = 5;
  services.fail2ban.bantime = "-1";
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
  security.pam.sshAgentAuth.enable = true;
  programs.ssh.startAgent = true;

  # VPN
  services.openvpn.servers = {
    officeVPN = {
      config = '' config /etc/openvpn/TSN_SA.ovpn '';
      autoStart = false;
    };
  };

  # DNS
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  services.resolved.enable = true;
}
