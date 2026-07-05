#!/bin/bash

KC_HOME=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ConfigFile=$KC_HOME/kobocloudrc.tmpl

Logs=/mnt/onboard/.add/kobocloud
Lib=/mnt/onboard/.add/kobocloud/Library
SD=/mnt/sd/kobocloud
UserConfig=/mnt/onboard/.add/kobocloud/kobocloudrc
RCloneConfig=/mnt/onboard/.add/kobocloud/rclone.conf
Dt="date +%Y-%m-%d_%H:%M:%S"
RCLONEDIR="/mnt/onboard/.add/kobocloud/bin/"
RCLONE="${RCLONEDIR}rclone"
