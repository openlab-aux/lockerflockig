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
    ];
  };

  users.users.openlab = {
    isNormalUser = true;
    extraGroups = [ "audio" "video" ];
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
