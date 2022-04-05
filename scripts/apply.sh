#!/usr/bin/env bash

# -----------------ENVIRONNEMENT VARIABLES----------------------
DEBIAN_CODENAME=`cat /etc/os-release | grep VERSION_CODENAME | cut -d "=" -f2`
ENTERPRISE_REPO_LIST="/etc/apt/sources.list.d/pve-enterprise.list"
FREE_REPO_LIST="/etc/apt/sources.list.d/pve.list"
FREE_REPO_LINE="deb http://download.proxmox.com/debian/pve $DEBIAN_CODENAME pve-no-subscription"
JSLIBFILE="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"

pve_log_folder="/var/log/pve/tasks/"
proxmoxlib="/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js"

# ---------------END OF ENVIRONNEMENT VARIABLES-----------------

function pve_patch() {
	echo "- apply patch..."
	echo $FREE_REPO_LINE > $FREE_REPO_LIST
	[ -f $ENTERPRISE_REPO_LIST ] && mv $ENTERPRISE_REPO_LIST $ENTERPRISE_REPO_LIST~
  
	# (6.1 and up)
	#sed -i.backup "s/data.status !== 'Active'/false/g" ${proxmoxlib}
	# (6.2-11 and up)
	#sed -i.backup -z "s/res === null || res === undefined || \!res || res\n\t\t\t.false/false/g" ${proxmoxlib}
	# (6.2-12 and up)
	#sed -i.backup -z "s/res === null || res === undefined || \!res || res\n\t\t\t.data.status \!== 'Active'/false/g" ${proxmoxlib}
  
	# (6.2-15 6.3-2 6.3-3 6.3-4 6.3-6 6.3-7 6.4-4 6.4-5 6.4-6 6.4-7 and up)
	# Proxmox 7.1.7 and Up
	#if grep -q ".data.status.toLowerCase() == 'active') {" $proxmoxlib; then
	#	echo "- Subscription Message already removed - Skipping"
	#else
	if [ -d "$pve_log_folder" ]; then
		result=$( grep -B 1 'No valid sub' $proxmoxlib | grep -i 'void' )
		#echo "Result" $result
    if [ -n "$result" ]; then      
      echo "- Removing No Valid Subscription Message Already Done"
    else  
      echo "- Removing No Valid Subscription Message for PVE"
      sed -Ezi.bak "s/(Ext.Msg.show\(\{\s+title: gettext\('N   o valid sub)/void\(\{ \/\/\1/g" ${proxmoxlib} && systemctl restart pveproxy.service      
    fi  
		#sed -Ezi.bak "s/!== 'active'/== 'active'/" $proxmoxlib && echo "- Restarting proxy service" && systemctl restart pveproxy.service
		#sed -i.bak -z "s/res === null || res === undefined || \!res || res\n\t\t\t.data.status.toLowerCase() \!== 'active'/false/g" ${proxmoxlib}
		
	else 
		echo "- Removing No Valid Subscription Message for PBS"
		sed -Ezi.bak "s/!== 'active'/== 'active'/" $proxmoxlib && echo "- Restarting proxy service" && systemctl restart proxmox-backup-proxy.service
	fi
	#fi

	#systemctl restart pveproxy.service
  
	# pvedarkdiscord theme: courtesy of https://github.com/Weilbyte/PVEDiscordDark
	#bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh ) install
	#systemctl restart pveproxy.service
}

pve_patch
