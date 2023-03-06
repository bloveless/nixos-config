{ config, pkgs, lib, ... }:

let
  k3s_1_26= pkgs.callPackage ./1_26/default.nix {};
in {
  options = {
    k3s = {
      token = lib.mkOption {
        type = types.str;
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
      extraFlags = "--no-deploy traefik --cluster-cidr 10.24.0.0/16";
      token = config.k3s.token;
      serverAddr = "192.168.5.20";
    };
  };
}
