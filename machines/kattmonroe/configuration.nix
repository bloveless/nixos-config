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

  networking.hostName = "kattmonroe"; # Define your hostname.
  networking.interfaces.ens18.ipv4.addresses = [ {
    address = "192.168.5.107";
    prefixLength = 22;
  } ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    8080
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  systemd.services.podman-nginx = {
    enable = true;
    wantedBy = [ "default.target" ];
    after = [ "network.target" ];
    description = "Nginx pod";
    serviceConfig =
    let
      podmancli = "${pkgs.bash}/bin/bash -l -c \"${config.virtualisation.podman.package}/bin/podman";
      endpodmancli = "\"";
      image = "nginx:1.23.3";
      podname = "nginx";
      cleanup_pod = [
        "${podmancli} stop -i ${podname} ${endpodmancli}"
        "${podmancli} rm -i ${podname} ${endpodmancli}"
      ];
    in
    {
      User = "podmanager";
      WorkingDirectory = "/home/podmanager";
      ExecStartPre = cleanup_pod;
      ExecStart = "${podmancli} run " +
        "--rm " +
        "--name=${podname} " +
        "--log-driver=journald " +
        "-p '0.0.0.0:8080:80' " +
        "${image} ${endpodmancli}";

      ExecStop = "${podmancli} stop ${podname} ${endpodmancli}";
      ExecStopPost = cleanup_pod;
      Restart = "always";
      TimeoutStopSec = 15;
    };
  };
}

