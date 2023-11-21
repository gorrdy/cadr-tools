#!/bin/bash
SCRIPT=`basename "$0"`

if [[ $UID != 0 ]]; then
    echo "Must be run as root. Please re-run this script as"
    echo "  sudo ./$SCRIPT"
    exit 1
fi

/usr/share/selfhost/lib/get_default_domain.sh && echo
