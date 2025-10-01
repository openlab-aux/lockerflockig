{
  config,
  pkgs,
  mqttBridgeAddress,
  ...
}:
{
  services.mosquitto = {
    enable = true;
    bridges.tor = {
      addresses = [
        {
          address = "127.0.0.1";
          port = 18830;
        }
      ];
      topics = [
        "# both 2"
      ];
    };
  };

  services.tor = {
    enable = true;
    relay.onionServices.mqtt = {
      version = 3;
      map = [
        {
          port = 1883;
          target = {
            addr = "[::1]";
            port = 1883;
          };
        }
      ];
    };
    client.enable = true;
    torsocks.enable = true;
  };

  networking.firewall.allowedTCPPorts = [ 1883 ];

  systemd.services.mqtt-tor-proxy = {
    description = "MQTT Tor proxy via socat";
    after = [ "tor.service" ];
    wants = [ "tor.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:18830,reuseaddr,fork SOCKS5:127.0.0.1:${mqttBridgeAddress}:1883,socksport=9050";
      Restart = "always";
      User = "nobody";
    };
  };
}
