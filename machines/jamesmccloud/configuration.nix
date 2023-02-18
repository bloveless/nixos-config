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
  ];

  networking.hostName = "jamesmccloud"; # Define your hostname.
  networking.interfaces.ens18.ipv4.addresses = [ {
    address = "192.168.5.58";
    prefixLength = 22;
  } ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    443 # caddy https
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  environment.systemPackages = with pkgs; [
    pkgs.cntr
  ];

  services.caddy = {
    enable = true;
    package = pkgs.callPackage ../../modules/caddy/default.nix {};
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
    email = "brennon.loveless@gmail.com";

    globalConfig = ''
      debug
    '';
    
    virtualHosts = {
      "localhost" = {
        extraConfig = ''
          tls internal
          respond "Localhost"
        '';
      };
    };
  };
}
