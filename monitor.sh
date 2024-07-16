#!/bin/bash

LOG_FILE="$1/eve.json"

BOT_TOKEN="BOT_TOKEN"
CHAT_ID="CHAT_ID"

# Running inotifywait to monitor changes in the file
inotifywait -m -e modify "$LOG_FILE" | while read -r directory events filename; do
  # Processing new lines
  tail -n 1 "$LOG_FILE" | while read -r line; do
    # Checking for the word "alert"
    if echo "$line" | grep -q "alert"; then
      # Sending a message to Telegram using curl
      curl -s -X POST https://api.telegram.org/bot$BOT_TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="$line"
    fi
  done
done
