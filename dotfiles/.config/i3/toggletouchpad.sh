#!/bin/bash

devices=$(xinput list --id-only)
for device in ${devices}
do
    devpath=$(xinput list-props "${device}" | grep "Device Node" | awk 'NF>1{print $NF}')
    devpath=${devpath:1:-1}
    if udevadm info "${devpath}" -q property 2> /dev/null | grep ID_INPUT_TOUCHPAD > /dev/null; then
        dev_name=$(xinput list --name-only "${device}")
        dev_enabled=$(xinput --list-props "${device}" | grep "Device Enabled" | awk 'NF>1{print $NF}')
        if [[ ${dev_enabled} -eq 1 ]]; then
            xinput disable "${device}"
            notify-send "${dev_name} (id=${device})" "Device Disabled"
        else
            xinput enable "${device}"
            notify-send "${dev_name} (id=${device})" "Device Enabled"
        fi
        break
    fi
done
