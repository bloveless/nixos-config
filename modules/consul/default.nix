{config, ...}: {
  age.secrets.consulGossipEncryptionKey.file = ../../secrets/gossip-encryption-key.age;
  age.secrets.consulAgentCa = {
    file = ../../secrets/consul-agent-ca.pem.age;
    mode = "600";
    owner = "consul";
    group = "consul";
  };
  age.secrets.consulClientKey = {
    file = ../../secrets/dc1-client-consul-2-key.pem.age;
    mode = "600";
    owner = "consul";
    group = "consul";
  };
  age.secrets.consulClient = {
    file = ../../secrets/dc1-client-consul-2.pem.age;
    mode = "600";
    owner = "consul";
    group = "consul";
  };

  age-template.files."consul-gossip-encryption.hcl" = {
    owner = "consul";
    group = "consul";
    mode = "0600"; # Restrict access to the key
    vars = {
      gossipKey = config.age.secrets.consulGossipEncryptionKey.path;
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
      bind_addr = "192.168.100.20";
      client_addr = "0.0.0.0";
      server = false;
      retry_join = [
        "192.168.100.15"
        "192.168.100.16"
        "192.168.100.17"
      ];
      ca_file = config.age.secrets.consulAgentCa.path;
      cert_file = config.age.secrets.consulClient.path;
      key_file = config.age.secrets.consulClientKey.path;
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
        grpc_tls = -1;
      };
      connect = {
        enabled = true;
      };
    };
    extraConfigFiles = [
      config.age-template.files."consul-gossip-encryption.hcl".path
    ];
  };
}
