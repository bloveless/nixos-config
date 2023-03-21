{ config, pkgs, ... }:

{
  imports = [ ./base.nix ];
  
  services = {
    k3s = {
      role = "agent";
    };

    kubernetes = {
      roles = ["node"];
      masterAddress = "192.168.5.20";
      easyCerts = true;

      kubelet.kubeconfig.server = "https://192.168.5.20:6443";
      apiserverAddress = "https://192.168.5.20:6443";

      addons.dns.enable = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    443 # consul api gateway
    10250 # k3s kubelet metrics
  ];
  networking.firewall.allowedTCPPortRanges = [];
  networking.firewall.allowedUDPPorts = [
    8472 # k3s flannel vxlan
    51820 # k3s flannel wireguard
    51821 # k3s flannel wireguard ipv6
  ];
}

