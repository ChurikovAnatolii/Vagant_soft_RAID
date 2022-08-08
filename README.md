# Vagant_soft_RAID
1. В вагрант файл прописано создание дополнительных дисков (2 sd и 2 nvme)
2. Написан скрипт по созданию и монтированию рейд-массива и созданию GPT c пятью разделами:

#!/bin/bash

sudo yum install -y mdadm\
sudo yum install -y gdisk\

sudo mdadm --create /dev/md/raid10 --level=5 --raid-devices=4 /dev/sdd /dev/sde /dev/sdf /dev/sdg\
sudo mkfs.ext4 /dev/md/raid10\
sudo cd\
sudo mkdir raid_mount\
sudo mount /dev/md/raid10 /home/vagrant/raid_mount\
for i in {1..10} ; do\
        sudo sgdisk -n ${i}:0:+100M /dev/nvme0n1\
done


3. В вагрант файл добавлено выполнение данного скрипта в раздел provision.
