#!/bin/bash

# Define paths
DATA_DIR="/usr/src/app/data"
WORKING_DIR="/usr/src/app"
COOKIES_PATH="${WORKING_DIR}/cookies.jar"
SETTINGS_PATH="${WORKING_DIR}/settings.json"

ln -s "${DATA_DIR}/cookies.jar" "${COOKIES_PATH}"
ln -s "${DATA_DIR}/settings.json" "${SETTINGS_PATH}"

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

wait_for_novnc

LOG_PATH="/usr/src/app/log.txt"

if [ ! -f $LOG_PATH ]; then
  touch $LOG_PATH
fi

tail -F $LOG_PATH &

python main.py "$VERBOSITY" "$@" --log 2>&1 | tee $LOG_PATH
