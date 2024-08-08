#!/bin/bash

# Define paths
DATA_DIR="/usr/src/app/data"
WORKING_DIR="/usr/src/app"
COOKIES_PATH="${WORKING_DIR}/cookies.jar"
SETTINGS_PATH="${WORKING_DIR}/settings.json"

# Create symlinks for data files
ln -s "${DATA_DIR}/cookies.jar" "${COOKIES_PATH}"
ln -s "${DATA_DIR}/settings.json" "${SETTINGS_PATH}"

# Set default values for environment variables
: "${DISPLAY_WIDTH:=1024}"
: "${DISPLAY_HEIGHT:=768}"
: "${DISPLAY_DEPTH:=16}"
: "${VNC_PORT:=5900}"
: "${NOVNC_PORT:=8080}"
: "${LOG_LEVEL:=INFO}"

wait_for_novnc() {
  sleep 5
}

convert_log_level_to_verbosity() {
  case "$LOG_LEVEL" in
    WARN)
      echo "-v"
      ;;
    INFO)
      echo "-vv"
      ;;
    CALL)
      echo "-vvv"
      ;;
    DEBUG)
      echo "-vvvv"
      ;;
    *)
      echo "Invalid LOG_LEVEL: $LOG_LEVEL"
      exit 1
      ;;
  esac
}

VERBOSITY=$(convert_log_level_to_verbosity)

# Start Xvfb with the specified resolution
Xvfb :0 -screen 0 "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH}" &

# Start FluxBox window manager
fluxbox &

# Start VNC server
x11vnc -xkb -forever -nopw -display :0 -listen localhost &

# Start noVNC
/usr/share/novnc/utils/launch.sh --vnc localhost:$VNC_PORT --listen $NOVNC_PORT &

wait_for_novnc

LOG_PATH="/usr/src/app/log.txt"

if [ ! -f $LOG_PATH ]; then
  touch $LOG_PATH
fi

tail -F $LOG_PATH &

python main.py "$VERBOSITY" "$@" --log 2>&1 | tee $LOG_PATH