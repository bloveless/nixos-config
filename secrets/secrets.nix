let
  brennon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINf6kijsnbx9rJOtxu6pNUgnZOBNK+GqSIHaZEo3IT8Q";
  # nomad-s01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiucWgup/mP78zyC23uFjYq0evcWdjGQUaBH";
  # nomad-s02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiucWgup/mP78zyC23uFjYq0evcWdjGQUaBH";
  # nomad-s03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiucWgup/mP78zyC23uFjYq0evcWdjGQUaBH";
  # nomad-c01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiucWgup/mP78zyC23uFjYq0evcWdjGQUaBH";
  # nomad-c02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiucWgup/mP78zyC23uFjYq0evcWdjGQUaBH";
  nomad-c03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHp/mUESS5xiJ0L1xVqhYt70M+AmWdYOA2QGQQko4Ud0";
in {
  "gossip-encryption-key.age".publicKeys = [brennon nomad-c03];
  "consul-agent-ca.pem.age".publicKeys = [brennon nomad-c03];
  "dc1-client-consul-2-key.pem.age".publicKeys = [brennon nomad-c03];
  "dc1-client-consul-2.pem.age".publicKeys = [brennon nomad-c03];
  "docker-auth.json.age".publicKeys = [brennon nomad-c03];
}
