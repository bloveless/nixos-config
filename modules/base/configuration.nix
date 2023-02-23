{ config, pkgs, ... }:

{
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.defaultGateway = "192.168.4.1";

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    git
    libva-utils
  ];

  # Enable GPU
  # nixpkgs.config.packageOverrides = pkgs: {
  #   vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  # };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      # vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      # vaapiVdpau
      # libvdpau-va-gl
    ];
  };


  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  security.sudo.extraRules= [{
    groups = [ "wheel" ];
    commands = [
      {
        command = "/run/current-system/sw/bin/nixos-rebuild";
        options= [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
      }

      {
        command = "/run/current-system/sw/bin/git";
        options= [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
      }
    ];
  }];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.11";
}

