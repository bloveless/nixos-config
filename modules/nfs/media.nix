{ config, pkgs, ... }:

{
	services.rpcbind.enable = true; # Needed for NFS

	environment.systemPackages = with pkgs; [
		pkgs.nfs-utils
	];

	systemd.mounts = let commonMountOptions = {
		type = "nfs";
		mountConfig = {
			Options = "noatime"; # ,rw,sync,hard,nfsvers=4.1";
		};
	}; in [
		(commonMountOptions // {
			what = "192.168.4.245:/volume1/k8s/media-server/plex/data/library";
			where = "/mnt/media";
		})
	];

	systemd.automounts = let commonAutoMountOptions = {
		wantedBy = [ "multi-user.target" ];
		automountConfig = {
			TimeoutIdleSec = "600";
		};
	}; in [
		(commonAutoMountOptions // { where = "/mnt/media"; })
	];
}