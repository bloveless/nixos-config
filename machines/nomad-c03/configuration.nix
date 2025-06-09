# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = "nix-command flakes";

  # do garbage collection weekly to keep disk usage low
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nomad-c03"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.brennon = {
    isNormalUser = true;
    description = "Brennon Loveless";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINf6kijsnbx9rJOtxu6pNUgnZOBNK+GqSIHaZEo3IT8Q brennon@Brennons-MacBook-Pro.local"
    ];
  };

  security.sudo.extraRules = [
    {
      users = [ "brennon" ];
      commands = [
        {
          command = "ALL";
          options = [ "SETENV" "NOPASSWD" ];
        }
      ];
    }
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      nomad_1_10_1 = prev.buildGo124Module (finalAttrs: {
        pname = "nomad";
        version = "1.10.1";
        vendorHash = "sha256-ZBCwZFrCauT0y/cMhrZow2I0fgbl4JrIEIjmtm/zVd4";

        subPackages = [ "." ];

        src = prev.fetchFromGitHub {
          owner = "hashicorp";
          repo = finalAttrs.pname;
          rev = "v${finalAttrs.version}";
          sha256 = "sha256-fHLtLp2K0BPmN9SYL6xHay9h4zHsGAE8bqboID3J0HE=";
        };

        nativeBuildInputs = [ prev.installShellFiles ];

        ldflags = [
          "-X github.com/hashicorp/nomad/version.Version=${finalAttrs.version}"
          "-X github.com/hashicorp/nomad/version.VersionPrerelease="
          "-X github.com/hashicorp/nomad/version.BuildDate=1970-01-01T00:00:00Z"
        ];

        # ui:
        #  Nomad release commits include the compiled version of the UI, but the file
        #  is only included if we build with the ui tag.
        tags = [ "ui" ];

        postInstall = ''
          echo "complete -C $out/bin/nomad nomad" > nomad.bash
          installShellCompletion nomad.bash
        '';

        meta = {
          homepage = "https://www.nomadproject.io/";
          description = "Distributed, Highly Available, Datacenter-Aware Scheduler";
          mainProgram = "nomad";
          license = "bsl11";
          maintainers = [];
        };
      });
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    neovim
    nomad_1_10_1
    consul
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  services.nomad = {
    dropPrivileges = false; # clients need to run as root
    enable = true;
    package = pkgs.nomad_1_10_1;
    enableDocker = true;
    settings = {
      server = {
        enabled = false;
        bootstrap_expect = 1;
      };
      client = {
        enabled = true;
      };
    };
  };

  age.secrets.gossipEncryptionKey.file = ../../secrets/gossip-encryption-key.age;
  age.secrets.consulAgentCa = {
    file = ../../secrets/consul-agent-ca.pem.age;
    mode = "700";
    owner = "consul";
    group = "consul";
  };
  age.secrets.consulClientKey = {
    file = ../../secrets/dc1-client-consul-2-key.pem.age;
    mode = "700";
    owner = "consul";
    group = "consul";
  };
  age.secrets.consulClient = {
    file = ../../secrets/dc1-client-consul-2.pem.age;
    mode = "700";
    owner = "consul";
    group = "consul";
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
      # this is an anti-pattern but I don't know how else to get the gossip encryption key in here
      # since it doesn't support reading in from a file
      encrypt = builtins.readFile config.age.secrets.gossipEncryptionKey.path;
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
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
