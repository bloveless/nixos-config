{ config, pkgs, ... }:

let
  nomad-1-5 = pkgs.callPackage ./nomad.nix {};
  cni-plugins-1-2 = pkgs.callPackage ./cni-plugins.nix {};
in {
  environment.systemPackages = [
    pkgs.getent
    nomad-1-5
    pkgs.consul
    pkgs.wireguard-tools
  ];

  services.nomad = {
    enable = true;
    package = nomad-1-5;
    dropPrivileges = false;
    extraSettingsPlugins = [ "/opt/cni" ];
    # extraSettingsPlugins = [ cni-plugins-1-2 ];
    # extraPackages = [ cni-plugins-1-2 ];
    extraSettingsPaths = [
      "/etc/nomad.d"
    ];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    4646 # nomad http api
    4647 # nomad internal rpc
    4648 # nomad gossip protocol
    8600 # consul dns
    8500 # consul http api
    8501 # consul https api
    8502 # consul grpc api
    8503 # consul grpc api tls
    8301 # consul serf lan
    8302 # consul serf wan
    8300 # consul rpc address
  ];
  networking.firewall.allowedTCPPortRanges = [
    { from = 21000; to = 21255; } # consul proxy sidecar
  ];
  networking.firewall.allowedUDPPorts = [
    4648 # nomad gossip protocol
    8600 # consul dns
    8501 # consul https api
    8502 # consul grpc api
    8503 # consul grpc api tls
    8301 # consul serf lan
    8302 # consul serf wan
  ];
  networking.firewall.allowedUDPPortRanges = [
    { from = 21000; to = 21255; } # consul proxy sidecar
  ];
}

