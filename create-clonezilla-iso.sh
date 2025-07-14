#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <clonezilla url> <qcow2 name>"
    echo "Example: $0 https://clonezilla.iso Landslide.qcow2"
    exit 1
fi

CLONEZILLA_URL=$1
CLONEZILLA_PATH="clonezilla.iso"
IMG_NAME=$2


WORK_DIR="clonezilla_build_$$"
ISO_DIR="$WORK_DIR/iso"
MOUNT_DIR="$WORK_DIR/mount"

mkdir -p "$WORK_DIR" "$ISO_DIR" "$MOUNT_DIR"

# Download Clonezilla if not present
if [ ! -f "$CLONEZILLA_PATH" ]; then
    echo "                                   "
    echo "###################################"
    echo "   Downloading Clonezilla ISO...   "
    echo "###################################"
    echo "                                   "
    wget -O "$CLONEZILLA_PATH" "$CLONEZILLA_URL"
fi

echo "                                   "
echo "###################################"
echo "     Extracting Clonezilla...      "
echo "###################################"
echo "                                   "
sudo mount -o loop "$CLONEZILLA_PATH" "$MOUNT_DIR"
cp -r "$MOUNT_DIR"/* "$ISO_DIR/"
sudo umount "$MOUNT_DIR"


echo "                                   "
echo "###################################"
echo "         Preseeding Task...        "
echo "###################################"
echo "                                   "
sed -i 's|locales=|locales=en_US.UTF-8|' $ISO_DIR/syslinux/isolinux.cfg
sed -i 's|keyboard-layouts=|keyboard-layouts=NONE ocs_prerun1="sudo mount /dev/sdb /home/partimag"|' $ISO_DIR/syslinux/isolinux.cfg
sed -i "s|ocs_live_run=\"ocs-live-general\"|ocs_live_run=\"ocs-sr -q2 -j2 -z0 -i 0 -p poweroff -b -y -icds -scs -sfsck -nogui savedisk Landslide sda\"|" $ISO_DIR/syslinux/isolinux.cfg
sed -i "s|ocs_live_batch=\"no\"|ocs_live_batch=\"yes\"|" $ISO_DIR/syslinux/isolinux.cfg

# create usb drive
qemu-img create -f qcow2 usb-drive.qcow2 25G
modprobe nbd max_part=8
qemu-nbd --connect=/dev/nbd0 usb-drive.qcow2
mkfs.ext4 /dev/nbd0
qemu-nbd --disconnect /dev/nbd0

echo "                                   "
echo "###################################"
echo "           Building ISO...         "
echo "###################################"
echo "                                   "
# DO NOT CHANGE THIS
# Modified from https://drbl.org/faq/2_System/files/editCZCDsquashfs.txt
genisoimage -b syslinux/isolinux.bin -c syslinux/boot.cat -o save-landslide.iso -no-emul-boot -boot-load-size 4 -boot-info-table -allow-limited-size -r -J -l -input-charset iso8859-1 $ISO_DIR

qemu-system-x86_64 -boot d -cdrom save-landslide.iso -m 4G --enable-kvm -smp cores=4,threads=1 -drive file=$IMG_NAME,index=0 -drive file=usb-drive.qcow2,index=1

qemu-nbd --disconnect /dev/nbd0

mkdir -p /mnt/tmp
modprobe nbd max_part=8
qemu-nbd --connect=/dev/nbd0 usb-drive.qcow2
mount /dev/nbd0 /mnt/tmp
cp -r /mnt/tmp/Landslide .
umount /mnt/tmp
rm -rf /mnt/tmp
qemu-nbd --disconnect /dev/nbd0

rm -rf save-landslide.iso
rm -rf usb-drive.qcow2

echo "                                   "
echo "###################################"
echo "       Adding Landslide...         "
echo "###################################"
echo "                                   "
rm -rf $WORK_DIR
mkdir -p "$WORK_DIR" "$ISO_DIR" "$MOUNT_DIR"
mount -o loop "$CLONEZILLA_PATH" "$MOUNT_DIR"
cp -r "$MOUNT_DIR"/* "$ISO_DIR/"
umount "$MOUNT_DIR"

mkdir -p $ISO_DIR/home/partimag
mv Landslide $ISO_DIR/home/partimag
genisoimage -b syslinux/isolinux.bin -c syslinux/boot.cat -o clonezilla-landslide.iso -no-emul-boot -boot-load-size 4 -boot-info-table -allow-limited-size -r -J -l -input-charset iso8859-1 $ISO_DIR

rm -rf $WORK_DIR
