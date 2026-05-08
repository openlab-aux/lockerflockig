{ pkgs, roomName, ... }:
{
  # debug
  environment.systemPackages = [
    pkgs.spotifyd
  ];

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        device_type = "speaker";
        device_name = roomName;

        use_mpris = false;

        backend = "pulseaudio";

        bitrate = 320;
        initial_volume = 80;
      };
    };
  };

  systemd.services.spotifyd = {
    after = [ "pipewire.service" ];
    serviceConfig = {
      RuntimeDirectory = "spotifyd";
      WorkingDirectory = "/run/spotifyd";
      SupplementaryGroups = [
        "pipewire"
      ];
    };
  };
}
