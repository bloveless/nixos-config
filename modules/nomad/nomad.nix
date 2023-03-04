{ lib
, buildGo120Module
, fetchFromGitHub
, nixosTests
}:
let
  pname = "nomad";
  version = "1.5.0";
  sha256 = "sha256-miimuWolTJ3lMY/ArnLZFu+GZv9ADdGsriXsTcEgdYc=";
  vendorSha256 = "sha256-ttP7pzsIBd2S79AUcbOeVG71Mb5qK706rq5DkT41VqM=";

in buildGo120Module (rec {
  inherit pname version sha256 vendorSha256;

  passthru.tests.nomad = nixosTests.nomad;

  subPackages = [ "." ];

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = pname;
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
