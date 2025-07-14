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

After burning the ISO to a Blu-ray, follow existing steps to interactively image Landslide onto an existing disk.

### Screenshots:
<img width="3206" height="894" alt="image" src="https://github.com/user-attachments/assets/a7807544-8446-4af7-ba4c-cb6721ee883d" />
<img width="1476" height="1636" alt="image" src="https://github.com/user-attachments/assets/d6552939-8f92-4dbc-b0ad-80b32ccf69fb" />
<img width="3839" height="2268" alt="image" src="https://github.com/user-attachments/assets/d7ac3833-cb27-4c1c-aa52-5a004107a7ee" />
<img width="3835" height="2130" alt="image" src="https://github.com/user-attachments/assets/8f17f649-e3c7-438d-aef6-0a9c0511cf00" />


