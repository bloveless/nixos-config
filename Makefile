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
	scp ./machines/andross01/secrets.nix andross01:~/secrets.nix
	ssh -t andross01 'sudo mv ~/secrets.nix /etc/nixos/machines/andross01/secrets.nix'
	
	scp ./machines/andross02/secrets.nix andross02:~/secrets.nix
	ssh -t andross02 'sudo mv ~/secrets.nix /etc/nixos/machines/andross02/secrets.nix'
	
	scp ./machines/andross03/secrets.nix andross03:~/secrets.nix
	ssh -t andross03 'sudo mv ~/secrets.nix /etc/nixos/machines/andross03/secrets.nix'
	
	scp ./machines/jamesmccloud/secrets.nix james:~/secrets.nix
	ssh -t james 'sudo mv ~/secrets.nix /etc/nixos/machines/jamesmccloud/secrets.nix'
	
	scp ./machines/foxmccloud/secrets.nix fox:~/secrets.nix
	ssh -t fox 'sudo mv ~/secrets.nix /etc/nixos/machines/foxmccloud/secrets.nix'
	
	scp ./machines/falcolombardi/secrets.nix falco:~/secrets.nix
	ssh -t falco 'sudo mv ~/secrets.nix /etc/nixos/machines/falcolombardi/secrets.nix'
	
	scp ./machines/kattmonroe/secrets.nix katt:~/secrets.nix
	ssh -t katt 'sudo mv ~/secrets.nix /etc/nixos/machines/kattmonroe/secrets.nix'
	
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
