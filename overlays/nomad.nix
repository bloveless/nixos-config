(final: prev: {
  nomad = prev.buildGo124Module (finalAttrs: {
    pname = "nomad";
    version = "1.10.1";
    vendorHash = "sha256-ZBCwZFrCauT0y/cMhrZow2I0fgbl4JrIEIjmtm/zVd4";

    subPackages = ["."];

    src = prev.fetchFromGitHub {
      owner = "hashicorp";
      repo = finalAttrs.pname;
      rev = "v${finalAttrs.version}";
      sha256 = "sha256-fHLtLp2K0BPmN9SYL6xHay9h4zHsGAE8bqboID3J0HE=";
    };

    nativeBuildInputs = [prev.installShellFiles];

    ldflags = [
      "-X github.com/hashicorp/nomad/version.Version=${finalAttrs.version}"
      "-X github.com/hashicorp/nomad/version.VersionPrerelease="
      "-X github.com/hashicorp/nomad/version.BuildDate=1970-01-01T00:00:00Z"
    ];

    # ui:
    #  Nomad release commits include the compiled version of the UI, but the file
    #  is only included if we build with the ui tag.
    tags = ["ui"];

    postInstall = ''
      echo "complete -C $out/bin/nomad nomad" > nomad.bash
      installShellCompletion nomad.bash
    '';

    meta = {
      homepage = "https://www.nomadproject.io/";
      description = "Distributed, Highly Available, Datacenter-Aware Scheduler";
      mainProgram = "nomad";
      license = "bsl11";
      maintainers = [];
    };
  });
})
