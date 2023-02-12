{ config, pkgs, ... }:

{
  services.nomad = {
    enable = true;
    settings = {
      datacenter = "homelab01";

      client = {
        enabled = true;
      };
    };
  };
}

