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
    ../../modules/nomad/client.nix
  ];

  consul.ipAddress = "192.168.5.107";

  networking.hostName = "kattmonroe"; # Define your hostname.
  networking.interfaces.ens18.ipv4.addresses = [ {
    address = "192.168.5.107";
    prefixLength = 22;
  } ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    9999 # fabio lb
    9998 # fabio ui
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}

