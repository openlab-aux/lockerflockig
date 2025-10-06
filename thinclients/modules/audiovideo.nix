{ pkgs, lib, ... }:
{
  environment.etc."xdg/weston/weston.ini".text =
    let
      wrapper = pkgs.writeShellScriptBin "firefox-wrapper.sh" ''
        exec ${pkgs.firefox}/bin/firefox --kiosk http://infopanel2.lab.weltraumpflege.org/
      '';
    in
    ''
      [shell]
      locking = false
      allow-zap = false
    '';

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sessionPackages = with pkgs; [ westonLite ];

  services.displayManager.autoLogin = {
    enable = true;
    user = "openlab";
  };

  environment.systemPackages = [
    pkgs.firefox
    pkgs.westonLite
    pkgs.pavucontrol
  ];

  services.pipewire = {
    enable = false;
  };

  services.pulseaudio = {
    enable = true;
    systemWide = true;
    package = pkgs.pulseaudioFull;
    zeroconf.publish.enable = true;
    tcp.enable = true;
    tcp.anonymousClients.allowAll = true;
  };

  users.users.openlab = {
    extraGroups = [ "pulse-access" ];
  };

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        backend = "pulseaudio";
        device_name = "openlab";
        device_type = "speaker";
        cache_path = "/var/cache/spotifyd";
        use_mpris = false;
      };
    };
  };
  systemd.services.spotifyd = {
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "openlab";
      SupplementaryGroups = [ "pulse-access" ];
    };
  };

  networking.firewall.enable = false;

  services.squeezelite = {
    enable = true;
    pulseAudio = true;
  };
  systemd.services.squeezelite = {
    environment = {
      HOME = "/var/lib/squeezelite";
    };
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "openlab";
    };
  };
}
