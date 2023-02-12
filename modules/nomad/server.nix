{ config, pkgs, ... }:

{
  environment.etc = {
    "nomad.d/nomad.hcl".text = ''
      datacenter = "homelab01"
      data_dir = "/opt/nomad"
    '';

    "nomad.d/server.hcl".text = ''
      server {
        enabled = true
        bootstrap_expect = 3

        server_join {
          retry_join = [ "192.168.5.20" "192.168.5.57" "192.168.5.108" ]
          retry_max = 3
          retry_interval = "15s"
        }
      }
    '';
  };

  fileSystems."/opt/nomad" = {
    device = "/dev/null";
    fsType = "none";
    options = [ "bind" ];
    copyWithPermissions = true;
    permissions = "0700";
  };

  systemd.services.nomad-server = {
    description = "Nomad server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      User = "nomad";
      Group = "nomad";
      ExecReload = "/bin/kill -HUP $MAINPID";
      ExecStart = "${pkgs.nomad_1_4}/bin/nomad -config /etc/nomad.d";
      KillMode = "process";
      LimitNOFILE = 65536;
      LimitNPROC = "infinity";
      Restart = "on-failure";
      RestartSec = 2;
      TasksMax = "infinity";
      OOMScoreAdjust = -1000;
    };
  };
}

