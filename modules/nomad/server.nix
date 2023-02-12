{ config, pkgs, ... }:

{
  services.nomad = {
    enable = true;
    settings = {
      datacenter = "homelab01";

      server = {
        enabled = true;
        bootstrap_expect = 3;

        server_join = {
          retry_join = [ "192.168.5.20" "192.168.5.57" "192.168.5.108" ];
          retry_max = 3;
          retry_interval = "15s";
        };
      };
    };
  };
}

