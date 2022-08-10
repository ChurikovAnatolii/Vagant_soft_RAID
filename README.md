# Vagant_soft_RAID
1. В вагрант файл прописано создание дополнительных дисков (2 sd и 2 nvme)
2. Написан скрипт по созданию и монтированию рейд-массива и созданию GPT c пятью разделами:


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
mount /dev/md/raid10 /root/raid_mount

# config mount options after reboot the system
echo '/dev/md/raid10                /root/raid_mount              ext4    defaults        0 0' >> /etc/fstab

# create 5 partitions 
for i in {1..10} ; do
        sudo sgdisk -n ${i}:0:+100M /dev/nvme0n1
done



3. В вагрант файл добавлено выполнение данного скрипта в раздел provision + добавлен вход по ssh от рута.


4. Raid остановлен: 

umount /dev/md127 
mdadm --stop /dev/md127 
mdadm: stopped /dev/md127

и запущен:

mdadm --assemble --scan
mdadm: /dev/md/raid10 has been started with 4 drives


6. Для автоматической загрузки конфигурации рейда добавлен файл mdadm.conf

ARRAY /dev/md/raid10 level=raid5 num-devices=4 metadata=1.2 spares=1 name=server:raid10 UUID=6e9dcdcf:2f9f3bbf:4ccc68e7:802a5d6c
   devices=/dev/sdd,/dev/sde,/dev/sdf,/dev/sdg


7. В fstab добавлена запись для автоматического примонтирования при загрузке:

 echo '/dev/md/raid10                /home/vagrant/raid_mount              ext4    defaults        0 0' >> /etc/fstab

