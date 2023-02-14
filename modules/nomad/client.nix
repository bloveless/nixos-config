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

        auto_encrypt {
          tls = true
        }

        retry_join = [ "192.168.5.20", "192.168.5.57", "192.168.5.108" ]
      '';
      
      "consul.d/client.hcl".text = ''
        bind_addr = "${config.consul.ipAddress}"

        acl {
          tokens {
            default = "${consul.agent_token}"
          }
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
      enableDocker = true;
      settings = {
        datacenter = "homelab01";

        client = {
          enabled = true;
        };

        consul = {
          token = nomad.consul_client_token;
        };
      };
    };
  };
}

