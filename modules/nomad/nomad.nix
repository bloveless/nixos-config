{ lib
, buildGo120Module
, fetchFromGitHub
, nixosTests
}:
let
  pname = "nomad";
  version = "1.5.0";
  sha256 = "sha256-xaMt57g2TV+LG5NRmIvKqg/Ljf2BFcHayuxC+Fz/9Ys=";
  vendorSha256 = "sha256-qU1gpN9T3b+onWgs2lJ01Wc0zzWwyndbvoja6fZsXFE=";

in buildGo120Module (rec {
  inherit pname version sha256 vendorSha256;

  subPackages = [ "." ];
  doCheck = false;

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "nomad";
    rev = "v${version}";
    inherit sha256;
  };

  # ui:
  #  Nomad release commits include the compiled version of the UI, but the file
  #  is only included if we build with the ui tag.
  tags = [ "ui" ];

  meta = with lib; {
    homepage = "https://www.nomadproject.io/";
    description = "A Distributed, Highly Available, Datacenter-Aware Scheduler";
    platforms = platforms.unix;
    license = licenses.mpl20;
    maintainers = with maintainers; [ rushmorem pradeepchhetri endocrimes maxeaubrey techknowlogick ];
  };
})
