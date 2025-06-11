{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    colmena.url = "github:zhaofengli/colmena/v0.4.0";
    # Add agenix input
    agenix = {
      url = "github:ryantm/agenix/0.15.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-template.url = "github:jhillyerd/agenix-template/1.0.0";
  };
  outputs = {
    nixpkgs,
    colmena,
    agenix,
    agenix-template,
    ...
  }: {
    colmenaHive = colmena.lib.makeHive {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [];
        };
      };

      defaults = {
        pkgs,
        lib,
        ...
      }: {
        nix.settings.experimental-features = "nix-command flakes";

        # do garbage collection weekly to keep disk usage low
        nix.gc = {
          automatic = lib.mkDefault true;
          dates = lib.mkDefault "weekly";
          options = lib.mkDefault "--delete-older-than 7d";
        };

        # Enable the OpenSSH daemon.
        services.openssh = {
          enable = true;
          settings.PasswordAuthentication = false;
          settings.KbdInteractiveAuthentication = false;
        };

        # Enable networking
        networking.networkmanager.enable = true;

        # Set your time zone.
        time.timeZone = "America/Los_Angeles";

        # Select internationalisation properties.
        i18n.defaultLocale = "en_US.UTF-8";

        i18n.extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };

        # Configure keymap in X11
        services.xserver.xkb = {
          layout = "us";
          variant = "";
        };

        nixpkgs.overlays = [
          (import ./overlays/nomad.nix)
        ];

        # List packages installed in system profile. To search, run:
        # $ nix search wget
        environment.systemPackages = with pkgs; [
          #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
          #  wget
          neovim
          nomad
          consul
        ];

        imports = [
          agenix.nixosModules.default
          agenix-template.nixosModules.default
          ./default.nix
          ./modules/consul/default.nix
          ./modules/nomad/default.nix
          ./modules/nfs/default.nix
        ];
      };

      nomad-c03 = {
        name,
        nodes,
        pkgs,
        ...
      }: {
        deployment = {
          targetHost = "nomad-c03";
          targetPort = 22;
          targetUser = "brennon";
          buildOnTarget = true;
        };
        time.timeZone = "America/Los_Angeles";

        imports = [
          ./machines/nomad-c03/configuration.nix
        ];
      };
    };
  };
}
