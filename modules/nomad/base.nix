{ config, pkgs, ... }:

{
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

  users.groups.nomad = {};
  users.users.nomad = {
    isNormalUser = false;
    extraGroups = [];
    group = "nomad";
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [];
  };
}

