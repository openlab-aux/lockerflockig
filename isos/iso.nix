{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  networking.hostName = "newNixos";
  users.users.root.initialPassword = "openlab";
  networking.networkmanager = {
    enable = true;
    ensureProfiles.profiles = {
      openlab-wifi = {
        connection = {
          id = "openlab-wifi";
          permissions = "";
          type = "wifi";
        };
        ipv4 = {
          dns-search = "";
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          dns-search = "";
          method = "auto";
        };
        wifi = {
          mac-address-blacklist = "";
          mode = "infrastructure";
          ssid = "Labor 2.0";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "nerdhoehle2";
        };
      };
      airbnb = {
        connection = {
          id = "airbnb";
          permissions = "";
          type = "wifi";
        };
        ipv4 = {
          dns-search = "";
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          dns-search = "";
          method = "auto";
        };
        wifi = {
          mac-address-blacklist = "";
          mode = "infrastructure";
          ssid = "MagentaWLAN-KJRQ";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-psk";
          psk = "68820295498583314159";
        };

      zw = {
        connection = {
          id = "zw";
          permissions = "";
          type = "wifi";
        };
        ipv4 = {
          dns-search = "";
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "stable-privacy";
          dns-search = "";
          method = "auto";
        };
        wifi = {
          mac-address-blacklist = "";
          mode = "infrastructure";
          ssid = "ZW public";
        };
      };
    };
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = true;
      KbdInteractiveAuthentication = true;
      PermitRootLogin = "yes";
    };
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  hardware.enableRedistributableFirmware = true;

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEee8lHpYKVEi0vbwD9QAz4nBTFVj3BmCzRtO2l6CzWs yonggan@Yonggan"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPYdhNU88xDjiC6LNwlgyxgTdf6oIx7CQq/fy91nA2aY nanashi@riotuxedo"
  ];
  environment.systemPackages = [ pkgs.neovim pkgs.qrencode ];

  systemd.services.connection-info = {
    after = [ "network-online.target" "sshd.service" "systemd-udev-settle.service" ];
    wants = [ "network-online.target" ];
    before = [ "getty@tty1.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      StandardOutput = "tty";
      StandardError = "tty";
      TTYPath = "/dev/tty1";
    };
    script = ''
      IP=$(${pkgs.iproute2}/bin/ip -4 -o addr show scope global | awk '{print $4}' | cut -d/ -f1 | head -n1)
      HOSTNAME=$(${pkgs.nettools}/bin/hostname)
      NMSTATUS=$(${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status 2>/dev/null)
      FPRINT=$(${pkgs.openssh}/bin/ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub 2>/dev/null)
      echo "" > /dev/tty1
      echo "========================================" > /dev/tty1
      echo "Hostname: $HOSTNAME" > /dev/tty1
      echo "IP Address: $IP" > /dev/tty1
      echo "Network status:" > /dev/tty1
      echo "$NMSTATUS" > /dev/tty1
      echo "SSH host key fingerprint: $FPRINT" > /dev/tty1
      echo "ssh: ssh root@$IP" > /dev/tty1
      echo "password: openlab"
      echo "nixos-anywhere: nix run github:nix-community/nixos-anywhere -- --flake .#taler root@$IP" > /dev/tty1
      echo "========================================" > /dev/tty1
      DATA="hostname=$HOSTNAME
ip=$IP
ssh=ssh root@$IP
fingerprint=$FPRINT
nixos-anywhere=nix run github:nix-community/nixos-anywhere -- --flake .#taler root@$IP"
      echo "$DATA" | ${pkgs.qrencode}/bin/qrencode -t ANSIUTF8 > /dev/tty1
    '';
  };
}
