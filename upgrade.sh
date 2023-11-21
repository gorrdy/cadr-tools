#!/bin/bash
SCRIPT=`basename "$0"`

if [[ $UID != 0 ]]; then
    echo "Must be run as root. Please re-run this script as"
    echo "sudo ./$SCRIPT"
    exit 1
fi

apt update
apt dist-upgrade -y
