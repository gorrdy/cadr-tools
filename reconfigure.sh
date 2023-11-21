#!/bin/bash
SCRIPT=`basename "$0"`

if [[ $UID != 0 ]]; then
    echo "Must be run as root. Please re-run this script as"
    echo "sudo ./$SCRIPT"
    exit 1
fi

APP=$1
if [[ "$APP" = "" ]]; then
    echo "App name not provided. Enter the app name as a parameter."
    echo "sudo ./$SCRIPT <APP_NAME>"
    exit 1
fi

dpkg-reconfigure $1