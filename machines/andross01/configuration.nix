# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base/configuration.nix
    ../../modules/users/brennon.nix
  ];

  networking.hostName = "andross01"; # Define your hostname.
  networking.interfaces.ens18.ipv4.addresses = [ {
    address = "192.168.5.20";
    prefixLength = 22;
  } ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nomad_1_4
    consul
  ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    4646 # nomad http api
    4647 # nomad internal rpc
    4648 # nomad gossip protocol
  ];
  networking.firewall.allowedUDPPorts = [
    4648 # nomad gossip protocol
  ];
}

