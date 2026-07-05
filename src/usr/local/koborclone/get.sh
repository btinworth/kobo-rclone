#!/bin/sh
# KoboRclone getter

RCLONE_VERSION="1.74.3"

# load config
. $(dirname $0)/config.sh
export USER_CONFIG

# check if KoboRclone contains the line "UNINSTALL"
if grep -q '^UNINSTALL$' $USER_CONFIG; then
  echo "Uninstalling KoboRclone!"
    $KC_HOME/uninstall.sh
    exit 0
fi

if grep -q "^REMOVE_DELETED$" $USER_CONFIG; then
	echo "$LIB/filesList.log" > "$LIB/filesList.log"
fi

# check internet connection
echo "`$DT` waiting for internet connection"
r=1;i=0
while [ $r != 0 ]; do
  if [ $i -gt 60 ]; then
    echo "`$DT` error! no connection detected"
    exit 1
  fi
  ping -c 1 -w 3 1.1.1.1 >/dev/null 2>&1
  r=$?
  if [ $r != 0 ]; then sleep 1; fi
  i=$(($i + 1))
done

# check for qbdb
if [ -f "/usr/bin/qndb" ]
then
  echo "NickelDBus found"
else
  echo "NickelDBus not found: installing it!"
  wget "https://github.com/shermp/NickelDBus/releases/download/0.2.0/KoboRoot.tgz" -O - | tar xz -C /
fi
if [ -f "${RCLONE}" ]
then
  echo "rclone found"
else
  echo "rclone not found: installing it!"
  mkdir -p "${RCLONE_DIR}"
  rcloneTemp="${RCLONE_DIR}/rclone.tmp.zip"
  rm -f "${rcloneTemp}"
  wget "https://github.com/rclone/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-arm-v7.zip" -O "${rcloneTemp}"
  unzip -p "${rcloneTemp}" rclone-v${RCLONE_VERSION}-linux-arm-v7/rclone > ${RCLONE}
  rm -f "${rcloneTemp}"
fi

# list file in lib dir before sync (name and size only, matching --size-only)
lib_list_before=$(find "$LIB" -type f ! -name "*.log" -exec stat -c '%s %n' {} \; | sort)
echo "Current Library list"
echo "$lib_list_before"

if grep -q "^REMOVE_DELETED$" $USER_CONFIG; then
  command="sync" # remove deleted, do a sync
else
  command="copy" # don't remove deleted, do a copy
fi

while read url || [ -n "$url" ]; do
  if echo "$url" | grep -q '^#'; then
    continue
  elif echo "$url" | grep -q "^REMOVE_DELETED$"; then
	  echo "Will delete files no longer present on remote"
  elif [ -n "$url" ]; then
    echo "Getting $url"
    remote=$(echo "$url" | cut -d: -f1)
    dir="$LIB/$remote/"
    mkdir -p "$dir"
    echo ${RCLONE} ${command} --no-check-certificate --size-only -v --config ${RCLONE_CONFIG} \"$url\" \"$dir\"
    ${RCLONE} ${command} --no-check-certificate --size-only -v --config ${RCLONE_CONFIG} "$url" "$dir"
  fi
done < $USER_CONFIG

# list file in lib dir after sync (name and size only, matching --size-only)
echo "New Library list"
lib_list_after=$(find "$LIB" -type f ! -name "*.log" -exec stat -c '%s %n' {} \; | sort)
echo "$lib_list_after"

# compare filelist before and after
if [ "$lib_list_after" = "$lib_list_before" ]
then
  echo "No Library Change. skipping rescan"
else
  echo "Library has changed, rescan needed"

  # use NickelDBus for library refresh
  /usr/bin/qndb -t 3000 -s pfmDoneProcessing -m pfmRescanBooksFull
fi

rm "$LOGS/index" >/dev/null 2>&1
echo "`$DT` done"
