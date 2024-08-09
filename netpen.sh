#!/bin/bash

#  Check for necessary tools and ensure they are installed.
#  Seperate .sh file will download dependencies
for tool in nmap ping tcpdump; do
    if ! command -v $tool &> /dev/null; then
        echo "$tool could not be found, please install it."
        exit 1
    fi
done

# Define log file and create them in case they don't exist
LOGFILE="tkl.log"
touch $LOGFILE $REPORT

# Fetcehs IP address from ifconfig.
get_ip_address() {
    ifconfig | awk '/^[a-zA-Z0-9]/ { iface=$1 } $1 == "inet" && $2 !~ /^127/ { print iface ": " $2 }'
}

inet=$(get_ip_address)

# Append information gathered onto $LOGFILE 
log() { 
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" | tee -a $LOGFILE
}
# Handles super user commands.
sudo -v
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        echo "You need to run this script with sudo."
        exit 1
    fi
}
check_sudo


# Visuals
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}              \n\n

                .======...        .--.        ...------.                
                  .==========-... -=--....-----------                   
                    ..=======================-----..                    
                       ..========......-=======..                       
                            ..-===.==.===-..                            
                      ....++++===..==..=======...                       
                    .++=++==++++. .==  .========-==.                    
                 ++++++++++..     .++.      ..==========.                
                  .=..            .++.            ..-.                  
                                  .++.                                  
                                  .++.                                  
                                  .++.                                   
                                  .++.              
                                  
                         __     _     ___             
                      /\ \ \___| |_  / _ \___ _ __    
                     /  \/ / _ \ __|/ /_)/ _ \ '_ \   
                    / /\  /  __/ |_/ ___/  __/ | | |_ 
                    \_\ \/ \___|\__\/    \___|_| |_(_)                                    

${NC}"                 



echo -e "\n\033[34mSystem Information\033[0m"
echo -e "\033[34mOperating System:\033[0m $(uname -s)"
echo -e "\033[34mOS Version:\033[0m $(uname -r)"
echo -e "\033[34mSystem Version:\033[0m $(sw_vers -productVersion)"
echo -e "\033[34mBuild Version:\033[0m $(sw_vers -buildVersion)\n"


log "Testing started"



while true; do
    printf "\nToolkit Tool-List\n"
    echo -e "===============\nIP Address Info\n$inet\n"

    echo -e "\033[32m1. IP Flush\033[0m"
    echo -e "\033[32m2. DNS Lookup\033[0m"
    echo -e "\033[32m3. Ping Test\033[0m"
    echo -e "\033[32m4. TCPDump toolkit\033[0m"
    echo -e "\033[32m5. Clear\033[0m"
    echo -e "\033[32m6. -------------\033[0m"
    echo -e "\033[32m10. Exit\033[0m"

    read -p "Choose - " option

    case $option in 

        1)
            sudo networksetup -setnetworkserviceenabled Wi-Fi off | tee -a $LOGFILE
            sleep 2
            sudo networksetup -setnetworkserviceenabled Wi-Fi on | tee -a $LOGFILE
            sleep 5
            inet=$(get_ip_address)
            log "New IP address info: $inet"
            ;;
        2)
            read -p "Enter domain: " web
            if [[ "$web" =~ ^[a-zA-Z0-9.-]+$ ]]; then
                log "Checking DNS records for $web."
                nslookup "$web" | tee -a $LOGFILE
            else
                echo "Invalid domain format"
            fi
            ;;
        3)
            read -p "Enter IP address: " ip
            if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                log "Testing Ping for $ip."
                ping "$ip" -c 5 | tee -a $LOGFILE
            else
                echo "Invalid IP address format"
            fi
            ;;
        4)
            echo -e "\033[32m+++++++++++\033[0m"
            echo -e "\033[32mTCP Toolkit\033[0m"
            echo -e "\033[32m+++++++++++\033[0m"
            echo -e "\033[32m1.) Available NIC's\033[0m"
            echo -e "\033[32m2.) Run 50 packet dump\033[0m"
            echo -e "\033[32m3.) Packets from Source\033[0m"
            echo -e "\033[32m4.) Packets from Dest\033[0m"
            read -p "Choose: " tcpvar
            case $tcpvar in
                1) 
                    sudo tcpdump -D | tee -a $LOGFILE
                    ;;
                      
                2)      
                    echo -e "\nWhat traffic are you looking for?\nExamples: http, https, arp, ftp, smtp, ssh (or 'all' for all protocols)"
                    read -p "? " trafproc

                    trafproc=$(echo "$trafproc" | tr '[:upper:]' '[:lower:]')

                    case $trafproc in
                        http)
                            filter="port 80"
                            ;;
                        https)
                            filter="port 443"
                            ;;
                        arp)
                            filter="arp"
                            ;;
                        ftp)
                            filter="port 21"
                            ;;
                        smtp)
                            filter="port 25"
                            ;;
                        ssh)
                            filter="port 22"
                            ;;
                        all)
                            filter=""
                            ;;
                        *)
                            echo "Invalid protocol"
                            continue
                            ;;
                    esac

                    echo -e "\033[31mDo you want to save to pcap file?"
                    read -p "Y/N: " opt
                    
                    case $opt in
                        Y|y)
                            if [ -z "$filter" ]; then
                                dummy="$(date +'%Y%m%d_%H%M%S').pcap"

                                timeout 20 sudo tcpdump -c 50 -i en0 -w "$dummy" | tee -a "$LOGFILE"

                                tshark -r "$dummy" -T fields -E header=y -E separator=, -E quote=d -e frame.number -e frame.time -e ip.src -e ip.dst -e tcp.port -e udp.port -e frame.len > output.csv

                                python3 format.py
                                python3 pcap-csv.py

                            else
                                dummy="$(date +'%Y%m%d_%H%M%S').pcap"

                                timeout 20 sudo tcpdump -c 50 -i en0 -w "$dummy" | tee -a "$LOGFILE"

                                tshark -r "$dummy" -T fields -E header=y -E separator=, -E quote=d -e frame.number -e frame.time -e ip.src -e ip.dst -e tcp.port -e udp.port -e frame.len > output.csv
                                python3 format.py
                                python3 pcap-csv.py
                            fi

                            ;;
                        N|n)
                            if [ -z "$filter" ]; then
                                timeout 20 sudo tcpdump -c 50 -i en0 | tee -a "$LOGFILE"
                                
                            else
                                timeout 20 sudo tcpdump -c 50 -i en0 "$filter" | tee -a "$LOGFILE"
                            fi
                            ;;
                        *)
                            echo "Invalid option"
                            ;;
                    esac
                    ;;
                  
                3)
                    read -p "Enter source IP: " src_ip
                    if [[ "$src_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                        sudo tcpdump src "$src_ip" | tee -a $LOGFILE
                    else
                        echo -e "\t\tInvalid IP address format"
                    fi
                    ;;
                4)
                    read -p "Enter destination IP: " dest_ip
                    if [[ "$dest_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                        sudo tcpdump dst "$dest_ip" | tee -a $LOGFILE
                    else
                        echo -e "\t\tInvalid IP address format"
                    fi
                    ;;
                *)
                    echo -e "\t\tInvalid option"
                    ;;
            esac
            ;;
        5)
            clear
            ;;
        6)
            echo -e "\033[32m\t\tNMAP TOOLKIT\033[0m"
            echo -e "\033[32m\t\t------------\033[0m"
            echo -e "\033[32m\t\t1.) Run port scan on fixed ports\033[0m"
            read -p "Choose Selection: " nmapvar

            case $nmapvar in
                1)
                    log "Running Port Scan on 1-1024" 
                    nmap -p1-1024 -v --open 127.0.0.1 | tee -a $LOGFILE
                    ;;
                *)
                    ;;
            esac
            ;;
        10)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done
