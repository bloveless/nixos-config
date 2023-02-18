{ lib, buildGo119Module, fetchFromGitHub, nixosTests, plugins ? [ ], pkgs }:
let
  version = "2.5.1";
  dist = fetchFromGitHub {
    owner = "caddyserver";
    repo = "dist";
    rev = "v${version}";
    sha256 = "sha256:1nlphjg5wh5drpwkm4cczrkxdzbv72ll7hp5x7z6ww8pzz3q10b3";
  };
  imports = lib.flip lib.concatMapStrings plugins (pkg: "	_ \"${pkg}\"\n");
  main = ''
    package main

    import (
    	caddycmd "github.com/caddyserver/caddy/v2/cmd"
    	_ "github.com/caddyserver/caddy/v2/modules/standard"
    ${imports}
    )

    func main() {
    	caddycmd.Main()
    }
  '';
in buildGo119Module {
  pname = "caddy";
  inherit version;
  runVend = true;

  subPackages = [ "cmd/caddy" ];

  src = fetchFromGitHub {
    owner = "caddyserver";
    repo = "caddy";
    rev = "v${version}";
    sha256 = "sha256:1nlphjg5wh5drpwkm4cczrkxdzbv72ll7hp5x7z6ww8pzz3q10b3";
  };

  vendorSha256 = "sha256-s3vfTOdjIEs9ds9EtDbBpmTwPbkDkNohacUtrReZ050=";

  nativeBuildInputs = [ pkgs.breakpointHook ];

  overrideModAttrs = (_: {
    preBuild = ''
      echo '${main}' > cmd/caddy/main.go
      go get github.com/caddy-dns/cloudflare
    '';
    postInstall = "cp go.sum go.mod $out/ && ls $out/";
  });

  postPatch = ''
    echo '${main}' > cmd/caddy/main.go
    cat cmd/caddy/main.go
  '';

  postConfigure = ''
    cp vendor/go.sum ./
    cp vendor/go.mod ./
  '';

  postInstall = ''
    install -Dm644 ${dist}/init/caddy.service ${dist}/init/caddy-api.service -t $out/lib/systemd/system

    substituteInPlace $out/lib/systemd/system/caddy.service --replace "/usr/bin/caddy" "$out/bin/caddy"
    substituteInPlace $out/lib/systemd/system/caddy-api.service --replace "/usr/bin/caddy" "$out/bin/caddy"
  '';

  passthru.tests = { inherit (nixosTests) caddy; };

  meta = with lib; {
    homepage = "https://caddyserver.com";
    description = "Fast, cross-platform HTTP/2 web server with automatic HTTPS";
    license = licenses.asl20;
    maintainers = with maintainers; [ Br1ght0ne techknowlogick ];
  };
}
