{
  lib,
  config,
  ...
}: let
  cfg = config.custom.consul;
in {
  options.custom.consul = {
    enable = lib.mkEnableOption "my consul";
    role = lib.mkOption {
      type = lib.types.enum ["server" "client"];
    };
    gossipKeyPath = lib.mkOption {
      type = lib.types.str;
    };
    consulAgentCaPath = lib.mkOption {
      type = lib.types.str;
    };
    consulAgentCertKeyPath = lib.mkOption {
      type = lib.types.str;
    };
    consulAgentCertPath = lib.mkOption {
      type = lib.types.str;
    };
    bindAddr = lib.mkOption {
      type = lib.types.str;
    };
    retryJoin = lib.mkOption {
      type = lib.types.listOf lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable {
    age-template.files."consul-gossip-encryption.hcl" = {
      owner = "consul";
      group = "consul";
      mode = "0600"; # Restrict access to the key
      vars = {
        gossipKey = cfg.gossipKeyPath; # config.age.secrets.consulGossipEncryptionKey.path;
      };
      content = ''
        encrypt = "$gossipKey"
      '';
    };

    services.consul = {
      enable = true;
      extraConfig = {
        datacenter = "dc1";
        log_level = "INFO";
        bind_addr = cfg.bindAddr;
        client_addr = "0.0.0.0";
        server = cfg.role == "server";
        bootstrap_expect =
          if cfg.role == "server"
          then 3
          else 0;
        retry_join = cfg.retryJoin;
        tls = {
          defaults =
            {
              verify_incoming = true;
              verify_outgoing = true;
              verify_server_hostname = true;
              ca_file = cfg.consulAgentCaPath;
            }
            // lib.optionalAttrs (cfg.role == "server") {
              cert_file = cfg.consulAgentCertPath;
              key_file = cfg.consulAgentCertKeyPath;
            };
        };
        auto_encrypt = {
          allow_tls = cfg.role == "server";
          tls = cfg.role == "client";
        };
        performance = {
          raft_multiplier = 1; # Recommended for 3-5 servers
        };
        ui_config = {
          enabled = cfg.role == "server";
        };
        telemetry = {
          prometheus_retention_time = "480h";
          disable_hostname = true; # Recommended to avoid redundant labels
        };
        ports = {
          grpc = 8502;
          grpc_tls = 8503;
        };
        connect = {
          enabled = true;
        };
      };
      extraConfigFiles = [
        config.age-template.files."consul-gossip-encryption.hcl".path
      ];
    };

    networking.firewall.enable = true;
    networking.firewall.allowedTCPPorts = [
      8300 # consul rpc address
      8301 # consul serf lan
      8302 # consul serf wan
      8500 # consul http api
      8501 # consul https api
      8502 # consul grpc api
      8503 # consul grpc api tls
      8600 # consul dns
    ];
    networking.firewall.allowedTCPPortRanges = [
      {
        from = 20000;
        to = 32000;
      } # consul proxy sidecar
    ];
    networking.firewall.allowedUDPPorts = [
      8301 # consul serf lan
      8302 # consul serf wan
      8600 # consul dns
    ];
    networking.firewall.allowedUDPPortRanges = [
      {
        from = 20000;
        to = 32000;
      } # consul proxy sidecar
    ];
  };
}
