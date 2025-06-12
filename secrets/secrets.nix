let
  brennon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINf6kijsnbx9rJOtxu6pNUgnZOBNK+GqSIHaZEo3IT8Q";
  # nomad-s01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiucWgup/mP78zyC23uFjYq0evcWdjGQUaBH";
  # nomad-s02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiucWgup/mP78zyC23uFjYq0evcWdjGQUaBH";
  # nomad-s03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiucWgup/mP78zyC23uFjYq0evcWdjGQUaBH";
  nomad-c01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGr39R7k0hXIThAjAdX3Zc/OkQqd+9cF25Xfz6ioJnR8";
  nomad-c02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE5SmrLXcQT6NhYQ7vZZkkTTMTJasjxonI9ea1939jVN";
  nomad-c03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHp/mUESS5xiJ0L1xVqhYt70M+AmWdYOA2QGQQko4Ud0";
in {
  "consul-agent-ca.pem.age".publicKeys = [brennon nomad-c01 nomad-c02 nomad-c03];
  "consul-agent-ca-key.pem.age".publicKeys = [brennon];
  "dc1-client-consul-0-key.pem.age".publicKeys = [brennon nomad-c01];
  "dc1-client-consul-0.pem.age".publicKeys = [brennon nomad-c01];
  "dc1-client-consul-1-key.pem.age".publicKeys = [brennon nomad-c02];
  "dc1-client-consul-1.pem.age".publicKeys = [brennon nomad-c02];
  "dc1-client-consul-2-key.pem.age".publicKeys = [brennon nomad-c03];
  "dc1-client-consul-2.pem.age".publicKeys = [brennon nomad-c03];
  "dc1-server-consul-0-key.pem.age".publicKeys = [brennon];
  "dc1-server-consul-0.pem.age".publicKeys = [brennon];
  "dc1-server-consul-1-key.pem.age".publicKeys = [brennon];
  "dc1-server-consul-1.pem.age".publicKeys = [brennon];
  "dc1-server-consul-2-key.pem.age".publicKeys = [brennon];
  "dc1-server-consul-2.pem.age".publicKeys = [brennon];
  "docker-auth.json.age".publicKeys = [brennon nomad-c01 nomad-c02 nomad-c03];
  "gossip-encryption-key.age".publicKeys = [brennon nomad-c01 nomad-c02 nomad-c03];
}
