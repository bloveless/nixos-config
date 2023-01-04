# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/base/configuration.nix
    ../../modules/nfs/media.nix
    ../../modules/users/podmanager.nix
    ../../modules/users/brennon.nix
    ../../modules/podman.nix
  ];

  networking.hostName = "kattmonroe"; # Define your hostname.
  networking.interfaces.ens18.ipv4.addresses = [ {
    address = "192.168.5.107";
    prefixLength = 22;
  } ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    8080
    8081
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  services.rootless-podman = {
    enable = true;
    containers = {
      nginx = {
        podName = "nginx";
        description = "Nginx pod";
        imageName = "nginx";
        imageTag = "1.23.3";
        extraConfig = "-p 0.0.0.0:8080:80";
      };

      apache = {
	podName = "apache";
	description = "Apache2 pod";
	imageName = "httpd";
	imageTag = "2.4.54";
	extraConfig = "-p 0.0.0.0:8081:80";
      };
    };
  };
}

