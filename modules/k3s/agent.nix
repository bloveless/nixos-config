{ config, pkgs, ... }:

{
  imports = [ ./base.nix ];
  
  services.k3s = {
    role = "agent";
  };

  networking.firewall.allowedTCPPorts = [
    10250 # k3s kubelet metrics
    443 # consul api gateway
  ];
  networking.firewall.allowedTCPPortRanges = [];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s flannel vxlan
    51820 # k3s flannel wireguard
    51821 # k3s flannel wireguard ipv6
  ];
}
