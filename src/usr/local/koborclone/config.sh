#!/bin/bash

KC_HOME=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_FILE=$KC_HOME/koborclonerc.tmpl

LOGS=/mnt/onboard/.add/koborclone
LIB=/mnt/onboard/.add/koborclone/Library
SD=/mnt/sd/koborclone
USER_CONFIG=/mnt/onboard/.add/koborclone/koborclonerc
DT="date +%Y-%m-%d_%H:%M:%S"
RCLONE_CONFIG=/mnt/onboard/.add/koborclone/rclone.conf
RCLONE="${KC_HOME}/bin/rclone"
