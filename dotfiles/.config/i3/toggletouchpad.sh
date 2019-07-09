#!/bin/bash

name=$(xinput list --name-only | grep TouchPad)
id=$(xinput --list --id-only "${name}")
devEnabled=$(xinput --list-props "${id}" | awk '/Device Enabled/{print !$NF}')
xinput --set-prop "${id}" 'Device Enabled' "${devEnabled}"
notify-send --icon computer "${name}" "Device Enabled = ${devEnabled}"
