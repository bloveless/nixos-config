# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: let
  unstableTarball =
    fetchTarball
    https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/base/configuration.nix
    ../../modules/base/igpu.nix
    ../../modules/storage/nfs.nix
    ../../modules/users/brennon.nix
    ../../modules/k3s/agent.nix
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  k3s = with import ./secrets.nix; {
    token = k3s.token;
    serverAddr = "https://192.168.5.20:6443";
  };

  networking.hostName = "kattmonroe"; # Define your hostname.
  networking.interfaces.ens18.ipv4.addresses = [
    {
      address = "192.168.5.107";
      prefixLength = 22;
    }
  ];
  networking.nameservers = ["192.168.5.201"];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [];
  # networking.firewall.allowedUDPPorts = [ ... ];

  services.keepalived = with import ./secrets.nix; {
    enable = true;
    vrrpInstances = {
      VI_2 = {
        interface = "ens18";
        priority = 150;
        state = "MASTER";
        unicastSrcIp = "192.168.5.107";
        unicastPeers = ["192.168.5.56" "192.168.5.19"];
        virtualRouterId = 100;

        virtualIps = [
          {
            addr = "192.168.5.202/22";
          }
        ];

        extraConfig = ''
          advert_int 1

          authentication {
            auth_type PASS
            auth_pass ${keepalived.auth_pass}
          }
        '';
      };
    };
  };
}
