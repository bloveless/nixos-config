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
        datacenter = "dc1"
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
          default_policy = "allow"
          enable_token_persistence = true
        }

        performance {
          raft_multiplier = 1
        }

        ui_config {
          enabled = true
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
    };

    services.nomad = {
      enable = true;
      package = pkgs.nomad_1_4;
      enableDocker = false;
      settings = {
        datacenter = "homelab01";

        server = {
          enabled = true;
          bootstrap_expect = 3;

          server_join = {
            retry_join = [ "192.168.5.20" "192.168.5.57" "192.168.5.108" ];
            retry_max = 3;
            retry_interval = "15s";
          };
        };
      };
    };
  };
}

