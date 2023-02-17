{ stdenv, pkgs, fetchFromGitHub, go, ... }:

let
  # Set the version of the Cloudflare module to include
  cloudflare_version = "latest";
in

stdenv.mkDerivation rec {
  name = "caddy-${version}-with-cloudflare-${cloudflare_version}";

  src = fetchFromGitHub {
    owner = "caddyserver";
    repo = "caddy";
    rev = "v2.6.4";
    sha256 = "3a3+nFHmGONvL/TyQRqgJtrSDIn0zdGy9YwhZP17mU0=";
  };

  buildInputs = [ go ];

  # Build Caddy with the Cloudflare module
  buildPhase = ''
    export GOPATH=$PWD/.gopath
    export GOBIN=$PWD/bin

    mkdir -p $GOPATH/src/github.com/caddyserver
    ln -s $src $GOPATH/src/github.com/caddyserver/caddy

    cd $GOPATH/src/github.com/caddyserver/caddy/cmd/caddy
    go build -o bin/caddy cmd/caddy/main.go
  '';

  # Install Caddy
  installPhase = ''
    mkdir -p $out/bin
    cp bin/caddy $out/bin/
  '';
}

