#!/bin/sh
#
# For installing NixOS-NiftyNix from minimal iso
#
# To run: sh -c "$(curl https://raw.githubusercontent.com/mike94100/NiftyNix/main/installer.sh)"

echo "--------------------------------------------------------------------------------"
echo "Storage devices will be listed."
read -p "Press 'q' to exit the list. Press enter to continue." NULL

sudo fdisk -l | less

echo "--------------------------------------------------------------------------------"
echo "Detected the following devices:"
echo

i=0
for device in $(sudo fdisk -l | grep "^Disk /dev" | awk "{print \$2 \$3 \$4}" | sed "s/,//"); do
    echo awk "{print \$2 \$3 \$4}"
    echo "[$i] $device"
    i=$((i+1))
    DEVICES[$i]=$device
done

echo
read -p "Which device do you wish to install on? " DEVICE

DEV=${DEVICES[$(($DEVICE+1))]}

read -p "Partition ${DEV}? [Y/n] " ANSWER

if [ "$ANSWER" = "Y" ]; then
    curl https://raw.githubusercontent.com/mike94100/NiftyNix/main/disko.nix -o /tmp/disko.nix
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko /tmp/disko.nix
fi

echo "Generate NixOS configuration."
sudo nixos-generate-config --root /mnt

read -p "Press enter to open the Nix configuration in nano."
sudo nano /mnt/etc/nixos/configuration.nix

echo "Install NixOS..."
sudo nixos-install

read -p "Remove installation media. Press enter to reboot." NULL
reboot
