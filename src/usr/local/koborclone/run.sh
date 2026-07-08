#!/bin/sh

# load config
. "$(dirname "$0")/config.sh"
export USER_CONFIG

# create lib dir
[ ! -e "$LIB" ] && mkdir -p "$LIB" >/dev/null 2>&1

# create user config if it doesn't exist
if [ ! -e "$USER_CONFIG" ]; then
  echo "No user config, creating at $USER_CONFIG"
  if [ -e "$USER_CONFIG_TEMPLATE" ]; then
    cp "$USER_CONFIG_TEMPLATE" "$USER_CONFIG"
  else
    : > "$USER_CONFIG"
  fi
fi

# create rclone config if it doesn't exist
if [ ! -e "$RCLONE_CONFIG" ]; then
  echo "No rclone config, creating at $RCLONE_CONFIG"
  if [ -e "$RCLONE_CONFIG_TEMPLATE" ]; then
    cp "$RCLONE_CONFIG_TEMPLATE" "$RCLONE_CONFIG"
  else
    : > "$RCLONE_CONFIG"
  fi
fi

# check if user config contains the line "UNINSTALL"
if grep -q '^UNINSTALL$' "$USER_CONFIG"; then
  echo "Uninstalling"

  rm -rf /etc/udev/rules.d/97-koborclone.rules
  rm -rf /usr/local/koborclone/
  exit 0
fi

# check if user config contains the line "SYNC" to remove books that no
# longer exist on the sync source
if grep -q '^SYNC$' "$USER_CONFIG"; then
  rclone_command=sync
else
  rclone_command=copy
fi

# check internet connection
echo "$($DT) Checking internet connection"
ping_exit_code=1
ping_retries=0
while [ "$ping_exit_code" -ne 0 ]; do
  if [ "$ping_retries" -gt 60 ]; then
    echo "$($DT) ERROR! No internet connection detected"
    exit 1
  fi
  ping -c 1 -w 3 1.1.1.1 >/dev/null 2>&1
  ping_exit_code=$?
  if [ "$ping_exit_code" -ne 0 ]; then
    sleep 1
  fi
  ping_retries=$((ping_retries + 1))
done

# check for qbdb
if [ ! -f "/usr/bin/qndb" ]; then
  echo "NickelDBus not found, installing..."
  wget "https://github.com/shermp/NickelDBus/releases/download/0.2.0/KoboRoot.tgz" -O - | tar xz -C /
fi

# check for rclone
if [ ! -x "${RCLONE}" ]; then
  echo "rclone missing: binary at ${RCLONE}"
  exit 1
fi

if pgrep -x rclone >/dev/null 2>&1; then
  echo "Another rclone process is already running. Exiting."
  exit 0
fi

changes=false

# loop through each line in the user config file
while IFS= read -r url || [ -n "$url" ]; do
  if echo "$url" | grep -q '^[[:space:]]*$'; then
    continue # ignore blank/whitespace-only lines
  elif echo "$url" | grep -q '^#'; then
    continue # ignore comment lines
  elif [ "$url" = "SYNC" ] || [ "$url" = "UNINSTALL" ]; then
    continue # ignore directive lines
  elif [ -n "$url" ]; then
    dir="$LIB/$(printf '%s' "$url" | sed 's/:/\//g')"
    mkdir -p "$dir"

    files_before=$(find "$dir" -type f -exec stat -c '%s %n' {} \; | sort)

    "$RCLONE" "$rclone_command" \
      --no-check-certificate \
      --size-only \
      --transfers 1 \
      --cache-dir "$RCLONE_CACHE_DIR" \
      --log-level NOTICE \
      --stats 0 \
      --config "$RCLONE_CONFIG" \
      "$url" "$dir"

    files_after=$(find "$dir" -type f -exec stat -c '%s %n' {} \; | sort)
    if [ "$files_before" != "$files_after" ]; then
      changes=true
    fi
  fi
done < "$USER_CONFIG"

# refresh library if required
if [ "$changes" = false ]; then
  echo "No files changed, skipping re-scan"
else
  echo "Files have changed, re-scanning library"

  # use NickelDBus for library refresh
  /usr/bin/qndb -t 3000 -s pfmDoneProcessing -m pfmRescanBooksFull
fi

echo "$($DT) done"
