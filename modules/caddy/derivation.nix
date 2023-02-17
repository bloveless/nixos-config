{ stdenv, pkgs, fetchFromGitHub, go, ... }:

let
  # Set the version of Caddy to build
  caddy_commit = "0db29e2ce9799f652f3d16fd5aed6e426d23bd0a"; # 2.6.4 tag

  # Set the version of the Cloudflare module to include
  cloudflare_version = "latest";
in

stdenv.mkDerivation rec {
  name = "caddy-${version}-with-cloudflare-${cloudflare_version}";

  dontUnpack = true;

  buildInputs = [ go ];

  # Build Caddy with the Cloudflare module
  buildPhase = ''
    ${pkgs.xcaddy}/bin/xcaddy build --with github.com/caddyserver/caddy/v2=github.com/caddyserver/caddy@${caddy_commit} --with github.com/caddy-dns/cloudflare@${cloudflare_version}
  '';

  # Install Caddy
  installPhase = ''
    mkdir -p $out/bin
    cp bin/caddy $out/bin/
  '';
}

