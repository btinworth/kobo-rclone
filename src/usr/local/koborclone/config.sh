#!/bin/sh

KOBORCLONE_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
USER_CONFIG_TEMPLATE="$KOBORCLONE_DIR/koborclone.json.tmpl"
RCLONE_CONFIG_TEMPLATE="$KOBORCLONE_DIR/rclone.conf.tmpl"

CONFIG_DIR=/mnt/onboard/.adds/koborclone
LIBRARY_DIR=/mnt/onboard

DT="date +%Y-%m-%d_%H:%M:%S"

USER_CONFIG="$CONFIG_DIR/koborclone.json"
RCLONE_CONFIG="$CONFIG_DIR/rclone.conf"
RCLONE_CACHE_DIR="$CONFIG_DIR/cache"
RCLONE="$KOBORCLONE_DIR/rclone"
JQ="$KOBORCLONE_DIR/jq"
