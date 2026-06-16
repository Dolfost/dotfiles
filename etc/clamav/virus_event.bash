#!/bin/bash
PATH=/usr/bin
ALERT="Signature: '$CLAM_VIRUSEVENT_VIRUSNAME' in $CLAM_VIRUSEVENT_FILENAME"

# send an alert to all graphical users.
for ADDRESS in /run/user/*; do
    USERID=${ADDRESS#/run/user/}
    /usr/bin/sudo -u "#$USERID" DBUS_SESSION_BUS_ADDRESS="unix:path=$ADDRESS/bus" PATH=${PATH} \
        /usr/bin/notify-send -a clamav -u critical -i dialog-warning "󱎶 Virus found!" "$ALERT"
done
