#!/bin/sh
#load config
. $(dirname $0)/config.sh

#create work dirs
[ ! -e "$LOGS" ] && mkdir -p "$LOGS" >/dev/null 2>&1
[ ! -e "$LIB" ] && mkdir -p "$LIB" >/dev/null 2>&1
[ ! -e "$SD" ] && mkdir -p "$SD" >/dev/null 2>&1

if [ ! -e $USER_CONFIG ]; then
  if [ -e $CONFIG_FILE ]; then
    cp $CONFIG_FILE $USER_CONFIG
  else
    echo "# Add your rclone remote:folder/on/remote pairs to this file" > $USER_CONFIG
    echo "# Remove the # from the following line to uninstall KoboRclone" >> $USER_CONFIG
    echo "#UNINSTALL" >> $USER_CONFIG
  fi
fi

#bind mount to subfolder of SD card on reboot
mountpoint -q "$SD"
if [ $? -ne 0 ]; then
  mount --bind "$LIB" "$SD"
  echo sd add /dev/mmcblk1p1 >> /tmp/nickel-hardware-status
fi
