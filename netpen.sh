#!/bin/bash

for tool in nmap ping tcpdump ; do
    if ! command -v $tool &> /dev/null
    then
        echo "$tool could not be found, please install it."
        exit 1
    fi
done

LOGFILE="tkl.log"
REPORT="tks_report.txt"
touch $LOGFILE $REPORT

log() { 
   echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}

sudo -v

check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        echo "You need to run this script with sudo."
        exit 1
    fi
}

check_sudo

log "Penetration Testing started"

while true; do
    printf "\nToolkit Tool-List\n"
    echo "==============="
    echo "1. DNS Lookup"
    echo "2. Ping Test"
    echo "3. TCPDump toolkit"
    echo "4. Clear"
    echo "5. Exit"
    read -p "Choose - " option

    case $option in 
        1)
            read -p "Enter domain: " web
            if [[ "$web" =~ ^[a-zA-Z0-9.-]+$ ]]; then
                log "Checking DNS records for $web."
                nslookup "$web" | tee -a $LOGFILE
            else
                echo "Invalid domain format"
            fi
            ;;
        2)
            read -p "Enter IP address: " ip
            if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                log "Testing Ping for $ip."
                ping "$ip" -c 5 | tee -a $LOGFILE
            else
                echo "Invalid IP address format"
            fi
            ;;
        3)
            echo
            echo "+++++++++++"
            echo "TCP Toolkit"
            echo "+++++++++++"
            echo "1.) Available NIC's"
            echo "2.) Run 50 packet dump"
            echo "3.) Packets from Source"
            echo "4.) Packets from Dest"
            read -p "Choose: " tcpvar
            case $tcpvar in
                1) 
                    sudo tcpdump -D | tee -a $LOGFILE
                    ;;
                2)      
                    sudo tcpdump -c 50 -i en0 | tee -a $LOGFILE
                    ;;
                3)
                    read -p "Enter source IP: " src_ip
                    if [[ "$src_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                        sudo tcpdump src "$src_ip" | tee -a $LOGFILE
                    else
                        echo "Invalid IP address format"
                    fi
                    ;;
                4)
                    read -p "Enter destination IP: " dest_ip
                    if [[ "$dest_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                        sudo tcpdump dst "$dest_ip" | tee -a $LOGFILE
                    else
                        echo "Invalid IP address format"
                    fi
                    ;;
                *)
                    echo "Invalid option"
                    ;;
            esac
            ;;
        4)
            clear
            ;;

        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done
