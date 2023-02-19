{ config, lib, pkgs, ... }:
{
  networking.extraHosts = ''
    192.168.5.58\tauthelia
    192.168.5.58\tconsul
    192.168.5.58\tnomad
    192.168.5.58\tfabio
    192.168.5.58\tbrennonloveless
    192.168.5.58\tdashboard
    192.168.5.58\tfileflows
    192.168.5.58\tgrafana
    192.168.5.58\tminio-api
    192.168.5.58\tminio
    192.168.5.58\tnas
    192.168.5.58\tnotes
    192.168.5.58\tnzbget
    192.168.5.58\tomada
    192.168.5.58\topenspeedtest
    192.168.5.58\toutline
    192.168.5.58\toverseerr
    192.168.5.58\tportainer
    192.168.5.15\tpostgres
    192.168.5.58\tprometheus
    192.168.5.58\tprowlarr
    192.168.5.58\tproxmox
    192.168.5.58\tqbittorrent
    192.168.5.58\tradarr
    192.168.5.15\tredis
    192.168.5.58\tsonarr
    192.168.5.58\tspeedtest-tracker
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
