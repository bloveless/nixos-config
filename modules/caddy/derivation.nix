{ stdenv, pkgs, fetchFromGitHub, go, ... }:

let
  # Set the version of Caddy to build
  version = "2.6.4";

  # Set the version of the Cloudflare module to include
  cloudflare_version = "latest";
in

stdenv.mkDerivation rec {
  name = "caddy-${version}-with-cloudflare-${cloudflare_version}";

  dontUnpack = true;

  # src = fetchFromGitHub {
  #   owner = "caddyserver";
  #   repo = "caddy";
  #   rev = "v${version}";
  #   sha256 = "3a3+nFHmGONvL/TyQRqgJtrSDIn0zdGy9YwhZP17mU0=";
  # };

  buildInputs = [ go ];

  # Build Caddy with the Cloudflare module
  buildPhase = ''
    ${pkgs.xcaddy}/bin/xcaddy build v2.6.4 --with github.com/caddy-dns/cloudflare@${cloudflare_version}
  '';

  # Install Caddy
  installPhase = ''
    mkdir -p $out/bin
    cp bin/caddy $out/bin/
  '';
}

