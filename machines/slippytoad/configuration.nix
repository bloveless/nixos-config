# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base/configuration.nix
    ../../modules/nfs/media.nix
    ../../modules/users/brennon.nix
    ../../modules/dnsmasq/default.nix
  ];

  networking.hostName = "slippytoad"; # Define your hostname.
  networking.interfaces.ens18.ipv4.addresses = [ {
    address = "192.168.5.21";
    prefixLength = 22;
  } ];
  networking.nameservers = [ "192.168.4.1" ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  services.keepalived = with import ./secrets.nix; {
    enable = true;
    vrrpInstances = {
      VI_2 = {
        interface = "ens18";
        priority = 150;
        state = "MASTER";
        unicastSrcIp = "192.168.5.21";
        unicastPeers = [ "192.168.5.59" ];
        virtualRouterId = 100;

        virtualIps = [
          {
            addr = "192.168.5.201/22";
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

