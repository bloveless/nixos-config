{ config, pkgs, ... }:

{
  services.nomad = {
    enable = true;
    package = pkgs.nomad_1_4;
    settings = {
      datacenter = "homelab01";

      client = {
        enabled = true;
      };
    };
  };
}

