{ config, pkgs, lib, ... }:

let
  k3s_1_26= pkgs.callPackage ./1_26/default.nix {};
in {
  options = {
    k3s = {
      token = lib.mkOption {
        type = lib.types.str;
      };
    };
    serverAddr = {
      serverAddr = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
  };

  config = {
    environment.systemPackages = [
      k3s_1_26
    ];

    services.k3s = with import ./secrets.nix; {
      enable = true;
      package = k3s_1_26;
      extraFlags = "--disable traefik --cluster-cidr 10.24.0.0/16";
      token = config.k3s.token;
      serverAddr = config.k3s.serverAddr;
    };
  };
}