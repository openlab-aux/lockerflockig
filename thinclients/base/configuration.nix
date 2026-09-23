{ pkgs, lib, ... }:
{
  imports = [
    ./disko.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  hardware.enableRedistributableFirmware = true;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  time.timeZone = "Europe/Berlin";

  users.users.root = {
    initialHashedPassword = lib.mkForce "$y$j9T$pP12RGiG/ftp.21vfzdpk0$KSNNZ.I7s3biDykt7VcgEsw0JbGddRqTX7ZApFhfjr8";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGnZ9eV387NUKXIs+TSxRjL5bH/bCp2qI7imzTuhjsdh root@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINZ/XY0zYbrSzVwU/NTiO0QrlsiQ2p62P4PUj7XJsKIA yonggan@Yonggan"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFhMuAk6prXqp5Db9tAQ+LZcflgW2Xc+W2vvxE9l/JQbsQIuRAWOGHP8P5F4RvStIymdUjKBqbmj4tZFNpP/dl6uHqERg0wC9IAihB8KIiyaf8ImlG/a0OxzvJj2XTeJ9/nvWKxS978e6Z/pB0WrA4tM46qBKHcAHbc8cli8rqzr4IBRNaMnMloucirGH/8oST0crHMVGwcXl890Xlbha7YhDxI5bYhA1/LxzAmQwgNtPGEbZcMSLEyCPEfADqxMVVS7ffcQTvVQzVxuNcwb4PY2ARedftvhEN0WsVQdfCr+9ArWQ5EyFAOhh/O72t5FqGjpH1doCrdA5IkFEwArTD kingbbq@ObenDroben.fritz.box"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDH7Fj7uje2+93emO38XYivaxvh8/wL9WwjbW0gdIvXaW0NKhsVzX4Y4wDzcnCSd/fWbh2nvVF0MLkkzEe2OI1At00j+bAyzEOhliG8eJNIrNxif8Cr2Rk7guNd/R/uO5w/v/V5cVXjAty+i769avuaGa0oA95czp6gzFxg3M42td4d1EsVRDfQ85yvNnYj3Qi5MAYp8qF4WJkg3tEImGfv1psvhgikUGErcLSUA45MpCkgiW1xZ7DssHYHYmYqaeQfs3zgGM32MPg4pZl2oEERrpHQqaFncpBrq48J5GjvtsqvM3982hXoZdGN7FWwVRDvpNfvAYGJCK+81piITnkz732Md8aguhNMxDJ3t+Upptg0814If3m7Ps5aH2Tqmsmf85ILlxyNBgnH9awKTScNJLX3NHyh+yw9kNYJUdXDYENAk+Q3IX8VAJtUfjq8N8oqgIF7g4ySkV23AxReJZFSHbEDfOO4Hc0aObK3LkuVHdl2MrT4mto/IQqdkiq43lk= matze@blade"
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
