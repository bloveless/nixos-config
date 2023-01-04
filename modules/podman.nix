{ lib, pkgs, config, ... }:
with lib;
let
	cfg = config.services.rootless-podman;
in {
	options.services.rootless-podman = {
		enable = mkOption {
			types = types.bool;
			default = false;
			description = ''
				Create one or many rootless podman containers.
			'';
		}


		containers = mkOption {
			type = types.submodule {
				options = {
					podName = mkOption {
						type = types.str;
					};
					description = mkOption {
						types = types.str
						default = "Rootless podman container";
					};
					imageName = mkOption {
						type = types.str;
					};
					imageTag = mkOption {
						type = types.str;
					};
					extraConfig = mkOption {
						type = types.str;
					}
				};
			};
			default = {};
			description = ''
				Definition of containers.
			'';
		}
	};

	config = mkIf cfg.Enable {
		mapAttrs (name: value: nameValuePair(systemd.services."podman-${name}") ({
			enable = true;
			wantedBy = [ "default.target" ];
			after = [ "network.target" ];
			description = value.description;
			serviceConfig =
				let {
					podmancli = "${pkgs.bash}/bin/bash -l -c \"${config.virtualisation.podman.package}/bin/podman";
					endpodmancli = "\"";
					image = "${value.imageName}:${value.imageTag}";
					podname = value.podName;
					cleanup_pod = [
						"${podmancli} stop -i ${podname} ${endpodmancli}"
						"${podmancli} rm -i ${podname} ${endpodmancli}"
					];
				} in {
					User = "podmanager";
					WorkingDirectory = "/home/podmanager";
					ExecStartPre = cleanup_pod;
					ExecStart = "${podmancli} run " +
						"--rm " +
						"--name=${podname} " +
						"--log-driver=journald " +
						"-p '0.0.0.0:8080:80' " +
						"${image} ${endpodmancli}";

					ExecStop = "${podmancli} stop ${podname} ${endpodmancli}";
					ExecStopPost = cleanup_pod;
					Restart = "always";
					TimeoutStopSec = 15;
				};
		})) { cfg.containers };
	};
}
