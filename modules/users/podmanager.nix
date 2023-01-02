{ pkgs, ... }:

{
  users.groups.podmanager = {};
  users.users.podmanager = {
    isNormalUser = true;
    group = "podmanager";
  };

  system.activationScripts.loginctl-enable-linger-podmanager = pkgs.lib.stringAfter [ "users" ] ''
    ${pkgs.systemd}/bin/loginctl enable-linger podmanager
  '';
}

