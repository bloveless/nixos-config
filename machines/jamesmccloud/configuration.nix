# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
   configFile = with import ./secrets.nix; pkgs.writeText "Caddyfile" ''
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
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	@www.brennonloveless.com host www.brennonloveless.com
	redir @www.brennonloveless.com https://brennonloveless.com{url}

	@overseerr.brennonloveless.com host overseerr.brennonloveless.com
	reverse_proxy @overseerr.brennonloveless.com http://192.168.5.17:5055
}

brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy http://192.168.5.202:9999
}

brennonloveless.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy http://192.168.5.202:9999
}

publicip.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy http://192.168.5.202:9999
}

dashboard.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy http://192.168.5.54:3000
}


code.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy http://192.168.5.106:4444
}

portainer.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy https://192.168.5.15:9443 {
		transport http {
			tls_insecure_skip_verify
		}
	}
}

proxmox.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy https://192.168.5.10:8006 {
		transport http {
			tls_insecure_skip_verify
		}
	}
}

nas.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy https://192.168.4.245:5001 {
		transport http {
			tls_insecure_skip_verify
		}
	}
}

fileflows.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy http://192.168.5.202:9999
}

notes.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy http://192.168.5.104:8080
}

authelia.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy http://192.168.5.15:9091
}

outline.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy http://192.168.5.54:3001
}

minio.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy http://192.168.4.245:9001
}

minio-api.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy http://192.168.4.245:9000
}

speedtest-tracker.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy https://192.168.5.104:8443 {
		transport http {
			tls_insecure_skip_verify
		}
	}
}

openspeedtest.lan.brennonloveless.com {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy http://192.168.5.104:3000
}

omada.lan.brennonloveless.com {
	redir https://omada.lan.brennonloveless.com:8043{url} permanent
}

omada.lan.brennonloveless.com:8043 {
	tls {
		dns cloudflare  ${cloudflare.dns_api_key}
	}

	reverse_proxy http://192.168.5.202:9999
}
  '';
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/base/configuration.nix
    ../../modules/users/brennon.nix
    ../../modules/cloudflared/service.nix
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  cloudflared.token = with import ./secrets.nix; cloudflared.token;

  networking.hostName = "jamesmccloud"; # Define your hostname.
  networking.interfaces.ens18.ipv4.addresses = [ {
    address = "192.168.5.58";
    prefixLength = 22;
  } ];
  networking.nameservers = [ "192.168.5.201" ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    80 # caddy http
    443 # caddy https
    8043 # omada listens on 8043
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  services.caddy = {
    enable = true;
    package = pkgs.callPackage ../../modules/caddy/default.nix {};

    acmeCA = "https://acme-v02.api.letsencrypt.org/directory";
    email = "brennon.loveless@gmail.com";

    adapter = "caddyfile";
    configFile = configFile;
  };
}
