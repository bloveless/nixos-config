# Impure is added so I don't have to git commit before every apply
export TMPDIR=/private/tmp

clients:
	nix run github:zhaofengli/colmena/v0.4.0 -- apply --on @client --impure

servers:
	nix run github:zhaofengli/colmena/v0.4.0 -- apply --on @server --impure

nomad-s01:
	nix run github:zhaofengli/colmena/v0.4.0 -- apply --on nomad-s01 --impure

nomad-s02:
	nix run github:zhaofengli/colmena/v0.4.0 -- apply --on nomad-s02 --impure

nomad-s03:
	nix run github:zhaofengli/colmena/v0.4.0 -- apply --on nomad-s03 --impure

nomad-c01:
	nix run github:zhaofengli/colmena/v0.4.0 -- apply --on nomad-c01 --impure

nomad-c02:
	nix run github:zhaofengli/colmena/v0.4.0 -- apply --on nomad-c02 --impure

nomad-c03:
	nix run github:zhaofengli/colmena/v0.4.0 -- apply --on nomad-c03 --impure
