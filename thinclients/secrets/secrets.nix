let
  audiovideo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKYJthO/KnF0PO/vAWMTUeNgvw2q7EElAsYHn60PAAxg";

  waaaaargh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKRkkl2ehRq95aP2W7v2+iMxi3vGdQgwwfTvWbU+uVN1 fuermannj@gmail.com";
  torproxy_shared = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGnZ9eV387NUKXIs+TSxRjL5bH/bCp2qI7imzTuhjsdh root@nixos";

  users = [
    waaaaargh
    torproxy_shared
  ];

  systems = [
    audiovideo
  ];

in {
  "foobar.age".publicKeys = users ++ systems;
}