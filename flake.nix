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
          overlays = [
            (import ./overlays/nomad.nix)
          ];
        };
      };

      defaults = {...}: {
        imports = [
          agenix.nixosModules.default
          agenix-template.nixosModules.default
          ./default.nix
          ./modules/consul/default.nix
          ./modules/nomad/default.nix
          ./modules/nfs/default.nix
        ];
      };

      nomad-c01 = {...}: {
        deployment = {
          tags = ["client"];
          targetHost = "nomad-c01";
          targetPort = 22;
          targetUser = "brennon";
          buildOnTarget = true;
        };

        imports = [
          ./machines/nomad-c01/configuration.nix
        ];
      };

      nomad-c02 = {...}: {
        deployment = {
          tags = ["client"];
          targetHost = "nomad-c02";
          targetPort = 22;
          targetUser = "brennon";
          buildOnTarget = true;
        };

        imports = [
          ./machines/nomad-c02/configuration.nix
        ];
      };

      nomad-c03 = {...}: {
        deployment = {
          tags = ["client"];
          targetHost = "nomad-c03";
          targetPort = 22;
          targetUser = "brennon";
          buildOnTarget = true;
        };

        imports = [
          ./machines/nomad-c03/configuration.nix
        ];
      };
    };
  };
}
