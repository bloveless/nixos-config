{ config, pkgs, ... }:

{
  environment.etc = {
    "nomad.d/nomad.hcl".text = ''
      datacenter = "homelab01"
      data_dir = "/opt/nomad"
    '';

    "nomad.d/client.hcl".text = ''
      client {
        enabled = true
      }
    '';
  };

  # systemd.services.nomad-server = {
  #   description = "Nomad server";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network-online.target" ];
  #   serviceConfig = {
  #     User = "nomad";
  #     Group = "nomad";
  #     ExecReload = "/bin/kill -HUP $MAINPID";
  #     ExecStart = "${pkgs.nomad_1_4}/bin/nomad -config /etc/nomad.d";
  #     KillMode = "process";
  #     LimitNOFILE = 65536;
  #     LimitNPROC = "infinity";
  #     Restart = "on-failure";
  #     RestartSec = 2;
  #     TasksMax = "infinity";
  #     OOMScoreAdjust = -1000;
  #   };
  # };
}

