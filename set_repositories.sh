#!/bin/bash

. /etc/os-release

id=$VERSION_ID
codename=$VERSION_CODENAME

gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF

gpg --export 3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C | sudo apt-key add -
gpg --export BC528686B50D79E339D3721CEB3E94ADBE1229CF | sudo apt-key add -

echo "deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/debian/$id/prod bullseye main" | sudo tee /etc/apt/sources.list.d/microsoft.list > /dev/null
echo "deb [signed-by=3D9E81D3CA76CDCBE768C4B4DC6B4F8E60B8CF4C] https://deb.ln-ask.me/beta $codename common local desktop" | sudo tee /etc/apt/sources.list.d/cryptoanarchy.list > /dev/null

sudo apt update
