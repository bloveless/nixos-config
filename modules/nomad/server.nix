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
      "consul.d/certs/consul-agent-ca-key.pem".text = consul."consul-agent-ca-key.pem";

      "consul.d/certs/consul-agent-ca.pem".text = consul."consul-agent-ca.pem";

      "consul.d/certs/homelab01-server-consul-0-key.pem".text = consul."homelab01-server-consul-0-key.pem";

      "consul.d/certs/homelab01-server-consul-0.pem".text = consul."homelab01-server-consul-0.pem";

      "consul.d/consul.hcl".text = ''
        datacenter = "homelab01"
        encrypt = "${consul.encryption_key}"
        verify_incoming = true
        verify_outgoing = true
        verify_server_hostname = true

        ca_file = "/etc/consul.d/certs/consul-agent-ca.pem"
        cert_file = "/etc/consul.d/certs/homelab01-server-consul-0.pem"
        key_file = "/etc/consul.d/certs/homelab01-server-consul-0-key.pem"

        auto_encrypt {
          allow_tls = true
        }

        retry_join = [ "192.168.5.20", "192.168.5.57", "192.168.5.108" ]

        acl {
          enabled = true
          default_policy = "deny"
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

    services.nomad = with import ./secrets.nix; {
      enable = true;
      package = pkgs.nomad_1_4;
      enableDocker = false;
      settings = {
        datacenter = "homelab01";

        server = {
          enabled = true;
          bootstrap_expect = 3;
        };

        acl = {
          enabled = true;
        };

        consul = {
          token = nomad.consul_server_token
        };
      };
    };
  };
}

