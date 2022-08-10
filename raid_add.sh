#!/bin/bash

# Install mdadm and gdisk
yum install -y mdadm
yum install -y gdisk

# Create array and make config file
mdadm --create /dev/md/raid10 --level=5 --raid-devices=4 /dev/sdd /dev/sde /dev/sdf /dev/sdg
mdadm --detail --scan --verbose >> /etc/mdadm.conf

# Create filesystem and mount point 
mkfs.ext4 /dev/md/raid10
cd
mkdir raid_mount
mount /dev/md/raid10 /home/vagrant/raid_mount

# config mount options after reboot the system
echo '/dev/md/raid10                /home/vagrant/raid_mount              ext4    defaults        0 0' >> /etc/fstab' >> /etc/fstab

# create 5 partitions 
for i in {1..10} ; do
        sudo sgdisk -n ${i}:0:+100M /dev/nvme0n1

