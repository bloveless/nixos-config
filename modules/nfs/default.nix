{
  lib,
  config,
  ...
}: let
  cfg = config.custom.nfs;

  commonMountOptions = {
    type = "nfs";
    mountConfig = {
      Options = "noatime,vers=4.1";
    };
  };

  commonAutoMountOptions = {
    wantedBy = ["multi-user.target"];
    automountConfig = {
      TimeoutIdleSec = "600";
    };
  };

  # Define mount configurations with enable conditions
  mountConfigs = [
    {
      condition = cfg.homelabMount.enable;
      mount =
        commonMountOptions
        // {
          what = "192.168.0.115:/volume1/homelab";
          where = "/mnt/homelab";
        };
      automount =
        commonAutoMountOptions
        // {
          where = "/mnt/homelab";
        };
    }
    {
      condition = cfg.mediaMount.enable;
      mount =
        commonMountOptions
        // {
          what = "192.168.0.115:/volume1/homelab/media-server/plex/data";
          where = "/mnt/media";
        };
      automount =
        commonAutoMountOptions
        // {
          where = "/mnt/media";
        };
    }
  ];

  # Filter and extract enabled mounts
  enabledMountConfigs = lib.filter (m: m.condition) mountConfigs;
  enabledMounts = lib.map (m: m.mount) enabledMountConfigs;
  enabledAutoMounts = lib.map (m: m.automount) enabledMountConfigs;
in {
  options.custom.nfs = {
    mediaMount = {
      enable = lib.mkEnableOption "the NFS media mount";
    };
    homelabMount = {
      enable = lib.mkEnableOption "the homelab media mount";
    };
  };

  config = lib.mkIf (cfg.mediaMount.enable || cfg.homelabMount.enable) {
    services.rpcbind.enable = true; # needed for NFS
    # optional, but ensures rpc-statsd is running for on demand mounting
    boot.supportedFilesystems = ["nfs"];

    systemd.mounts = enabledMounts;
    systemd.automounts = enabledAutoMounts;
  };
}
