{ config, lib, pkgs, ... }:
with lib;
{
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

        auto_encrypt {
          tls = true
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
      
      "consul.d/client.hcl".text = ''
        bind_addr = "${config.consul.ipAddress}"
      '';
    };

    services.consul = {
      enable = true;
      webUi = true;
    };

    services.nomad = {
      enable = true;
      package = pkgs.nomad_1_4;
      enableDocker = true;
      settings = {
        datacenter = "homelab01";

        client = {
          enabled = true;
        };
      };
    };
  };
}

