{ lib, fetchFromGitHub, buildGoModule, nixosTests }:

buildGoModule rec {
  pname = "cni-plugins";
  version = "1.2.0";
  CGO_ENABLED = false;

  src = fetchFromGitHub {
    owner = "containernetworking";
    repo = "plugins";
    rev = "v${version}";
    sha256 = "sha256-p6gvXn8v7KZMiCPj2EQlk/2au1nZ6EJlLxcMZHzlEp8=";
  };

  deleteVendor = true;
  vendorSha256 = "sha256-OaNcVBiz1kWEs4JEKz7LuLbBSt4gB2CP2lF0zjCBNgI=";

  doCheck = false;

  ldflags = [
    "-X github.com/containernetworking/plugins/pkg/utils/buildversion.BuildVersion=v${version}"
  ];

  subPackages = [
    "plugins/ipam/dhcp"
    "plugins/ipam/host-local"
    "plugins/ipam/static"
    "plugins/main/bridge"
    "plugins/main/host-device"
    "plugins/main/ipvlan"
    "plugins/main/loopback"
    "plugins/main/macvlan"
    "plugins/main/ptp"
    "plugins/main/vlan"
    "plugins/meta/bandwidth"
    "plugins/meta/firewall"
    "plugins/meta/portmap"
    "plugins/meta/sbr"
    "plugins/meta/tuning"
    "plugins/meta/vrf"
  ];

  passthru.tests = { inherit (nixosTests) cri-o podman; };

  meta = with lib; {
    description = "Some standard networking plugins, maintained by the CNI team";
    homepage = "https://www.cni.dev/plugins/";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ cstrahan ] ++ teams.podman.members;
  };
}
