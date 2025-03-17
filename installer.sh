#!/bin/sh
#
# For installing NixOS-NiftyNix from minimal iso
#
# To run:
# sh -c "$(curl https://raw.githubusercontent.com/mike94100/NiftyNix/main/installer.sh)"

echo "--------------------------------------------------------------------------------"
echo "Storage devices will be listed."
read -p "Press 'q' to exit the list. Press enter to continue." NULL

sudo fdisk -l | less

echo "--------------------------------------------------------------------------------"
echo "Detected the following devices:"
echo

i=0
for device in $(sudo fdisk -l | grep "^Disk /dev" | awk "{print \$2}" | sed "s/://"); do
    echo "[$i] $device"
    i=$((i+1))
    DEVICES[$i]=$device
done

echo
read -p "Which device do you wish to install on? " DEVICE

DEV=${DEVICES[$(($DEVICE+1))]}

read -p "Partition ${DEV}? [Y/n] " ANSWER

if [ "$ANSWER" = "n" ]; then
    exit 1
fi

curl https://raw.githubusercontent.com/mike94100/NiftyNix/main/disko.nix -o /tmp/disko.nix

read -p "Destroy, format, and mount the drive? Or remount matching partition configuration?  [1/2]" ANSWER
if [ "$ANSWER" = "1" ]; then
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode destroy,format,mount /tmp/disko.nix
elif [ "$ANSWER" = "2" ]; then
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode mount /tmp/disko.nix
else
    exit 1
fi

echo "Generate NixOS configuration."
sudo nixos-generate-config --root /mnt

read -p "Press enter to open the Nix configuration in nano."
sudo nano /mnt/etc/nixos/configuration.nix

echo "Install NixOS..."
cd /mnt
sudo nixos-install

read -p "Remove installation media. Press enter to reboot." NULL
reboot
