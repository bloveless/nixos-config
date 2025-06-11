{
  lib,
  config,
  ...
}: let
  cfg = config.custom.consul;
in {
  options.custom.consul = {
    enable = lib.mkEnableOption "my consul";
    gossipKeyPath = lib.mkOption {
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
        server = false;
        retry_join = cfg.retryJoin;
        ca_file = cfg.consulAgentCaPath;
        cert_file = cfg.consulClientPath;
        key_file = cfg.consulClientKeyPath;
        verify_outgoing = true;
        auto_encrypt = {
          tls = true;
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
  };
}
