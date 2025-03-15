/*
curl https://raw.githubusercontent.com/mike94100/NiftyNix/main/disko-NiftyNix.nix -o /tmp/disko-NiftyNix.nix
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko-NiftyNix.nix

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
            /* grub MBR
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
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypt";
                passwordFile = "/tmp/secret.key"; # Enable for interactive password entry
                askPassword = true; # Enable for interactive password entry
                settings = {
                  allowDiscards = true;
                  #keyFile = "/tmp/secret.key"; # Disable for interactive password entry (precreated key file required)
                };
                #additionalKeyFiles = [ "/tmp/additionalSecret.key" ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # Overrside existing partition
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
  };
}
