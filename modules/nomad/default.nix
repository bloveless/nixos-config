{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.custom.nomad;
in {
  options.custom.nomad = {
    enable = lib.mkEnableOption "nomad";
    enableDocker = lib.mkEnableOption "docker";
    enablePodman = lib.mkEnableOption "podman";
    runAsRoot = lib.mkEnableOption "run the nomad service as root (required on clients)";
    dockerAuthPath = lib.mkOption {
      type = lib.types.str;
    };
    consulAgentCaPath = lib.mkOption {
      type = lib.types.str;
    };
    consulClientKeyPath = lib.mkOption {
      type = lib.types.str;
    };
    consulClientPath = lib.mkOption {
      type = lib.types.str;
    };
    servers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    # https://nixos.wiki/wiki/Docker
    virtualisation.docker.enable = cfg.enableDocker;
    # https://nixos.wiki/wiki/Podman
    virtualisation.containers.enable = true;
    virtualisation = {
      podman = {
        enable = cfg.enablePodman;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = false;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };
    services.nomad = {
      dropPrivileges = !cfg.runAsRoot; # clients need to run as root
      enable = true;
      package = pkgs.nomad; # this is overwritten by an overlay
      enableDocker = true;
      extraPackages = with pkgs; [cni-plugins];
      extraSettingsPlugins = with pkgs; [nomad-driver-podman];
      settings = {
        bind_addr = "0.0.0.0";

        server = {
          # license_path is required for Nomad Enterprise as of Nomad v1.1.1+
          #license_path = "/etc/nomad.d/license.hclic"
          enabled = false;
          bootstrap_expect = 1;
        };

        acl = {
          enabled = true;
        };

        client = {
          enabled = true;
          servers = cfg.servers;
        };

        consul = {
          grpc_address = "127.0.0.1:8503";
          address = "127.0.0.1:8500"; # Consul is running locally
          ca_file = cfg.consulAgentCaPath;
          cert_file = cfg.consulClientPath;
          key_file = cfg.consulClientKeyPath;
          verify_ssl = true;
        };

        telemetry = {
          collection_interval = "1s";
          disable_hostname = true;
          prometheus_metrics = true;
          publish_allocation_metrics = true;
          publish_node_metrics = true;
        };

        plugin = [
          {
            docker = {
              config = {
                auth = {
                  config = cfg.dockerAuthPath;
                };
                volumes = {
                  enabled = true;
                };
                allow_caps = ["audit_write" "chown" "dac_override" "fowner" "fsetid" "kill" "mknod" "net_bind_service" "setfcap" "setgid" "setpcap" "setuid" "sys_chroot" "net_raw" "net_admin"];
              };
            };
          }
        ];
      };
    };
  };
}
