# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base/configuration.nix
    ../../modules/users/podmanager.nix
    ../../modules/users/brennon.nix
  ];

  networking.hostName = "foxmccloud"; # Define your hostname.
  networking.interfaces.ens18.ipv4.addresses = [ {
    address = "192.168.5.19";
    prefixLength = 22;
  } ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  systemd.services.podman-nginx = {
    enable = true;
    wantedBy = [ "default.target" ];
    after = [ "network.target" ];
    description = "Text nginx pod";
    serviceConfig =
    let
      podmancli = "${config.virtualisation.podman.package}/bin/podman";
      image_version = "1.23.3";
      podname = "nginx";
    in
    {
      User = "podmanager";
      ExecStartPre= [
        "${podmancli} stop -i ${podname}"
        "${podmancli} rm -i ${podname}"
      ];
      ExecStart = "${podmancli} run " +
        "--rm " +
        "--name=${podname} " +
        "--log-driver=journald " +
        "-p '0.0.0.0:8080:80' " +
        "docker.io/library/nginx:${image_version}";

      ExecStop = "${podmancli} stop ${podname}";
      ExecStopPost = "${podmancli} rm -i ${podname}";
      Restart = "always";
      TimeoutStopSec = 15;
    };
  };

}

