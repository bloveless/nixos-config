{ config, pkgs, ... }:

{
  imports = [ ./base.nix ];

  services.k3s = {
    role = "server";
    disableAgent = true;
    clusterInit = true;
  };
}
