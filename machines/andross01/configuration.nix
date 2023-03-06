# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base/configuration.nix
    ../../modules/users/brennon.nix
    ../../modules/nomad/base.nix
    ../../modules/nomad/server.nix
    ../../modules/k3s/server.nix
  ];

  k3s = with import ./secrets.nix; {
    token = k3s.token;
  };

  consul = with import ./secrets.nix; {
    ipAddress = "192.168.5.20";
    consulAgentCAKey = consul."consul-agent-ca-key.pem";
    consulAgentCA = consul."consul-agent-ca.pem";
    homelab01ServerConsul0Key = consul."homelab01-server-consul-0-key.pem";
    homelab01ServerConsul0 = consul."homelab01-server-consul-0.pem";
    encryptionKey = consul.encryption_key;
  };

  networking.hostName = "andross01"; # Define your hostname.
  networking.interfaces.ens18.ipv4.addresses = [ {
    address = "192.168.5.20";
    prefixLength = 22;
  } ];
  networking.nameservers = [ "192.168.5.201" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [];
}

