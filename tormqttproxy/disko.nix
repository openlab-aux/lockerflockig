{...}: {
  disko.devices = {
    disk = {
	    # To specify an additional drive, create another entry e.g. disk.data
      main = {
        device = "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
			      # Boot partition formatted for EFI
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              name = "ESP";
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
			      # Optional swap partition
            swap = {
              size = "2G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
			      # Root partition for operating system storage
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}