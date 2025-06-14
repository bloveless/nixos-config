# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nomad-s02";

  age.secrets.consulGossipEncryptionKey.file = ../../secrets/gossip-encryption-key.age;
  age.secrets.consulAgentCa = {
    file = ../../secrets/consul-agent-ca.pem.age;
    mode = "600";
    owner = "consul";
    group = "consul";
  };
  age.secrets.consulClientKey = {
    file = ../../secrets/dc1-server-consul-1-key.pem.age;
    mode = "600";
    owner = "consul";
    group = "consul";
  };
  age.secrets.consulClient = {
    file = ../../secrets/dc1-server-consul-1.pem.age;
    mode = "600";
    owner = "consul";
    group = "consul";
  };
  age.secrets.dockerAuth.file = ../../secrets/docker-auth.json.age;

  custom.consul = {
    enable = true;
    role = "server";
    gossipKeyPath = config.age.secrets.consulGossipEncryptionKey.path;
    consulAgentCaPath = config.age.secrets.consulAgentCa.path;
    consulClientKeyPath = config.age.secrets.consulClientKey.path;
    consulClientPath = config.age.secrets.consulClient.path;
    bindAddr = "192.168.100.16";
    retryJoin = [
      "192.168.100.15"
      "192.168.100.16"
      "192.168.100.17"
    ];
  };

  custom.nomad = {
    enable = true;
    role = "server";
    enableDocker = false;
    enablePodman = false;
    runAsRoot = false;
    dockerAuthPath = config.age.secrets.dockerAuth.path;
    consulAgentCaPath = config.age.secrets.consulAgentCa.path;
    consulClientKeyPath = config.age.secrets.consulClientKey.path;
    consulClientPath = config.age.secrets.consulClient.path;
    servers = [
      "192.168.100.15:4647"
      "192.168.100.16:4647"
      "192.168.100.17:4647"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
