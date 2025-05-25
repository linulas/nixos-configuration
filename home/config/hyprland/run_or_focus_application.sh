#!/bin/sh

APP_NAME_SEARCH="$1"
APP_LAUNCH_CMD_OVERRIDE="$2" # optional if launch command differs to much from class

if [ -z "$APP_NAME_SEARCH" ]; then
  echo "Usage: $0 <application_class_name>"
  echo "  Example: $0 kitty"
  echo "  Example: $0 firefox"
  exit 1
fi

# Determine the actual command to use for launching the application.
# If APP_LAUNCH_CMD_OVERRIDE ($2) is set and not empty, use it.
# Otherwise (if $2 is not provided or is an empty string), use APP_NAME_SEARCH ($1).
LAUNCH_COMMAND="${APP_LAUNCH_CMD_OVERRIDE:-$APP_NAME_SEARCH}"

if hyprctl clients | grep -q "class:.$APP_NAME_SEARCH"; then
  echo "App '$APP_NAME_SEARCH' is running. Switching to its workspace and focusing."

  WORKSPACE_ID=$(hyprctl clients | grep "class..$APP_NAME_SEARCH" -B4 | grep 'workspace:' | sort | uniq | head -n 1 | sed -e 's/.*: //g' -e 's/ .*//g')

  if [ -n "$WORKSPACE_ID" ]; then
    hyprctl dispatch workspace "$WORKSPACE_ID"

    hyprctl dispatch focuswindow "class:^(.*$APP_NAME_SEARCH.*)$"
  else
    # This might happen if the app was detected but its workspace ID couldn't be parsed.
    echo "Warning: '$APP_NAME_SEARCH' is running, but could not determine its workspace. Attempting to focus by class only."
    # Try to focus anyway - focuswindow might find it across workspaces or if it's on the current one.
    if ! hyprctl dispatch focuswindow "class:^(.*$APP_NAME_SEARCH.*)$"; then
        echo "Error: Failed to focus '$APP_NAME_SEARCH' even though it was detected."
    fi
  fi
else
  echo "App '$APP_NAME_SEARCH' is not running. Launching via hyprctl..."
  hyprctl dispatch exec "$LAUNCH_COMMAND"
fi

exit 0
