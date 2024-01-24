#!/bin/bash

SCRIPT=`basename "$0"`

if [[ $UID != 0 ]]; then
    echo "Must be run as root. Please re-run this script as"
    echo "sudo ./$SCRIPT"
    exit 1
fi

#check the version of Debian. If bullseye or higher, stop the upgrade script
. /etc/os-release

if [[ $VERSION_ID -ge 11 ]]; then
    echo "The debian version is already up to date - $VERSION"
    exit 0
fi

apt update
apt dist-upgrade -y
apt autoremove --purge
apt clean

systemctl stop lnd-system-mainnet

sed -i 's/buster\/updates/bullseye-security/g' /etc/apt/sources.list
sed -i 's/10\/prod buster/11\/prod bullseye/g' /etc/apt/sources.list
sed -i 's/buster/bullseye/g' /etc/apt/sources.list

sed -i 's/buster\/updates/bullseye-security/g' /etc/apt/sources.list.d/*
sed -i 's/10\/prod buster/11\/prod bullseye/g' /etc/apt/sources.list.d/*
sed -i 's/buster/bullseye/g' /etc/apt/sources.list.d/*

apt update
apt dist-upgrade -y

systemctl start lnd-system-mainnet

pg_dropcluster --stop 13 main
pg_upgradecluster 11 main
pg_dropcluster --stop 11 main

apt autoremove --purge -y
apt clean

reboot