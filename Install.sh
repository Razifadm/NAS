#!/bin/sh

# Download bin 
wget -O /usr/bin/nas \
https://raw.githubusercontent.com/Razifadm/3ModNssVpn/main/usr/bin/nas

# Bagi permission execute pada bin
chmod +x /usr/bin/nas

echo "NAS Installed"
# Padam skrip ini sendiri
rm -f "$0"
