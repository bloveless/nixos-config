{...}: {
  ## Install system packages:
  environment.systemPackages = [];
  ## Enable `neovim` program:
  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.brennon = {
    isNormalUser = true;
    description = "Brennon Loveless";
    extraGroups = ["networkmanager" "wheel"];
    packages = [];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINf6kijsnbx9rJOtxu6pNUgnZOBNK+GqSIHaZEo3IT8Q brennon@Brennons-MacBook-Pro.local"
    ];
  };
  security.sudo.extraRules = [
    {
      users = ["brennon"];
      commands = [
        {
          command = "ALL";
          options = ["SETENV" "NOPASSWD"];
        }
      ];
    }
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
