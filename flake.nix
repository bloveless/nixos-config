{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    colmena.url = "github:zhaofengli/colmena/v0.4.0";
    # Add agenix input
    agenix = {
      url = "github:ryantm/agenix/0.15.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, colmena, agenix, ... }: {
    colmenaHive = colmena.lib.makeHive {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [];
        };
      };

      defaults = { config, pkgs, ... }: {
        ## Install system packages:
        environment.systemPackages = [];
        ## Enable `neovim` program:
        programs.neovim = {
          enable = true;
          vimAlias = true;
          defaultEditor = true;
        };
        imports = [
          agenix.nixosModules.default
        ];
      };

      nomad-c03 = { name, nodes, pkgs, ... }: {
        deployment = {
          targetHost = "nomad-c03";
          targetPort = 22;
          targetUser = "brennon";
          buildOnTarget = true;
        };
        time.timeZone = "America/Los_Angeles";

        imports = [
          ((builtins.toString ./.) + "/machines/nomad-c03/configuration.nix")
        ];
      };
    };
  };
}
