{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.wiremix
  ];

  services.pipewire = {
    enable = true;

    systemWide = true;

    pulse.enable = true;
  };
}
