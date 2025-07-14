# clonezilla-automation

## Approach 1: dd-based ISO (non-interactive install)

### Artifacts:

Produces a bootable Clonezilla ISO that will non-interactively image the first disk detected by Clonezilla with a provided Landslide image. To manually choose which disk will be targeted, edit the ```TARGET_DISK``` variable inside of the script.


### Preconditions:
1. Access to```create-dd-iso.sh``` with execute permissions
2. Access to root permissions
3. Access to the ```geniso``` and ```wget``` commands
4. Landslide image (save99) (```.img``` file) in CWD

### Execution:
To run the automation, run ```sudo ./create-dd-iso.sh <clonezilla url> <image file name>```. Running the script will:

- Download the Clonezilla ISO
- Extract the Clonezilla ISO
- Edit the boot parameters of the ISO
- Copy over the Landslide image to the ISO
- Repackage the ISO using ```genisoimage```

After burning the ISO to a Blu-ray, booting up a machine using the CD will non-interactively image the first disk detected by Clonezilla.

### Screenshots:



## Approach 2: Clonezilla-based ISO (interactive install)

### Artifacts:

Produces a bootable Clonezilla ISO that can interactively image a disk with a provided Landslide image.

### Preconditions:
1. Access to```create-clonezilla-iso.sh``` with execute permissions
2. Access to root permissions
3. Access to a working QEMU/KVM setup
4. Access to the ```geniso``` command
5. Landslide qcow2 (save99) (```.qcow2``` file) in CWD

### Execution:
To run the automation, run ```sudo ./create-clonezilla-iso.sh <clonezilla url> <qcow2 file name>```. Running the script will:

- Download the Clonezilla ISO
- Extract the Clonezilla ISO
- Edit the boot parameters of the ISO
- Repackage the ISO
- Create a qcow2 to store the Clonezilla compatible image
- Run Clonezilla in a VM to create the Clonezila-compatible Landslide image
- Copy Landslide image to Clonezilla ISO
- Repackage the ISO with Landslide image

After burning the ISO to a Blu-ray, follow these steps to image Landslide to your disk:
