#!/bin/sh

KC_HOME=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CONFIG_TEMPLATE="$KC_HOME/koborclone.conf.tmpl"
RCLONE_CONFIG_TEMPLATE="$KC_HOME/rclone.conf.tmpl"

LOGS=/mnt/onboard/.add/koborclone
LIB=/mnt/onboard/.add/koborclone/Library
SD=/mnt/sd/koborclone
USER_CONFIG=/mnt/onboard/.add/koborclone/koborclone.conf
DT="date +%Y-%m-%d_%H:%M:%S"
RCLONE_CONFIG=/mnt/onboard/.add/koborclone/rclone.conf
RCLONE="$KC_HOME/bin/rclone"
