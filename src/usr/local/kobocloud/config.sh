#!/bin/bash

KC_HOME=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONFIG_FILE=$KC_HOME/kobocloudrc.tmpl

LOGS=/mnt/onboard/.add/kobocloud
LIB=/mnt/onboard/.add/kobocloud/Library
SD=/mnt/sd/kobocloud
USER_CONFIG=/mnt/onboard/.add/kobocloud/kobocloudrc
DT="date +%Y-%m-%d_%H:%M:%S"
RCLONE_CONFIG=/mnt/onboard/.add/kobocloud/rclone.conf
RCLONE_DIR="/mnt/onboard/.add/kobocloud/bin/"
RCLONE="${RCLONE_DIR}rclone"
