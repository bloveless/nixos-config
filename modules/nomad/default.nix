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
    role = lib.mkOption {
      type = lib.types.enum ["server" "client"];
    };
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
      enableDocker = cfg.enableDocker;
      extraPackages = with pkgs; [cni-plugins consul];
      extraSettingsPlugins = with pkgs; [nomad-driver-podman];
      settings = {
        bind_addr = "0.0.0.0";

        server = {
          # license_path is required for Nomad Enterprise as of Nomad v1.1.1+
          #license_path = "/etc/nomad.d/license.hclic"
          enabled = cfg.role == "server";
          bootstrap_expect = 3;
        };

        acl = {
          enabled = true;
        };

        client = {
          enabled = cfg.role == "client";
          servers = cfg.servers;
          cni_path = "${pkgs.cni-plugins}/bin";
        };

        consul = {
          grpc_address = "127.0.0.1:8502";
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

        plugin = lib.optionals (cfg.role == "client") [
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
          # Add the Podman plugin configuration here, conditionally
          (lib.mkIf cfg.enablePodman {
            nomad-driver-podman = {
              # You can add specific Podman driver configurations here if needed.
              # For example, to specify a custom socket path or other options.
              # Common configurations are often left at their defaults.
              # See Nomad Podman driver documentation for details:
              # https://www.nomadproject.io/docs/drivers/podman
              config = {
                # Example: If you need to specify a custom socket (unlikely for default NixOS setup)
                # socket_path = "/run/user/1000/podman/podman.sock";
              };
            };
          })
        ];
      };
    };

    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [
      4646 # nomad http api
      4647 # nomad internal rpc
      4648 # nomad gossip protocol
    ];
    networking.firewall.allowedUDPPorts = [
      4648 # nomad gossip protocol
    ];
    networking.firewall.allowedTCPPortRanges = [
      {
        from = 20000;
        to = 32000;
      } # nomad ephemeral ports
    ];
    networking.firewall.allowedUDPPortRanges = [
      {
        from = 20000;
        to = 32000;
      } # nomad ephemeral ports
    ];
  };
}
