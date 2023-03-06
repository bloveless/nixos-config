{ config, pkgs, ... }:

{
  options = {
    k3s = {
      token = lib.mkOption {
        type = lib.types.str;
      };
      clusterInit = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = {
    imports = [ ./base.nix ];

    services.k3s = {
      role = "server";
      disableAgent = true;
      clusterInit = config.k3s.clusterInit;
    };

    networking.firewall.allowedTCPPorts = [
      6443 # k3s api
      10250 # k3s kubelet metrics
    ];
    networking.firewall.allowedTCPPortRanges = [
      { from = 2379; to = 2380; } # k3s embedded etcd
    ];
    networking.firewall.allowedUDPPorts = [
      8472 # k3s flannel vxlan
      51820 # k3s flannel wireguard
      51821 # k3s flannel wireguard ipv6
    ];
  }
}
