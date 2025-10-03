#!/bin/bash

dev="$1"

# Check for required argument
if [[ ! -b "${dev}" ]]; then
  echo "Error! No device was provided."
  exit 1
fi

# Check for root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run the script with administrator privileges."
  exit 1
fi

echo "Repairing drive..."
umount -f "${dev}"* &> /dev/null || true
sgdisk -t 1:0700 -c 1:"EFI System" -A 1:set:0 -A 1:set:62 -A 1:set:63 "${dev}"

tar -xf ./binaries/grub-*/i386-pc.tar.xz --wildcards *.img -C "/tmp"
dd conv=fsync status=none if="/tmp/i386-pc/boot.img" of="${dev}" bs=1 count=446
dd conv=fsync status=none if="/tmp/i386-pc/core.img" of="${dev}" bs=512 count=2014 seek=34

sync
rm -rf "/tmp/i386-pc/"
echo -e "\n\e[0;42mMultiOS-USB has been successfully repaired.\e[0m\n"
