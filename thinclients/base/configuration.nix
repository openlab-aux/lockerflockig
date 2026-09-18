{ pkgs, lib, ... }:
{
  imports = [
    ./disko.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  time.timeZone = "Europe/Berlin";

  users.users.root = {
    initialHashedPassword = lib.mkForce "$y$j9T$pP12RGiG/ftp.21vfzdpk0$KSNNZ.I7s3biDykt7VcgEsw0JbGddRqTX7ZApFhfjr8";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGnZ9eV387NUKXIs+TSxRjL5bH/bCp2qI7imzTuhjsdh root@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZ/XY0zYbrSzVwU/NTiO0QrlsiQ2p62P4PUj7XJsKIA yonggan@Yonggan"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFhMuAk6prXqp5Db9tAQ+LZcflgW2Xc+W2vvxE9l/JQbsQIuRAWOGHP8P5F4RvStIymdUjKBqbmj4tZFNpP/dl6uHqERg0wC9IAihB8KIiyaf8ImlG/a0OxzvJj2XTeJ9/nvWKxS978e6Z/pB0WrA4tM46qBKHcAHbc8cli8rqzr4IBRNaMnMloucirGH/8oST0crHMVGwcXl890Xlbha7YhDxI5bYhA1/LxzAmQwgNtPGEbZcMSLEyCPEfADqxMVVS7ffcQTvVQzVxuNcwb4PY2ARedftvhEN0WsVQdfCr+9ArWQ5EyFAOhh/O72t5FqGjpH1doCrdA5IkFEwArTD kingbbq@ObenDroben.fritz.box"
    ];
  };

  users.users.openlab = {
    isNormalUser = true;
    extraGroups = [
      "audio"
      "video"
    ];
    initialPassword = "openlab";
    createHome = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    git
    htop
    lsof
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
    openFirewall = true;
  };

  system.stateVersion = "25.05"; # Did you read the comment?
}
