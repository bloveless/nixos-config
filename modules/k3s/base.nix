{ config, pkgs, ... }:

let
  k3s_1_26= pkgs.callPackage ./k3s/1_26/default.nix {};
in {
  environment.systemPackages = [
    k3s_1_26
  ];
}
