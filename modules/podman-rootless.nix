{ lib, pkgs, config, ... }:
with lib;
let
	cfg = config.services.podman-rootless;
in {
	options.services.podman-rootless = {
		enable = mkOption {
			type = types.bool;
			default = false;
			description = ''
				Create one or many rootless podman containers.
			'';
		};

		containers = mkOption {
			type = types.attrsOf(types.submodule {
				options = {
					podName = mkOption {
						type = types.str;
					};
					description = mkOption {
						type = types.str;
						default = "Rootless podman container";
					};
					imageName = mkOption {
						type = types.str;
					};
					imageTag = mkOption {
						type = types.str;
					};
					extraConfigs = mkOption {
						type = types.listOf(types.str);
					};
				};
			});
			default = {};
			description = ''
				Definition of containers.
			'';
		};
	};

	config = mkIf cfg.enable {
		systemd.services = mapAttrs' (name: value: nameValuePair("podman-${name}") ({
			enable = true;
			wantedBy = [ "default.target" ];
			after = [ "network.target" ];
			description = value.description;
			serviceConfig =
				let
					podmancli = "${pkgs.bash}/bin/bash -l -c \"${config.virtualisation.podman.package}/bin/podman";
					endpodmancli = "\"";
					image = "${value.imageName}:${value.imageTag}";
					podname = value.podName;
					cleanup_pod = [
						"${podmancli} stop -i ${podname} ${endpodmancli}"
						"${podmancli} rm -i ${podname} ${endpodmancli}"
					];
				in {
					User = "podmanager";
					WorkingDirectory = "/home/podmanager";
					ExecStartPre = cleanup_pod;
					ExecStart = "${podmancli} run " +
						"--rm " +
						"--name=${podname} " +
						"--log-driver=journald " +
						concatStringsSep " " value.extraConfigs +
						" ${image} ${endpodmancli}";

					ExecStop = "${podmancli} stop ${podname} ${endpodmancli}";
					ExecStopPost = cleanup_pod;
					Restart = "always";
					TimeoutStopSec = 15;
				};
		})) cfg.containers;
	};
}
