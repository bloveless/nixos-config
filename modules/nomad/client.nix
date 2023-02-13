{ config, lib, pkgs, ... }:
with lib;
{
  options.consul = {
    ipAddress = mkOption {
      type = types.str;
    };
  };

  config = {
    environment.etc = with import ./secrets.nix; {
      "consul.d/certs/consul-agent-ca.pem".text = consul."consul-agent-ca.pem";

      "consul.d/consul.hcl".text = ''
        datacenter = "homelab01"
        encrypt = "${consul.encryption_key}"
        verify_incoming = true
        verify_outgoing = true
        verify_server_hostname = true

        ca_file = "/etc/consul.d/certs/consul-agent-ca.pem"

        auto_encrypt {
          allow_tls = true
        }

        retry_join = [ "192.168.5.20", "192.168.5.57", "192.168.5.108" ]

        acl {
          enabled = true
          default_policy = "allow"
          enable_token_persistence = true
        }

        performance {
          raft_multiplier = 1
        }
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

