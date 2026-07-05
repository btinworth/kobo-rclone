#!/bin/sh

set -e

RCLONE_VERSION="1.74.3"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
BIN_DIR="$SCRIPT_DIR/src/usr/local/koborclone/bin"

mkdir -p "$BIN_DIR"

RCLONE_ZIP="rclone-v${RCLONE_VERSION}-linux-arm-v7.zip"
RCLONE_ZIP_PATH="$BIN_DIR/$RCLONE_ZIP"
RCLONE_DOWNLOAD_URL="https://github.com/rclone/rclone/releases/download/v${RCLONE_VERSION}/${RCLONE_ZIP}"

curl -fsSL "$RCLONE_DOWNLOAD_URL" -o "$RCLONE_ZIP_PATH"

unzip -p "$RCLONE_ZIP_PATH" "rclone-v${RCLONE_VERSION}-linux-arm-v7/rclone" > "$BIN_DIR/rclone"
rm -f "$RCLONE_ZIP_PATH"
chmod +x "$BIN_DIR/rclone"

tar -cvzf KoboRoot.tgz -C src etc usr
