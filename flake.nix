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
  outputs = { nixpkgs, colmena, agenix, agenix-template, ... }: {
    colmenaHive = colmena.lib.makeHive {
      meta = {
        nixpkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [];
        };
      };

      defaults = { ... }: {

        imports = [
          agenix.nixosModules.default
          agenix-template.nixosModules.default
          ((builtins.toString ./.) + "/default.nix")
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
          ((builtins.toString ./.) + "/modules/consul/default.nix")
        ];
      };
    };
  };
}
