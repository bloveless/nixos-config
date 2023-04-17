{ config, lib, pkgs, ... }:
{
  networking.extraHosts = ''
    192.168.6.1 	argocd
    192.168.5.58	authelia
    192.168.5.58	brennonloveless
    192.168.5.58	dashboard
    192.168.5.58	fileflows
    192.168.6.1 	grafana
    192.168.6.1 	jackett
    192.168.5.58	minio-api
    192.168.5.58	minio
    192.168.5.58	nas
    192.168.5.58	notes
    192.168.6.1 	sabnzbd
    192.168.5.58	omada
    192.168.5.58	openspeedtest
    192.168.5.58	outline
    192.168.6.1 	overseerr
    192.168.5.58	portainer
    192.168.5.15	postgres
    192.168.6.1 	prometheus
    192.168.6.1 	prowlarr
    192.168.5.58	proxmox
    192.168.5.58	publicip
    192.168.6.1 	qbittorrent
    192.168.6.1 	radarr
    192.168.5.15	redis
    192.168.6.1 	sonarr
    192.168.5.58	speedtest-tracker
  '';

  services.dnsmasq = {
    enable = true;
    alwaysKeepRunning = true;
    resolveLocalQueries = true;
    servers = [ "1.1.1.1" "1.0.0.1" ];
    extraConfig = ''
      interface=ens18
      bind-dynamic

      # never forward addresses in the non-routed address spaces
      domain-needed

      # query with each server strictly in the order in resolv.conf
      bogus-priv
          
      # query with each server strictly in the order in [resolv.conf]
      strict-order

      # add domain name automatically to hostnames
      expand-hosts

      # add internal domain
      domain=lan.brennonloveless.com
    '';
  };
}
