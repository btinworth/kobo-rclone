#!/bin/sh

# load config
. "$(dirname "$0")/config.sh"
export USER_CONFIG

# check if KoboRclone contains the line "UNINSTALL"
if grep -q '^UNINSTALL$' "$USER_CONFIG"; then
  echo "Uninstalling KoboRclone!"
  "$KC_HOME/uninstall.sh"
  exit 0
fi

# check internet connection
echo "$($DT) waiting for internet connection"
r=1
i=0
while [ "$r" -ne 0 ]; do
  if [ "$i" -gt 60 ]; then
    echo "$($DT) error! no connection detected"
    exit 1
  fi
  ping -c 1 -w 3 1.1.1.1 >/dev/null 2>&1
  r=$?
  if [ "$r" -ne 0 ]; then
    sleep 1
  fi
  i=$((i + 1))
done

# check for qbdb
if [ -f "/usr/bin/qndb" ]; then
  echo "NickelDBus found"
else
  echo "NickelDBus not found: installing it!"
  wget "https://github.com/shermp/NickelDBus/releases/download/0.2.0/KoboRoot.tgz" -O - | tar xz -C /
fi

# check for rclone
if [ ! -x "${RCLONE}" ]; then
  echo "rclone missing: binary at ${RCLONE}"
  exit 1
fi

# list file in lib dir before sync (name and size only, matching --size-only)
lib_list_before=$(find "$LIB" -type f ! -name "*.log" -exec stat -c '%s %n' {} \; | sort)
echo "Current Library list"
echo "$lib_list_before"

while IFS= read -r url || [ -n "$url" ]; do
  if echo "$url" | grep -q '^#'; then
    continue
  elif [ -n "$url" ]; then
    if pgrep -x rclone >/dev/null 2>&1; then
      echo "Another rclone process is already running. Exiting."
      exit 0
    fi

    remote=$(echo "$url" | cut -d: -f1)
    dir="$LIB/$remote/"
    mkdir -p "$dir"

    printf 'Running: %s copy --no-check-certificate --size-only -v --config %s "%s" "%s"\n' "$RCLONE" "$RCLONE_CONFIG" "$url" "$dir"
    "$RCLONE" copy --no-check-certificate --size-only -v --config "$RCLONE_CONFIG" "$url" "$dir"
  fi
done < "$USER_CONFIG"

# list file in lib dir after sync (name and size only, matching --size-only)
echo "New Library list"
lib_list_after=$(find "$LIB" -type f ! -name "*.log" -exec stat -c '%s %n' {} \; | sort)
echo "$lib_list_after"

# compare file list before and after
if [ "$lib_list_after" = "$lib_list_before" ]; then
  echo "No Library Change. skipping rescan"
else
  echo "Library has changed, rescan needed"

  # use NickelDBus for library refresh
  /usr/bin/qndb -t 3000 -s pfmDoneProcessing -m pfmRescanBooksFull
fi

rm "$LOGS/index" >/dev/null 2>&1
echo "$($DT) done"
