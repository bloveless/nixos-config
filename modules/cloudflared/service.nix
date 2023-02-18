{ config, lib, pkgs, ... }:
with lib;
{
  options.cloudflared = {
    token = mkOption {
      type = types.str;
    };
  };

  config = {
    users.users.cloudflared = {
      group = "cloudflared";
      isSystemUser = true;
    };
    users.groups.cloudflared = { };

    systemd.services.cloudflared = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.callPackage ./default.nix {}}/bin/cloudflared tunnel --no-autoupdate run --token=${config.cloudflared.token}";
        Restart = "always";
        User = "cloudflared";
        Group = "cloudflared";
      };
    };
  };
}
