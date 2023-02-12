{ config, pkgs, ... }:

{
  systemd.services.nomad-server = {
    description = "Nomad server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      User = "nomad";
      Group = "nomad";
      ExecReload = "/bin/kill -HUP $MAINPID";
      ExecStart = "${pkgs.nomad_1_4}/bin/nomad";
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

