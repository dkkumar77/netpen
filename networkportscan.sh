#!/bin/bash


function sig_handler(){
    exit;

}
# Check if nmap is installed
if ! command -v nmap > /dev/null 2>&1; then
    echo "nmap is not installed"
    exit 1
fi


trap sig_handler SIGINT
sudo nmap -sn 10.0.0.0/24 | awk '/Nmap scan report for/ {printf "IP: %s\n", $5} /MAC Address: / {printf "MAC: %s\n", $3}'
while true; do
    echo -e "\nInformation about host?"
    read -p "Enter IP Address (or type 'exit' to quit): " ipresolv

    if [[ "$ipresolv" == "exit" ]]; then
        echo "Exiting the script."
        break
    fi
    sudo nmap -O "$ipresolv" | tee -a tkl.log
done
