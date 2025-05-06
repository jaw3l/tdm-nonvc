#!/bin/bash

set -e
set -u

log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

handle_error() {
  local exit_code=$?
  log "Error occured in line $1 with exit code $exit_code"
  exit $exit_code
}

trap 'handle_error $LINENO' ERR

# Define paths
DATA_DIR="/usr/src/app/data"
WORKING_DIR="/usr/src/app"
COOKIES_PATH="${WORKING_DIR}/cookies.jar"
SETTINGS_PATH="${WORKING_DIR}/settings.json"

# Create symlinks for data files only if they don't already exist
if [ ! -e "${COOKIES_PATH}" ]; then
  log "Creating symlinks for cookies.jar"
  ln -s "${DATA_DIR}/cookies.jar" "${COOKIES_PATH}" || {
    log "Failed to create symlink for cookies.jar"
    exit 1
  }
fi

if [ ! -e "${SETTINGS_PATH}" ]; then
  ln -s "${DATA_DIR}/settings.json" "${SETTINGS_PATH}"
fi

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
x11vnc -xkb -forever -nopw -display :0 -listen localhost -ncache 10 &

# Start noVNC
/usr/share/novnc/utils/novnc_proxy --vnc localhost:"$VNC_PORT" --listen "$NOVNC_PORT" --web /usr/share/novnc --file-only &

wait_for_novnc

LOG_PATH="/usr/src/app/log.txt"

if [ ! -f $LOG_PATH ]; then
  touch $LOG_PATH
fi

tail -F $LOG_PATH &

while true; do
  start_time=$(date +%s)
  while true; do
    python main.py "$VERBOSITY" "$@" --log 2>&1 | tee $LOG_PATH | while read -r line; do
      echo "$line"
      if echo "$line" | grep -q -E '((Websocket)[[\]][0][[\]].?((connection problem)|(stopped)))'; then
        log "Detected error message. Restarting application..."
        break 2
      fi
    done

    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))
    if [ $elapsed_time -ge 21600 ]; then
      log "6 hours elapsed. Restarting application..."
      break
    fi
    sleep 5
  done
done
