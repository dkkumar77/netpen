#!/bin/bash

for tool in nmap ping ; do
    if ! command -v $tool &> /dev/null
    then
        echo "$tool could not be found, please install it."
        exit
    fi
done

LOGFILE="tkl.log"
REPORT="tks_report.txt"
touch $LOGFILE $REPORT

log() { 
   echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}


read -sp "Enter admin password: " sup
echo
echo "$sup" | sudo -S true &> /dev/null

if [ $? -eq 0 ]; then
    echo
else
    echo "Incorrect password"
    exit 1
fi

log "Penetration Testing started"

printf "\nToolkit Tool-List\n"
echo "==============="
echo "1. DNS Lookup"
echo "2. Ping Test"
echo "3. VB Check"
echo "4. DNS Records"
echo "5. Exit"
read -p "Choose - " option

case $option in 
    1)
        read -p "Enter domain." web
        log "Checking DNS records."
        nslookup $web | tee -a $LOGFILE
        ;;
    2)
        read -p "Enter IP address" ip
        log "Testing Ping"
        ping $ip -c 5 | tee -a $LOGFILE
        ;;
        
esac
