{ lib
, buildGoModule
, fetchFromGitHub
, nixosTests
, caddy
, testers
, installShellFiles
}:
let
  version = "2.6.4";
  cloudflare_commit = "ed330a80c094fe73a59b5d8abc2624222550cc7e";
  dist = fetchFromGitHub {
    owner = "caddyserver";
    repo = "dist";
    rev = "v${version}";
    hash = "sha256-SJO1q4g9uyyky9ZYSiqXJgNIvyxT5RjrpYd20YDx8ec=";
  };
  main = ''
    package main

    import (
    	caddycmd "github.com/caddyserver/caddy/v2/cmd"

    	// plug in Caddy modules here
    	_ "github.com/caddy-dns/cloudflare"
    	_ "github.com/caddyserver/caddy/v2/modules/standard"
    )

    func main() {
    	caddycmd.Main()
    }
  '';
in
buildGoModule {
  pname = "jbl-caddy";
  inherit version;

  src = fetchFromGitHub {
    owner = "caddyserver";
    repo = "caddy";
    rev = "v${version}";
    hash = "sha256-3a3+nFHmGONvL/TyQRqgJtrSDIn0zdGy9YwhZP17mU0=";
  };

  vendorHash = "sha256-Ak6dH9tlXI/lGf0qF7ryFDUaAPOTPOUvjoim5tjYfIc=";

  overrideModAttrs = (_: {
    preBuild = ''
      echo '${main}' > cmd/caddy/main.go
      go get github.com/caddy-dns/cloudflare@${cloudflare_commit}
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

  subPackages = [ "cmd/caddy" ];

  ldflags = [
    "-s" "-w"
    "-X github.com/caddyserver/caddy/v2.CustomVersion=${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    install -Dm644 ${dist}/init/caddy.service ${dist}/init/caddy-api.service -t $out/lib/systemd/system
    substituteInPlace $out/lib/systemd/system/caddy.service --replace "/usr/bin/caddy" "$out/bin/caddy"
    substituteInPlace $out/lib/systemd/system/caddy-api.service --replace "/usr/bin/caddy" "$out/bin/caddy"
    installShellCompletion --cmd metal \
      --bash <($out/bin/caddy completion bash) \
      --zsh <($out/bin/caddy completion zsh)
  '';

  passthru.tests = {
    inherit (nixosTests) caddy;
    version = testers.testVersion {
      command = "${caddy}/bin/caddy version";
      package = caddy;
    };
  };

  meta = with lib; {
    homepage = "https://caddyserver.com";
    description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
    license = licenses.asl20;
    maintainers = with maintainers; [ Br1ght0ne indeednotjames techknowlogick ];
  };
}
