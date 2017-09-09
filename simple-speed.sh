#!/bin/bash

# https://wiki.archlinux.org/index.php/SSD_Benchmarking#Using_hdparm
# gnome-disks
# systemd-analyze plot > boot.svg


if [ -r "$(which hbasics)" ] ; then
  source hbasics # lsdisk.sh 
fi

echo -e "\n##########################################" \
        "\n### diskspeed.sh - Working from $(pwd) ###" \
        "\n##########################################"

dev=""
if [ ! -z "$(type -a lsdisk)" ] ; then
  dev="$(lsdisk -dev)" # find out which /dev/zzz  $PWD is on
  if [ ! -z "$dev" ] ;then
    echo -e "\nLaunching 'parted' to print partition parameters - sudo..."
    sudo parted $dev -s unit B print
    echo -e "\nLaunching 'hdparm -Tt $dev' with sudo..."
    sudo hdparm -Tt $dev
  else
    echo "lsdisk failed to provide /dev/... , cannot automatically run hdparm"
  fi
else
  echo "No lsdisk, cannot find out the required device name /dev/..."
fi


tf=./tempfile
blksize="4k"     ;bznumeric=4096
blkcount=256000  ;bcnumeric=$blkcount

echo -e "\n\nSetup: $blkcount blocks of $blksize, a total of $(($bcnumeric * $bznumeric )) bytes."


echo -e "\nUsing 'dd' - Creating $tf ... non-cached write"
dd if=/dev/zero of=$tf bs=$blksize count=$blkcount conv=fdatasync,notrunc

echo -e "\nClear cache... sudo required"
sudo bash -c 'echo 3 > /proc/sys/vm/drop_caches'

echo -e "\n'dd' -- Non-cached read..."
dd if=$tf of=/dev/null bs=$blksize count=$blkcount

echo -e "\n'dd' -- Cached read..."
dd if=$tf of=/dev/null bs=$blksize count=$blkcount

echo -e "\n'dd' -- Removing $tf"
rm $tf


