#! /usr/bin/env bash

# Title for notifications
TITLE="Package Updates"

echo "Last run: $(date)" >>~/Documents/paru_update.log

# Run paru to check for updates (simulate upgrade, suppress color)
UPDATE_OUTPUT=$(paru -Qu 2>&1)
EXIT_CODE=$?

# If no updates available
if [[ -z "$UPDATE_OUTPUT" ]]; then
  notify-send -u normal "$TITLE" "Your system is up to date!"
  exit 0
fi

# If updates are found and exit code is 0
if [[ $EXIT_CODE -eq 0 ]]; then
  UPDATE_COUNT=$(echo "$UPDATE_OUTPUT" | wc -l)
  notify-send -u critical "$TITLE" "$UPDATE_COUNT updates available via paru."
  exit 0
fi

# If an error occurred
notify-send -u critical "$TITLE" "Error checking for updates. Paru exited with code $EXIT_CODE. $UPDATE_OUTPUT"
exit 0
