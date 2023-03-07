{ config, pkgs, lib, ... }:

{
  options = {
    k3s = {
      token = lib.mkOption {
        type = lib.types.str;
      };
      serverAddr = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
  };

  config = {
    environment.systemPackages = [
      pkgs.unstable.k3s
    ];

    services.k3s = with import ./secrets.nix; {
      enable = true;
      package = pkgs.unstable.k3s;
      extraFlags = "--disable traefik --cluster-cidr 10.24.0.0/16";
      token = config.k3s.token;
      serverAddr = config.k3s.serverAddr;
    };
  };
}
