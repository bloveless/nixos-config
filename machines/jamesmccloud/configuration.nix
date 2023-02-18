# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
   configFile = pkgs.writeText "Caddyfile" ''
# vim: set ts=4 sw=4 tw=4 noet :
{
	debug
	email brennon.loveless@gmail.com
}

localhost {
	tls internal
	respond "Localhost"
}

:8090 {
	metrics /metrics
}

*.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	@www.brennonloveless.com host www.brennonloveless.com
	redir @www.brennonloveless.com https://brennonloveless.com{url}

	@overseerr.brennonloveless.com host overseerr.brennonloveless.com
	reverse_proxy @overseerr.brennonloveless.com http://192.168.5.17:5055
}

brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.202:9999
}

brennonloveless.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.202:9999
}

dashboard.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.54:3000
}

portainer.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy https://192.168.5.15:9443 {
		transport http {
			tls_insecure_skip_verify
		}
	}
}

proxmox.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy https://192.168.5.10:8006 {
		transport http {
			tls_insecure_skip_verify
		}
	}
}

nas.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy https://192.168.4.245:5001 {
		transport http {
			tls_insecure_skip_verify
		}
	}
}

overseerr.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.17:5055
}

radarr.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.17:7878
}

sonarr.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.17:8989
}

prowlarr.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.17:9696
}

nzbget.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.17:6789
}

qbittorrent.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.17:8080
}

fileflows.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.54:5000
}

grafana.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.105:3000
}

prometheus.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.105:9090
}

notes.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.104:8080
}

authelia.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.15:9091
}

outline.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.54:3001
}

minio.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.4.245:9001
}

minio-api.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.4.245:9000
}

speedtest-tracker.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy https://192.168.5.104:8443 {
		transport http {
			tls_insecure_skip_verify
		}
	}
}

openspeedtest.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.104:3000
}

omada.lan.brennonloveless.com {
	redir https://omada.lan.brennonloveless.com:8043{url} permanent
}

omada.lan.brennonloveless.com:8043 {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy https://192.168.5.104:8043 {
		transport http {
			tls_insecure_skip_verify
		}
	}
}


consul.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.20:8500
}

nomad.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.20:4646
}

fabio.lan.brennonloveless.com {
	tls {
		dns cloudflare  {{ cloudflare_dns_api_key }}
	}

	reverse_proxy http://192.168.5.202:9998
}
  '';
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/base/configuration.nix
    ../../modules/nfs/media.nix
    ../../modules/users/brennon.nix
  ];

  networking.hostName = "jamesmccloud"; # Define your hostname.
  networking.interfaces.ens18.ipv4.addresses = [ {
    address = "192.168.5.58";
    prefixLength = 22;
  } ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    443 # caddy https
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  environment.systemPackages = with pkgs; [
    pkgs.cntr
  ];


  services.caddy = {
    enable = true;
    package = pkgs.callPackage ../../modules/caddy/default.nix {};

    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
    email = "brennon.loveless@gmail.com";

    configFile = configFile;
  };
}
