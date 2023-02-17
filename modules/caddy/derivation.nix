{ stdenv, pkgs, fetchFromGitHub, go, ... }:

let
  # Set the version of Caddy to build
  caddy_commit = "0db29e2ce9799f652f3d16fd5aed6e426d23bd0a"; # 2.6.4 tag

  # Set the version of the Cloudflare module to include
  cloudflare_commit = "ed330a80c094fe73a59b5d8abc2624222550cc7e"; # latest
in

stdenv.mkDerivation rec {
  name = "caddy-${caddy_commit}-with-cloudflare-${cloudflare_commit}";

  dontUnpack = true;

  buildInputs = [ go ];

  # Build Caddy with the Cloudflare module
  buildPhase = ''
    ${pkgs.xcaddy}/bin/xcaddy build --with github.com/caddyserver/caddy/v2@v2.6.4 --with github.com/caddy-dns/cloudflare@${cloudflare_commit}
  '';

  # Install Caddy
  installPhase = ''
    mkdir -p $out/bin
    cp bin/caddy $out/bin/
  '';
}

