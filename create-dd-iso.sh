#!/bin/bash
set -e

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


if [[ "$#" -ne 2 ]]; then
    echo "Usage: $0 <clonezilla url> <image file name>"
    exit 1
fi

TARGET_DISK="/dev/sda"

CLONEZILLA_URL=$1
CLONEZILLA_PATH="clonezilla.iso"
IMG_NAME=$2

WORK_DIR="dd_build_$$"
ISO_DIR="$WORK_DIR/iso"
MOUNT_DIR="$WORK_DIR/mount"

mkdir -p "$WORK_DIR" "$ISO_DIR" "$MOUNT_DIR"

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
mount -o loop "$CLONEZILLA_PATH" "$MOUNT_DIR"
cp -r "$MOUNT_DIR"/* "$ISO_DIR/"
umount "$MOUNT_DIR"

echo "                                   "
echo "###################################"
echo "       Embedding Landslide...      "
echo "###################################"
echo "                                   "
mkdir -p $ISO_DIR/home/partimag
cp $IMG_NAME $ISO_DIR/home/partimag/

echo "                                   "
echo "###################################"
echo "         Preseeding Task...        "
echo "###################################"
echo "                                   "
sed -i 's|locales=|locales=en_US.UTF-8|' $ISO_DIR/syslinux/isolinux.cfg
sed -i 's|keyboard-layouts=|keyboard-layouts=NONE|' $ISO_DIR/syslinux/isolinux.cfg
sed -i "s|ocs_live_run=\"ocs-live-general\"|ocs_live_run=\"sudo dd if=/run/live/medium/home/partimag/${IMG_NAME} of=${TARGET_DISK}\" ocs_postrun=\"sudo poweroff\"|" $ISO_DIR/syslinux/isolinux.cfg
sed -i "s|ocs_live_batch=\"no\"|ocs_live_batch=\"yes\"|" $ISO_DIR/syslinux/isolinux.cfg

echo "                                   "
echo "###################################"
echo "           Building ISO...         "
echo "###################################"
echo "                                   "

# DO NOT CHANGE THIS
# Modified from https://drbl.org/faq/2_System/files/editCZCDsquashfs.txt
genisoimage -b syslinux/isolinux.bin -c syslinux/boot.cat -o dd-landslide.iso -no-emul-boot -boot-load-size 4 -boot-info-table -allow-limited-size -r -J -l -input-charset iso8859-1 $ISO_DIR

rm -rf $WORK_DIR
