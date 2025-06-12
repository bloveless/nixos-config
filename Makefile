nomad-c01:
	# Impure is added so I don't have to git commit before every apply
	TMPDIR=/private/tmp nix run github:zhaofengli/colmena/v0.4.0 -- apply --on nomad-c01 --impure

nomad-c02:
	# Impure is added so I don't have to git commit before every apply
	TMPDIR=/private/tmp nix run github:zhaofengli/colmena/v0.4.0 -- apply --on nomad-c02 --impure

nomad-c03:
	# Impure is added so I don't have to git commit before every apply
	TMPDIR=/private/tmp nix run github:zhaofengli/colmena/v0.4.0 -- apply --on nomad-c03 --impure

all: commit james servers clients dnsmasq

servers: andross

clients: fox falco katt

dnsmasq: slippy peppy

commit:
	git add .
	git commit -m Deploying || true
	git push

james:
	ssh -t james 'sudo git -C /etc/nixos pull && sudo nixos-rebuild switch && sudo systemctl restart caddy'


andross:
	ssh -t andross01 'sudo git -C /etc/nixos pull && sudo nixos-rebuild switch'
	ssh -t andross02 'sudo git -C /etc/nixos pull && sudo nixos-rebuild switch'
	ssh -t andross03 'sudo git -C /etc/nixos pull && sudo nixos-rebuild switch'

fox:
	ssh -t fox 'sudo git -C /etc/nixos pull && sudo nixos-rebuild switch'

falco:
	ssh -t falco 'sudo git -C /etc/nixos pull && sudo nixos-rebuild switch'

katt:
	ssh -t katt 'sudo git -C /etc/nixos pull && sudo nixos-rebuild switch'

slippy:
	ssh -t slippy 'sudo git -C /etc/nixos pull && sudo nixos-rebuild switch'

peppy:
	ssh -t peppy 'sudo git -C /etc/nixos pull && sudo nixos-rebuild switch'

secrets:
	scp ./machines/jamesmccloud/secrets.nix james:~/secrets.nix
	ssh -t james 'sudo mv ~/secrets.nix /etc/nixos/machines/jamesmccloud/secrets.nix'

	scp ./machines/slippytoad/secrets.nix slippy:~/secrets.nix
	ssh -t slippy 'sudo mv ~/secrets.nix /etc/nixos/machines/slippytoad/secrets.nix'

	scp ./machines/peppyhare/secrets.nix peppy:~/secrets.nix
	ssh -t peppy 'sudo mv ~/secrets.nix /etc/nixos/machines/peppyhare/secrets.nix'

clean-nix:
	ssh -t andross01 'sudo nix-collect-garbage'
	ssh -t andross02 'sudo nix-collect-garbage'
	ssh -t andross03 'sudo nix-collect-garbage'
	ssh -t james 'sudo nix-collect-garbage'
	ssh -t fox 'sudo nix-collect-garbage'
	ssh -t falco 'sudo nix-collect-garbage'
	ssh -t katt 'sudo nix-collect-garbage'
	ssh -t slippy 'sudo nix-collect-garbage'
	ssh -t peppy 'sudo nix-collect-garbage'

upgrade-nix: clean-nix
	ssh -t andross01 'sudo nixos-rebuild switch --upgrade'
	ssh -t andross02 'sudo nixos-rebuild switch --upgrade'
	ssh -t andross03 'sudo nixos-rebuild switch --upgrade'
	ssh -t james 'sudo nixos-rebuild switch --upgrade'
	ssh -t fox 'sudo nixos-rebuild switch --upgrade'
	ssh -t falco 'sudo nixos-rebuild switch --upgrade'
	ssh -t katt 'sudo nixos-rebuild switch --upgrade'
	ssh -t slippy 'sudo nixos-rebuild switch --upgrade'
	ssh -t peppy 'sudo nixos-rebuild switch --upgrade'

reset-k3s:
	ssh -t andross01 'sudo systemctl stop k3s && sudo rm -rf /var/lib/rancher'
	ssh -t andross02 'sudo systemctl stop k3s && sudo rm -rf /var/lib/rancher'
	ssh -t andross03 'sudo systemctl stop k3s && sudo rm -rf /var/lib/rancher'
	ssh -t fox 'sudo systemctl stop k3s && sudo rm -rf /var/lib/rancher'
	ssh -t falco 'sudo systemctl stop k3s && sudo rm -rf /var/lib/rancher'
	ssh -t katt 'sudo systemctl stop k3s && sudo rm -rf /var/lib/rancher'


reboot:
	ssh -t andross01 'sudo reboot' || true
	ssh -t andross02 'sudo reboot' || true
	ssh -t andross03 'sudo reboot' || true
	ssh -t fox 'sudo reboot' || true
	ssh -t falco 'sudo reboot' || true
	ssh -t katt 'sudo reboot' || true
