{ config, pkgs, lib, ... }:

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

  imports = [ ./base.nix ];

  config = {
    services.k3s = {
      role = "server";
      extraFlags = "--cluster-cidr 10.24.0.0/16 --node-taint node-role.kubernetes.io/control-plane=true:NoSchedule";
      clusterInit = config.k3s.clusterInit;
    };

    server.kubernetes = {
      roles = ["master" "node"];
      masterAddress = "192.168.5.20";
      apiserverAddress = "https://192.168.5.20:6443";
      easyCerts = true;

      apiserver = {
        securePort = 6443;
        advertiseAddress = "192.168.5.20";
      };

      # use coredns
      addons.dns.enable = true;
    };

    networking.firewall.allowedTCPPorts = [
      6443 # k3s/kubernetes api
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
  };
}
