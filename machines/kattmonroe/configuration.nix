# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base/configuration.nix
    ../../modules/base/igpu.nix
    ../../modules/storage/nfs.nix
    ../../modules/users/brennon.nix
    ../../modules/nomad/base.nix
    ../../modules/nomad/client.nix
  ];

  environment.etc = {
    "nomad.d/volumes.hcl".text = ''
      client {
        host_volume "fileflows-node-data" {
          path = "/mnt/storage-nfs/media-server/fileflows-node/Data"
          read_only = false
        }
        host_volume "fileflows-node-logs" {
          path = "/mnt/storage-nfs/media-server/fileflows-node/Logs"
          read_only = false
        }
        host_volume "fileflows-node-temp" {
          path = "/mnt/storage-nfs/media-server/fileflows-node/Temp"
          read_only = false
        }
      }
    '';
    "nomad.d/extra.hcl".text = ''
      client {
        meta {
          gpu = "true"
        }
      }
    '';
  };

  consul = with import ./secrets.nix; {
    ipAddress = "192.168.5.107";
    consulAgentCA = consul."consul-agent-ca.pem";
    encryptionKey = consul.encryption_key;
  };

  networking.hostName = "kattmonroe"; # Define your hostname.
  networking.interfaces.ens18.ipv4.addresses = [ {
    address = "192.168.5.107";
    prefixLength = 22;
  } ];
  networking.nameservers = [ "192.168.5.201" ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    9999 # fabio lb
    9998 # fabio ui
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  services.keepalived = with import ./secrets.nix; {
    enable = true;
    vrrpInstances = {
      VI_2 = {
        interface = "ens18";
        priority = 150;
        state = "MASTER";
        unicastSrcIp = "192.168.5.107";
        unicastPeers = [ "192.168.5.56" "192.168.5.19" ];
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

