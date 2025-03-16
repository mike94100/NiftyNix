/*
Partition Layout
/boot FAT32 512M
crypt BTRFS 100%
    /root - /
    /home - /home
    /nix - /nix
*/
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            /* Uncomment for MBR if needed
            boot = {
                size = "1M"
                type = "EF02"
            }*/
            # EFI
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
            	type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                	"/root" = {
                    	mountpoint = "/";
                        mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                        mountpoint = "/home";
                        mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                	};
                  };
            	};
              };
            };
          };
        };
      };
    };
}
