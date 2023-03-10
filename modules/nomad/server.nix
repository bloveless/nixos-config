{ config, lib, pkgs, ... }:
with lib;
let
  cni-plugins-1-2 = pkgs.callPackage ./cni-plugins.nix {};
in {
  options = {
    consul = {
      ipAddress = mkOption {
        type = types.str;
      };

      consulAgentCAKey = mkOption {
        type = types.str;
      };

      consulAgentCA = mkOption {
        type = types.str;
      };

      homelab01ServerConsul0Key = mkOption {
        type = types.str;
      };

      homelab01ServerConsul0 = mkOption {
        type = types.str;
      };

      encryptionKey = mkOption {
        type = types.str;
      };
    };
  };

  config = {
    environment.etc = {
      "consul.d/certs/consul-agent-ca-key.pem".text = config.consul.consulAgentCAKey;

      "consul.d/certs/consul-agent-ca.pem".text = config.consul.consulAgentCA;

      "consul.d/certs/homelab01-server-consul-0-key.pem".text = config.consul.homelab01ServerConsul0Key;

      "consul.d/certs/homelab01-server-consul-0.pem".text = config.consul.homelab01ServerConsul0;

      "consul.d/consul.hcl".text = ''
        datacenter = "homelab01"
        encrypt = "${config.consul.encryptionKey}"
        verify_incoming = true
        verify_outgoing = true
        verify_server_hostname = true

        ca_file = "/etc/consul.d/certs/consul-agent-ca.pem"
        cert_file = "/etc/consul.d/certs/homelab01-server-consul-0.pem"
        key_file = "/etc/consul.d/certs/homelab01-server-consul-0-key.pem"

        auto_encrypt {
          allow_tls = true
        }

        acl {
          enabled = true
          default_policy = "allow"
          enable_token_persistence = true
        }

        performance {
          raft_multiplier = 1
        }

        retry_join = [ "192.168.5.20", "192.168.5.57", "192.168.5.108" ]
      '';
      
      "consul.d/server.hcl".text = ''
        server = true
        bootstrap_expect = 3
        client_addr = "0.0.0.0"
        bind_addr = "${config.consul.ipAddress}"

        connect {
          enabled = true
        }

        addresses {
          grpc = "127.0.0.1"
        }

        ports {
          grpc_tls = 8503
        }
      '';
      "nomad.d/server.hcl".text = ''
        datacenter = "homelab01"

        server {
          enabled = true
          bootstrap_expect = 3
        }
      '';
    };

    services.consul = {
      enable = true;
      webUi = true;
    };

    services.nomad = {
      enableDocker = false;
    };
  };
}

