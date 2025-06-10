{pkgs, ...}: {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.brennon = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICXm5R5aXSC+CkrF4XhlqNqdfSzXpZKaM3arSfgNXjYE brennon@Brennon-Loveless-MacBook-Pro.local"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOodGuL1ZmloOuJzeXedkN3H0LHwOcr9d45kWfnZa1VZ brennon@devbox"
    ];
  };
}
