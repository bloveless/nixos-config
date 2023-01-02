{ pkgs, ... }:

{
  users.groups.podmanager = {};
  users.users.podmanager = {
    isNormalUser = true;
    group = "podmanager";
  };
}

