{ config, pkgs, ... }:
{
  services.mosquitto.enable = true;

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
  };
}
