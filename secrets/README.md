# Secrets

## Encrypt

Define secrets in secrets.nix with public key
Make sure to include brennon in every one or they can't been seen or edited on macbook
Run `nix run github:ryantm/agenix -- -e dc1-client-consul-2-key.pem.age` to create the secret

Run `nix run github:ryantm/agenix -- -r` to rekey all the secrets
