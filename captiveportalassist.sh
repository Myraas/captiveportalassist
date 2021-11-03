#!/bin/bash

counter=0
gateway=''

timer(){
    while [ "$gateway" = '' ]; do
        gateway=$(route get default | grep gateway | awk '{print $2}')
        sleep 1
    done
    open -a "Google Chrome" http://"$gateway"
    while [ $counter -lt 100 ]; do
     n=$(curl -m 4 http://www.msftncsi.com/ncsi.txt)
     if [ "$n" = "Microsoft NCSI" ]; then
        echo "Connection established"
		echo "Reconfiguring DNS to static entries"
		networksetup -setdnsservers Wi-Fi 1.1.1.1 8.8.8.8
        exit 0
     else
        echo "Connection failed"
        counter=$((counter + 1))
        sleep 2
     fi
    done
}

if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
    echo "Connection established"
    echo "Reconfiguring DNS to static entries"
	networksetup -setdnsservers Wi-Fi 1.1.1.1 8.8.8.8
else
    echo "No connection, acquiring DNS from DHCP"
    networksetup -setdnsservers Wi-Fi Empty
    sleep 1
    if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
        echo "Connection established"
		echo "Reconfiguring DNS to static entries"
        networksetup -setdnsservers Wi-Fi 1.1.1.1 8.8.8.8
        exit 0
    else
        echo "Connection failed"
        echo "Starting timer"
        timer
        echo "Could not establish a connection"
		exit 1
    fi
fi
