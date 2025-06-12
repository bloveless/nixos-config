# Impure is added so I don't have to git commit before every apply
clients:
	TMPDIR=/private/tmp nix run github:zhaofengli/colmena/v0.4.0 -- apply --on @client --impure

nomad-c01:
	TMPDIR=/private/tmp nix run github:zhaofengli/colmena/v0.4.0 -- apply --on nomad-c01 --impure

nomad-c02:
	TMPDIR=/private/tmp nix run github:zhaofengli/colmena/v0.4.0 -- apply --on nomad-c02 --impure

nomad-c03:
	TMPDIR=/private/tmp nix run github:zhaofengli/colmena/v0.4.0 -- apply --on nomad-c03 --impure
