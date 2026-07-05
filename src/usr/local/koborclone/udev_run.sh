#!/bin/sh

# udev kills slow scripts
if [ "$SETSID" != "1" ]; then
    SETSID=1 setsid "$0" "$@" &
    exit
fi

# load config
. "$(dirname "$0")/config.sh"

# run the main script and redirect output to log
"$KC_HOME/run.sh" > "$LOGS/log.txt" 2>&1 &
