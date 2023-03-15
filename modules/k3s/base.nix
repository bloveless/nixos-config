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
      enable = false;
      package = pkgs.unstable.k3s;
      token = config.k3s.token;
      serverAddr = config.k3s.serverAddr;
    };
  };
}
