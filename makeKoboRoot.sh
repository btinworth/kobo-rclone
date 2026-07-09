#!/bin/sh

set -e

SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
KOBORCLONE_DIR="$SCRIPT_DIR/src/usr/local/koborclone"

mkdir -p "$KOBORCLONE_DIR"

# download rclone
RCLONE_VERSION=$(curl -fsSL "https://downloads.rclone.org/version.txt" | sed 's/rclone v//')
echo "Latest rclone version: $RCLONE_VERSION"
RCLONE_ZIP="rclone-v${RCLONE_VERSION}-linux-arm-v7.zip"
RCLONE_ZIP_PATH="$KOBORCLONE_DIR/$RCLONE_ZIP"
RCLONE_DOWNLOAD_URL="https://github.com/rclone/rclone/releases/download/v${RCLONE_VERSION}/${RCLONE_ZIP}"
curl -fsSL "$RCLONE_DOWNLOAD_URL" -o "$RCLONE_ZIP_PATH"

# verify rclone checksum
EXPECTED_RCLONE_SHA256=$(curl -fsSL "https://github.com/rclone/rclone/releases/download/v${RCLONE_VERSION}/SHA256SUMS" | grep "$RCLONE_ZIP" | awk '{print $1}')
ACTUAL_RCLONE_SHA256=$(shasum -a 256 "$RCLONE_ZIP_PATH" | awk '{print $1}')
if [ "$EXPECTED_RCLONE_SHA256" != "$ACTUAL_RCLONE_SHA256" ]; then
  echo "Checksum mismatch for $RCLONE_ZIP"
  echo "  expected: $EXPECTED_RCLONE_SHA256"
  echo "  got:      $ACTUAL_RCLONE_SHA256"
  rm -f "$RCLONE_ZIP_PATH"
  exit 1
fi

unzip -p "$RCLONE_ZIP_PATH" "rclone-v${RCLONE_VERSION}-linux-arm-v7/rclone" > "$KOBORCLONE_DIR/rclone"
rm -f "$RCLONE_ZIP_PATH"
chmod +x "$KOBORCLONE_DIR/rclone"

# download cacert.pem
CACERT_PATH="$KOBORCLONE_DIR/cacert.pem"
curl -fsSL "https://curl.se/ca/cacert.pem" -o "$CACERT_PATH"

# verify cacert.pem checksum
EXPECTED_CACERT_SHA256=$(curl -fsSL "https://curl.se/ca/cacert.pem.sha256" | awk '{print $1}')
ACTUAL_CACERT_SHA256=$(shasum -a 256 "$CACERT_PATH" | awk '{print $1}')
if [ "$EXPECTED_CACERT_SHA256" != "$ACTUAL_CACERT_SHA256" ]; then
  echo "Checksum mismatch for cacert.pem"
  echo "  expected: $EXPECTED_CACERT_SHA256"
  echo "  got:      $ACTUAL_CACERT_SHA256"
  rm -f "$CACERT_PATH"
  exit 1
fi

# download jq (static arm hard-float build, matches the rclone arm-v7 target)
JQ_PATH="$KOBORCLONE_DIR/jq"
curl -fsSL "https://github.com/jqlang/jq/releases/latest/download/jq-linux-armhf" -o "$JQ_PATH"

# verify jq checksum
EXPECTED_JQ_SHA256=$(curl -fsSL "https://github.com/jqlang/jq/releases/latest/download/sha256sum.txt" | grep 'jq-linux-armhf$' | awk '{print $1}')
ACTUAL_JQ_SHA256=$(shasum -a 256 "$JQ_PATH" | awk '{print $1}')
if [ "$EXPECTED_JQ_SHA256" != "$ACTUAL_JQ_SHA256" ]; then
  echo "Checksum mismatch for jq-linux-armhf"
  echo "  expected: $EXPECTED_JQ_SHA256"
  echo "  got:      $ACTUAL_JQ_SHA256"
  rm -f "$JQ_PATH"
  exit 1
fi
chmod +x "$JQ_PATH"

tar -cvzf KoboRoot.tgz -C src etc usr
