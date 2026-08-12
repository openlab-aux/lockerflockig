# modules/rakete.nix

{ pkgs, lib, ... }:

let
  urlB64 =
    "...";

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

  moveWorkspacesToInternal = pkgs.writeShellScript "rakete-workspaces-internal" ''
    set -eu

    ${pkgs.sway}/bin/swaymsg \
      "workspace 1, move workspace to output eDP-1"

    ${pkgs.sway}/bin/swaymsg \
      "workspace 2, move workspace to output eDP-1"
  '';

  moveWorkspacesToExternal = pkgs.writeShellScript "rakete-workspaces-external" ''
    set -eu

    ${pkgs.sway}/bin/swaymsg \
      "workspace 1, move workspace to output HDMI-A-1"

    ${pkgs.sway}/bin/swaymsg \
      "workspace 2, move workspace to output HDMI-A-1"

    ${pkgs.sway}/bin/swaymsg workspace 2
  '';
in
{
  environment.systemPackages = with pkgs; [
    wl-clipboard
    mako
    kanshi
    libnotify
    procps
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

  # NetworkManager manages both Ethernet and Wi-Fi.
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

  # Keep running when the laptop lid is closed.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  systemd.services.rakete-install = {
    description = "Download and install rakete game files";

    wantedBy = [
      "multi-user.target"
    ];

    after = [
      "network-online.target"
    ];

    wants = [
      "network-online.target"
    ];

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

          default-timeout = 10000;
          ignore-timeout = 1;
          max-visible = 1;

          format = "<b>%s</b>\\n%b";
          markup = 1;
        };
      };

      services.kanshi = {
        enable = true;

        profiles = {
          external = {
            name = "external";

            outputs = [
              {
                criteria = "eDP-1";
                status = "disable";
              }

              {
                criteria = "HDMI-A-1";
                status = "enable";
              }
            ];

            exec = "${moveWorkspacesToExternal}";
          };

          internal = {
            name = "internal";

            outputs = [
              {
                criteria = "eDP-1";
                status = "enable";
              }
            ];

            exec = "${moveWorkspacesToInternal}";
          };
        };
      };

      wayland.windowManager.sway = {
        enable = true;

        wrapperFeatures = {
          base = true;
          gtk = true;
        };

        systemd.variables = [
          "--all"
        ];

        config = {
          modifier = "Mod4";

          terminal = "${pkgs.foot}/bin/foot";

          startup = [
            {
              command =
                "${pkgs.firefox}/bin/firefox --new-window http://infopanel2.lab.weltraumpflege.org/";
            }

            {
              command =
                "${pkgs.sway}/bin/swaymsg workspace 2 && sleep 1 && ${installPath}/rakete --exhibition";
            }
          ];

          window = {
            titlebar = false;
            border = 0;
          };

          window.commands = [
            {
              criteria = {
                app_id = "firefox";
              };

              command = "fullscreen enable";
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
                class = "rakete";
              }
            ];
          };

          keybindings = lib.mkOptionDefault {
            "${config.wayland.windowManager.sway.config.modifier}+1" =
              "workspace 1";

            "${config.wayland.windowManager.sway.config.modifier}+2" =
              "exec ${switchToWorkspace2}";

            "${config.wayland.windowManager.sway.config.modifier}+Return" =
              "exec ${pkgs.foot}/bin/foot";

            "${config.wayland.windowManager.sway.config.modifier}+Shift+q" =
              "kill";

            "${config.wayland.windowManager.sway.config.modifier}+d" =
              "exec ${pkgs.wmenu}/bin/wmenu-run";
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
    [[ "$(tty)" == /dev/tty1 ]] && exec sway
  '';
}
