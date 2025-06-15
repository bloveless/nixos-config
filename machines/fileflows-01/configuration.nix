# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "fileflows-01"; # Define your hostname.

  systemd.tmpfiles.rules = [
    "d /opt/Tdarr/server 0755 1000 1000"
    "d /opt/Tdarr/configs 0755 1000 1000"
    "d /opt/Tdarr/logs 0755 1000 1000"
    "d /opt/Unmanic/config 0755 1000 1000"
    "d /opt/FileFlows/data 0755 1000 1000"
    "d /opt/FileFlows/logs 0755 1000 1000"
    "d /opt/FileFlows/temp 0755 1000 1000"
  ];

  custom.nfs.mediaMount.enable = true;

  virtualisation = {
    docker.enable = true;
    oci-containers = {
      backend = "docker";
      containers = {
        fileflows = {
          autoStart = true;

          hostname = "fileflows-01";

          image = "revenz/fileflows:25.05";

          environment = {
            TempPathHost = "/opt/FileFlows/temp";
          };

          extraOptions = [
            "--device=/dev/dri:/dev/dri"
          ];

          volumes = [
            "/var/run/docker.sock:/var/run/docker.sock:ro"
            "/opt/FileFlows/data:/app/Data"
            "/opt/FileFlows/logs:/app/Logs"
            "/opt/FileFlows/temp:/temp"
            "/mnt/media:/media"
          ];

          ports = [
            "5000:5000"
          ];
        };
      };
    };
  };

  networking.firewall.enable = true;
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [5000];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
