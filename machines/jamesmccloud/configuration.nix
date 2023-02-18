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

  services.caddy = {
    enable = true;
    package = pkgs.callPackage ../../modules/caddy/derivation.nix {
      plugins = [
        "github.com/caddy-dns/cloudflare"
      ];
    };
    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
    email = "brennon.loveless@gmail.com";

    virtualHosts = {
      "brennonloveless.com" = {

      };
    };
  };
}
