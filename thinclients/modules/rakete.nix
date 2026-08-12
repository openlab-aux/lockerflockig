# modules/rakete.nix

{ pkgs, lib, ... }:

let
  urlB64 = "aHR0cHM6Ly9kcml2ZS51c2VyY29udGVudC5nb29nbGUuY29tL2Rvd25sb2FkP2lkPTFyVlE4RDZ2ZXA5Q0xUeHhKNGlhdzZQbEhRVVVpUHFNeiZleHBvcnQ9ZG93bmxvYWQmYXV0aHVzZXI9MCZjb25maXJtPXQmdXVpZD1iMTUyNDBjYi01MmMwLTQzNDktYTkwMS00ZTU3MGEzZWUwZTAmYXQ9QUZZTHo0Tkl0bXVQSlNZRzhOSnhmcDZtY1k5OSUzQTE3ODY0Nzg1NzU0Njc=";

  installPath = "/home/openlab/rakete";

  switchToWorkspace2 = pkgs.writeShellScript "switch-workspace-2" ''
    hour=$(date +%H)

    if [ "$hour" -ge 22 ] || [ "$hour" -lt 8 ]; then
      ${pkgs.libnotify}/bin/notify-send \
        "Rakete" \
        "nicht verfügbar zwischen 22 und 8 Uhr, wegen Lärmschutz"
    else
      ${pkgs.sway}/bin/swaymsg workspace 2
    fi
  '';

  mirrorExternal = pkgs.writeShellScript "rakete-mirror-external" ''
    set -u

    # If a previous mirror instance survived a display reconnect,
    # terminate it before starting a new one.
    ${pkgs.procps}/bin/pkill -x wl-mirror 2>/dev/null || true

    # Give Sway a moment to finish applying the newly connected output.
    ${pkgs.coreutils}/bin/sleep 0.5

    # Mirror the internal laptop display onto the external HDMI output.
    exec ${pkgs.wl-mirror}/bin/wl-mirror \
      --fullscreen-output HDMI-A-1 \
      eDP-1
  '';
in
{
  environment.systemPackages = with pkgs; [
    wl-clipboard
    mako
    wl-mirror
    kanshi
    pkgs.libnotify
  ];

  services.gnome.gnome-keyring.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  security.polkit.enable = true;

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    alsa-lib
    libGL
    libX11
    libXcursor
    libXrandr
    libXi
    libXext
    systemd
    stdenv.cc.cc.lib
  ];

  networking.networkmanager = {
    enable = true;

    ensureProfiles.profiles = {
      "Labor 2.0" = {
        connection = {
          id = "Labor 2.0";
          type = "wifi";
        };

        wifi = {
          mode = "infrastructure";
          ssid = "Labor 2.0";
        };

        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "nerdhoehle2";
        };
      };
    };
  };

  systemd.services.rakete-install = {
    description = "Download and install rakete game files";

    wantedBy = [ "multi-user.target" ];

    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    unitConfig.ConditionPathExists = "!${installPath}/rakete";

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
    };

    path = with pkgs; [
      curl
      unzip
      coreutils
    ];

    script = ''
      set -euo pipefail

      url=$(echo "${urlB64}" | base64 -d)

      tmpdir=$(mktemp -d)
      trap 'rm -rf "$tmpdir"' EXIT

      curl -L --fail \
        -o "$tmpdir/rakete.zip" \
        "$url"

      mkdir -p "${installPath}"

      unzip -q \
        "$tmpdir/rakete.zip" \
        -d "${installPath}"

      chmod +x "${installPath}/rakete"

      chown -R openlab:openlab "${installPath}"
    '';
  };

  home-manager.users.openlab =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      home.packages = [
        pkgs.wmenu
      ];

      services.mako = {
        enable = true;

        output = "eDP-1";

        settings = {
          anchor = "center";
          width = 600;
          height = 300;

          font = "sans-serif 28";

          border-size = 4;
          border-color = "#ffffffff";
          border-radius = 12;

          background-color = "#1e1e2eee";
          text-color = "#ffffffff";

          default-timeout = 6000;
          ignore-timeout = 0;

          format = "<b>%s</b>\\n%b";
          markup = 1;
        };
      };

      services.kanshi = {
        enable = true;

        profiles = {
          mirror = {
            name = "mirror";

            outputs = [
              {
                criteria = "eDP-1";
                status = "enable";
              }

              {
                criteria = "HDMI-A-1";
                status = "enable";
              }
            ];

            exec = "${mirrorExternal}";
          };
        };
      };

      wayland.windowManager.sway = {
        enable = true;

        config = {
          modifier = "Mod4";

          startup = [
            {
              command = "${pkgs.firefox}/bin/firefox --kiosk http://infopanel2.lab.weltraumpflege.org/";
            }

            {
              command = "swaymsg 'workspace 2; exec /home/openlab/rakete/rakete --exhibition'";
            }

            {
              command = "swaymsg 'workspace 1'";
            }
          ];

          assigns = {
            "1" = [
              {
                app_id = "firefox";
              }
            ];

            "2" = [
              {
                app_id = "rakete";
              }
            ];
          };

          workspaceOutputAssign = [
            {
              workspace = "1";
              output = "eDP-1";
            }

            {
              workspace = "2";
              output = "eDP-1";
            }
          ];

          keybindings = lib.mkOptionDefault {
            "${config.wayland.windowManager.sway.config.modifier}+1" = "workspace 1";

            "${config.wayland.windowManager.sway.config.modifier}+2" = "exec ${switchToWorkspace2}";

            "${config.wayland.windowManager.sway.config.modifier}+Return" = "exec ${pkgs.foot}/bin/foot";

            "${config.wayland.windowManager.sway.config.modifier}+Shift+q" = "kill";

            "${config.wayland.windowManager.sway.config.modifier}+d" = "exec ${pkgs.wmenu}/bin/wmenu-run";
          };
        };
      };

      home.stateVersion = "26.05";
    };

  services.getty = {
    autologinUser = "openlab";
    autologinOnce = true;
  };

  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && sway
  '';
}
