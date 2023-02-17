{ stdenv, pkgs, fetchFromGitHub, go, ... }:

let
  # Set the version of Caddy to build
  version = "2.6.4";

  # Set the version of the Cloudflare module to include
  cloudflare_version = "latest";
in

stdenv.mkDerivation rec {
  name = "caddy-${version}-with-cloudflare-${cloudflare_version}";

  buildInputs = [ go ];

  # Build Caddy with the Cloudflare module
  buildPhase = ''
    export CADDY_VERSION=${version}
    ${pkgs.xcaddy}/bin/xcaddy build --with github.com/caddy-dns/cloudflare@${cloudflare_version}
  '';

  # Install Caddy
  installPhase = ''
    mkdir -p $out/bin
    cp bin/caddy $out/bin/
  '';
}

