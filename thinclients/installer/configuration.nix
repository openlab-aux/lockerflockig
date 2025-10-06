{ lib, ...}: {
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
    openFirewall = true;
  };

  boot.loader.efi.canTouchEfiVariables = false;

  users.users.root = {
    initialHashedPassword = lib.mkForce "$y$j9T$pP12RGiG/ftp.21vfzdpk0$KSNNZ.I7s3biDykt7VcgEsw0JbGddRqTX7ZApFhfjr8";
  };

  system.stateVersion = "25.05";
}