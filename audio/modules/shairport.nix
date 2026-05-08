{ pkgs, roomName, ... }:
{
  environment.systemPackages = [
    pkgs.shairport-sync
  ];

  services.shairport-sync = {
    enable = true;
    package = pkgs.shairport-sync;
    settings = {
      general = {
        name = roomName;
        output_backend = "pa";
      };
    };
  };

  users.users.shairport = {
    extraGroups = [
      "pipewire"
      "audio"
    ];
  };
}
