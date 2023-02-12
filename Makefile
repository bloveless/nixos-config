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

