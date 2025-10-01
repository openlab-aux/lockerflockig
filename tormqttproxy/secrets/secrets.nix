let
  yonggan_tormqttproxy1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEPATG9D1L1UtuZwhxWkhCFIDLwTfPxyMsB30JxT/5bV";
  yonggan_tormqttproxy2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmLNSzV9lFwdDUUPJqlQBYhyyem12zIO93xqD8sdXdW";
  users = [
    yonggan_tormqttproxy1
    yonggan_tormqttproxy2
  ];

  systems = [

  ];
in
{
  "tormqttproxy1_hostkey.age".publicKeys = users ++ systems;
  "tormqttproxy2_hostkey.age".publicKeys = users ++ systems;
}
