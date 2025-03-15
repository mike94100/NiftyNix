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
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypt";
                #passwordFile = "/tmp/disk.key"; # Path to file containing the password for initial encryption
                askPassword = true; # Ask for password for initial encryption
                settings = {
                  allowDiscards = true;
                };
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
  };
}
