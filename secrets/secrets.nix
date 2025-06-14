let
  brennon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINf6kijsnbx9rJOtxu6pNUgnZOBNK+GqSIHaZEo3IT8Q";
  nomad-c01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGr39R7k0hXIThAjAdX3Zc/OkQqd+9cF25Xfz6ioJnR8";
  nomad-c02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE5SmrLXcQT6NhYQ7vZZkkTTMTJasjxonI9ea1939jVN";
  nomad-c03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHp/mUESS5xiJ0L1xVqhYt70M+AmWdYOA2QGQQko4Ud0";
  nomad-s01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF+QwmpSWefeawZJZIAdKHCfcf6tNh7TW65leftLi6M0";
  nomad-s02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPpGDsiSUYefg7V9vVnqf/0U3tBldwe2mHyfEG4wBx8";
  nomad-s03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEeCfLUrBw8Yl1v+PkCtr7HEG7M94ZTHSFJCfe/mz7NU";
in {
  "consul-agent-ca.pem.age".publicKeys = [brennon nomad-c01 nomad-c02 nomad-c03 nomad-s01 nomad-s02 nomad-s03];
  "consul-agent-ca-key.pem.age".publicKeys = [brennon];
  "dc1-server-consul-0-key.pem.age".publicKeys = [brennon nomad-s01];
  "dc1-server-consul-0.pem.age".publicKeys = [brennon nomad-s01];
  "dc1-server-consul-1-key.pem.age".publicKeys = [brennon nomad-s02];
  "dc1-server-consul-1.pem.age".publicKeys = [brennon nomad-s02];
  "dc1-server-consul-2-key.pem.age".publicKeys = [brennon nomad-s03];
  "dc1-server-consul-2.pem.age".publicKeys = [brennon nomad-s03];
  "docker-auth.json.age".publicKeys = [brennon nomad-c01 nomad-c02 nomad-c03 nomad-s01 nomad-s02 nomad-s03];
  "gossip-encryption-key.age".publicKeys = [brennon nomad-c01 nomad-c02 nomad-c03 nomad-s01 nomad-s02 nomad-s03];
}
