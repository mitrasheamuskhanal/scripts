#!/bin/bash
# Author: MSK
# Description: Create Home Assistant VM on Proxmox

set -e

WORKDIR="/root/home-assistant"
IMAGE="haos_ova-18.1.qcow2"
IMAGE_XZ="${IMAGE}.xz"

echo "===================================="
echo " Home Assistant Proxmox Installer"
echo "===================================="

# Create working directory
mkdir -p $WORKDIR
cd $WORKDIR


# Download HAOS image
if [ ! -f "$IMAGE" ]; then

    if [ ! -f "$IMAGE_XZ" ]; then
        echo "Downloading Home Assistant OS..."
        wget -O "$IMAGE_XZ" \
        https://github.com/home-assistant/operating-system/releases/download/18.1/haos_ova-18.1.qcow2.xz
    fi

    echo "Extracting image..."
    unxz "$IMAGE_XZ"

else
    echo "Image already exists, skipping download."
fi


# VM Information
echo
read -p "Enter VM ID: " vmid
read -p "Enter VM Name: " vmname


# Check existing VM
if qm status $vmid &>/dev/null; then
    echo "VM ID $vmid already exists!"
    exit 1
fi


########################################
# Network bridge selection
########################################

echo
echo "Available Network Bridges"
echo "-------------------------"

bridges=($(ip -br link show type bridge | awk '{print $1}'))

if [ ${#bridges[@]} -eq 0 ]; then
    echo "No bridge found!"
    exit 1
fi

for i in "${!bridges[@]}"; do
    echo "$((i+1)). ${bridges[$i]}"
done

echo "$(( ${#bridges[@]} + 1 )). Other"

read -p "Select network bridge: " bridge_choice


if [ "$bridge_choice" -eq "$(( ${#bridges[@]} + 1 ))" ]; then

    read -p "Enter custom bridge name: " bridge

else

    bridge=${bridges[$((bridge_choice-1))]}

fi


echo "Selected bridge: $bridge"


########################################
# Storage selection
########################################

echo
echo "Available Proxmox Storage"
echo "-------------------------"


storages=($(pvesm status | awk 'NR>1 {print $1}'))


for i in "${!storages[@]}"; do
    echo "$((i+1)). ${storages[$i]}"
done


echo "$(( ${#storages[@]} + 1 )). Other"

read -p "Select storage: " storage_choice


if [ "$storage_choice" -eq "$(( ${#storages[@]} + 1 ))" ]; then

    read -p "Enter custom storage name: " storage

else

    storage=${storages[$((storage_choice-1))]}

fi


echo "Selected storage: $storage"



########################################
# Create VM
########################################

echo
echo "Creating VM..."

qm create $vmid \
--name "$vmname" \
--memory 4096 \
--cores 2 \
--sockets 1 \
--cpu host \
--net0 virtio,bridge=$bridge \
--machine q35 \
--bios ovmf


########################################
# EFI Disk
########################################

echo "Adding EFI disk..."

qm set $vmid \
--efidisk0 $storage:0,efitype=4m,pre-enrolled-keys=0



########################################
# Import HA Disk
########################################

echo "Importing Home Assistant disk..."

qm importdisk \
$vmid \
$IMAGE \
$storage



########################################
# Attach disk
########################################

echo "Attaching disk..."

unused_disk=$(qm config $vmid | grep unused | awk '{print $2}' | cut -d':' -f2)


if [ -z "$unused_disk" ]; then
    echo "Could not find imported disk"
    exit 1
fi


qm set $vmid \
--scsihw virtio-scsi-pci \
--scsi0 $storage:$unused_disk



########################################
# Boot settings
########################################

qm set $vmid \
--boot order=scsi0


qm set $vmid \
--serial0 socket \
--vga serial0



########################################
# Start VM
########################################

echo
echo "Starting Home Assistant..."

qm start $vmid

qm set 111 --vga std
echo
echo "===================================="
echo " Home Assistant VM Created"
echo "===================================="

echo
qm config $vmid

echo
echo "Access Home Assistant:"
echo "http://<VM-IP>:8123"
