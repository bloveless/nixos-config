{ pkgs, ... }:

{
  users.users.podmanager = {
    isNormalUser = true;
    group = "podmanager";
  };
}

