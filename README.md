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

NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda            8:0    0 19.5G  0 disk 
|-sda1         8:1    0    2G  0 part [SWAP]
`-sda2         8:2    0 17.6G  0 part /
sdb            8:16   0    1G  0 disk 
sdc            8:32   0    1G  0 disk 
sdd            8:48   0    1G  0 disk 
sde            8:64   0    1G  0 disk 
sdf            8:80   0    1G  0 disk 
sdg            8:96   0    1G  0 disk 
sdh            8:112  0    1G  0 disk 
sdi            8:128  0    1G  0 disk 
nvme0n1      259:0    0    1G  0 disk 
|-nvme0n1p1  259:7    0  100M  0 part 
|-nvme0n1p2  259:8    0  100M  0 part 
|-nvme0n1p3  259:9    0  100M  0 part 
|-nvme0n1p4  259:10   0  100M  0 part 
|-nvme0n1p5  259:11   0  100M  0 part 
|-nvme0n1p6  259:12   0  100M  0 part 
|-nvme0n1p7  259:13   0  100M  0 part 
|-nvme0n1p8  259:14   0  100M  0 part 
|-nvme0n1p9  259:24   0  100M  0 part 
`-nvme0n1p10 259:25   0  100M  0 part 
nvme0n2      259:1    0    1G  0 disk 
nvme0n3      259:2    0    1G  0 disk 
nvme0n4      259:3    0    1G  0 disk 
nvme0n5      259:4    0    1G  0 disk 
nvme0n6      259:5    0    1G  0 disk 
nvme0n7      259:6    0    1G  0 disk 

и запущен:

mdadm --assemble --scan
mdadm: /dev/md/raid10 has been started with 4 drives

[root@server vagrant]# lsblk
NAME         MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda            8:0    0 19.5G  0 disk  
|-sda1         8:1    0    2G  0 part  [SWAP]
`-sda2         8:2    0 17.6G  0 part  /
sdb            8:16   0    1G  0 disk  
sdc            8:32   0    1G  0 disk  
sdd            8:48   0    1G  0 disk  
`-md127        9:127  0    3G  0 raid5 
sde            8:64   0    1G  0 disk  
`-md127        9:127  0    3G  0 raid5 
sdf            8:80   0    1G  0 disk  
`-md127        9:127  0    3G  0 raid5 
sdg            8:96   0    1G  0 disk  
`-md127        9:127  0    3G  0 raid5 
sdh            8:112  0    1G  0 disk  
sdi            8:128  0    1G  0 disk  
nvme0n1      259:0    0    1G  0 disk  
|-nvme0n1p1  259:7    0  100M  0 part  
|-nvme0n1p2  259:8    0  100M  0 part  
|-nvme0n1p3  259:9    0  100M  0 part  
|-nvme0n1p4  259:10   0  100M  0 part  
|-nvme0n1p5  259:11   0  100M  0 part  
|-nvme0n1p6  259:12   0  100M  0 part  
|-nvme0n1p7  259:13   0  100M  0 part  
|-nvme0n1p8  259:14   0  100M  0 part  
|-nvme0n1p9  259:24   0  100M  0 part  
`-nvme0n1p10 259:25   0  100M  0 part  
nvme0n2      259:1    0    1G  0 disk  
nvme0n3      259:2    0    1G  0 disk  
nvme0n4      259:3    0    1G  0 disk  
nvme0n5      259:4    0    1G  0 disk  
nvme0n6      259:5    0    1G  0 disk  
nvme0n7      259:6    0    1G  0 disk 

6. Для автоматической загрузки конфигурации рейда добавлен файл mdadm.conf

ARRAY /dev/md/raid10 level=raid5 num-devices=4 metadata=1.2 spares=1 name=server:raid10 UUID=6e9dcdcf:2f9f3bbf:4ccc68e7:802a5d6c
   devices=/dev/sdd,/dev/sde,/dev/sdf,/dev/sdg


7. В fstab добавлена запись для автоматического примонтирования при загрузке:

 echo '/dev/md/raid10                /home/vagrant/raid_mount              ext4    defaults        0 0' >> /etc/fstab

