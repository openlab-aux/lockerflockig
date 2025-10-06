{ pkgs, ...}: {
  environment.etc."xdg/weston/weston.ini".text = let 
    wrapper = pkgs.writeShellScriptBin "firefox-wrapper.sh" ''
      exec ${pkgs.firefox}/bin/firefox --kiosk http://infopanel2.lab.weltraumpflege.org/
    '';
  in ''
    [output]
    name = "VGA1"
    mode = "1920x1080"

    [shell]
    locking = false
    allow-zap = false

    [autolaunch]
    path=${wrapper}/bin/firefox-wrapper.sh
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
  ];
}