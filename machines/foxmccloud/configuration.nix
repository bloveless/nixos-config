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
  # networking.firewall.allowedTCPPorts = [
  #   8080
  # ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  virtualisation.oci-containers.containers = {
    nginx = {
      image = "nginx:1.23.3";
      autoStart = true;
      ports = [ "0.0.0.0:8080:80" ];
    };
  };

  # systemd.services.podman-nginx.serviceConfig.User = "podmanager";

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
        "--sdnotify=conmon " +
        "--log-driver=journald " +
        "-p '0.0.0.0:8080:80' " +
        # "-v '/home/podmanager/hass/config:/config' " +
        "${image} ${endpodmancli}"; 

      Type = "notify";
      NotifyAccess = "all";
      ExecStop = "${podmancli} stop ${podname} ${endpodmancli}";
      ExecStopPost = cleanup_pod;
      Restart = "always";
      TimeoutStopSec = 15;
    };
  };

  # systemd.services.podman-nginx = {
  #   enable = true;
  #   wantedBy = [ "default.target" ];
  #   after = [ "network.target" ];
  #   description = "Text nginx pod";
  #   path = [
  #     pkgs.shadow # for newuidmap and newgidmap binaries
  #   ];
  #   serviceConfig =
  #   let
  #     podmancli = "${config.virtualisation.podman.package}/bin/podman";
  #     image_version = "1.23.3";
  #     podname = "nginx";
  #   in
  #   {
  #     User = "podmanager";
  #     ExecStartPre= [
  #       "${podmancli} stop -i ${podname}"
  #       "${podmancli} rm -i ${podname}"
  #     ];
  #     ExecStart = "${podmancli} run " +
  #       "--rm " +
  #       "--name=${podname} " +
  #       "--log-driver=journald " +
  #       "-p '0.0.0.0:8080:80' " +
  #       "docker.io/library/nginx:${image_version}";
  #
  #     ExecStop = "${podmancli} stop ${podname}";
  #     ExecStopPost = "${podmancli} rm -i ${podname}";
  #     Restart = "always";
  #     TimeoutStopSec = 15;
  #   };
  # };

}

