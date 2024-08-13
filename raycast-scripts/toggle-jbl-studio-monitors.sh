#!/bin/bash

# Raycast Script Command Template
#
# Duplicate this file and remove ".template." from the filename to get started.
# See full documentation here: https://github.com/raycast/script-commands
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle JBL Studio Monitors
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🤖
# @raycast.packageName Raycast Scripts

curl -s -X POST \
    -H "Authorization: Bearer $(op read 'op://Dev/Lab K8S homelab/HOME_ASSISTANT_API_TOKEN_FOR_CONFIG_RELOAD')" \
    -H "Content-Type: application/json" \
    --data '{"entity_id": "switch.den_wipro_jbl_studio_monitors_socket"}' \
    http://homelab-nas.home.lan:8123/api/services/switch/toggle

echo "Toggled JBL Studio Monitors"
