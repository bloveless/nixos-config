{ config, pkgs, ... }:

{
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.defaultGateway = "192.168.4.1";
  networking.nameservers = [ "192.168.5.201" ];

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    git
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  security.sudo.extraRules= [{
    groups = [ "wheel" ];
    commands = [
      {
        command = "/run/current-system/sw/bin/nixos-rebuild";
        options= [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
      },
      {
        command = "/run/current-system/sw/bin/git";
        options= [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
      }
    ];
  }];

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      # dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.dnsname.enable = true;
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.11";
}

