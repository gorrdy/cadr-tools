#!/bin/bash

SCRIPT=`basename "$0"`

if [[ $UID != 0 ]]; then
    echo "Must be run as root. Please re-run this script as"
    echo "  sudo ./$SCRIPT"
    exit 1
fi

. /etc/os-release

id=$VERSION_ID
codename=$VERSION_CODENAME

apt install gpg -y

gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF

gpg --export 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C | apt-key add -
gpg --export BC528686B50D79E339D3721CEB3E94ADBE1229CF | apt-key add -

echo "deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/debian/$id/prod $codename main" | tee /etc/apt/sources.list.d/microsoft.list > /dev/null
echo "deb [signed-by=3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C] https://deb.ln-ask.me/beta $codename common local desktop" | tee /etc/apt/sources.list.d/cryptoanarchy.list > /dev/null

apt update
