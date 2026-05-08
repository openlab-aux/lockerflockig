{ pkgs, roomName, ... }:
{
  networking = {
    hostName = "${roomName}-audio";
    domain = "lab";
  };

  # only the bare necessities
  environment.systemPackages = with pkgs; [
    vim # fight me irl
    htop
  ];
}
