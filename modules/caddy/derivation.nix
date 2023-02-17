{ stdenv, pkgs, fetchFromGitHub, go, ... }:

let
  # Set the version of Caddy to build
  version = "2.6.4";

  # Set the version of the Cloudflare module to include
  cloudflare_version = "latest";
in

stdenv.mkDerivation rec {
  name = "caddy-${version}-with-cloudflare-${cloudflare_version}";

  src = fetchFromGitHub {
    owner = "caddyserver";
    repo = "caddy";
    rev = "v${version}";
    sha256 = "1gcbi0zrmf83v6xdj7b8vpfh2d1wyhyr04cfwvvz7m8x4lprz7xp";
  };

  buildInputs = [ go ];

  # Build Caddy with the Cloudflare module
  buildPhase = ''
    export GOPATH=$PWD/.gopath
    export GOBIN=$PWD/bin

    mkdir -p $GOPATH/src/github.com/caddyserver
    ln -s $src $GOPATH/src/github.com/caddyserver/caddy

    cd $GOPATH/src/github.com/caddyserver/caddy/cmd/caddy
    ${pkgs.xcaddy} build --with github.com/caddy-dns/cloudflare@${cloudflare_version}
  '';

  # Install Caddy
  installPhase = ''
    mkdir -p $out/bin
    cp bin/caddy $out/bin/
  '';
}

