{ config, lib, pkgs, ... }:
with lib;
{
  options = {
    consul = {
      ipAddress = mkOption {
        type = types.str;
      };

      consulAgentCA = mkOption {
        type = types.str;
      };

      encryptionKey = mkOption {
        type = types.str;
      };
    };
  };

  config = {
    environment.etc = {
      "consul.d/certs/consul-agent-ca.pem".text = config.consul.consulAgentCA;

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
      "nomad.d/client.hcl".text = ''
        datacenter = "homelab01"

        client {
          enabled = true

          host_volume "wireguard-config" {
            path = "/mnt/storage-nfs/media-server/wireguard/config"
            read_only = false
          }
        }
        
        plugin "docker" {
          config {
            allow_privileged = true
            allow_caps = ["audit_write", "chown", "dac_override", "fowner", "fsetid", "kill", "mknod", "net_bind_service", "setfcap", "setgid", "setpcap", "setuid", "sys_chroot", "net_admin", "sys_module" ]
            
            volumes {
                enabled = true
            }
          }
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
      dropPrivileges = false;
      extraSettingsPaths = [
        "/etc/nomad.d"
      ];
    };
  };
}

