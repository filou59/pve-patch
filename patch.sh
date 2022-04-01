#!/usr/bin/env bash

#mkdir -p /usr/share/pve-patch/{images,scripts}
mkdir -p /usr/share/pve-patch/scripts
echo "- patch `pveversion`..."
echo "- download and copy files..."

//wget -nc -qP /usr/share/pve-patch/images/ https://github.com/filou59/pve-patch/raw/master/images/{favicon.ico,logo-128.png,proxmox_logo.png}
rm -f /usr/share/pve-patch/scripts/{90pvepatch,apply.sh}
wget -qP /usr/share/pve-patch/scripts/ https://raw.githubusercontent.com/filou59/pve-patch/master/scripts/{90pvepatch,apply.sh}

# We want to overwrite so updates work seamlessly if script updated.
#wget -O /usr/share/pve-patch/scripts/90pvepatch https://gitlab.com/filou59/proxmox-no-subscription-repository-pve-patch/-/raw/master/scripts/90pvepatch
#wget -O /usr/share/pve-patch/scripts/apply.sh https://gitlab.com/filou59/proxmox-no-subscription-repository-pve-patch/-/raw/master/scripts/apply.sh

chmod -R a+x /usr/share/pve-patch/scripts
cp -f /usr/share/pve-patch/scripts/90pvepatch /etc/apt/apt.conf.d/90pvepatch
/usr/share/pve-patch/scripts/apply.sh

echo "- done!"
