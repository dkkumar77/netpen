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
ACT_LOG="activity.log"

touch $LOGFILE $ACT_LOG

# Fetches IP address from ifconfig.
get_ip_address() {
    ifconfig | awk '/^[a-zA-Z0-9]/ { iface=$1 } $1 == "inet" && $2 !~ /^127/ { print iface ": " $2 }'
}

# Visuals
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'



function sig_handler {
    echo -e "\nNow exiting, thank you for using"
    echo -e "$(whoami) had a succesful logoff on $(date '+%Y-%m-%d %H:%M:%S')" >> activity.log  
    
    exit;
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

trap sig_handler SIGINT

echo -e "$(whoami) had a successful login on $(date '+%Y-%m-%d %H:%M:%S') " >> activity.log

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
    echo -e "\033[32m6. Nmap Toolkit\033[0m"
    echo -e "\033[32m7. Port Analyzer\033[0m"
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
                                rm formatted.csv output.csv

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
            echo -e "\033[32m\t\t2.) Run OS scan on network\033[0m"
            echo -e "\033[32m\t\t2.) Vulnerable Ports\033[0m"


            read -p "Choose Selection: " nmapvar

            case $nmapvar in
                1)
                    log "Running Port Scan on 1-1024" 
                    nmap -p1-1024 -v --open 127.0.0.1 | tee -a $LOGFILE
                    ;;
                2)
                    chmod +x portscan.sh
                    sudo ./portscan.sh
                    ;;
                3)
                    python3 vul_port.py
                    ;;
                *)
                    ;;
            esac
            ;;
        7)
            echo "Executing prockiller script..."  
            if [ -x "./prockiller.sh" ]; then
                ./prockiller.sh
            else
                echo "Error: prockiller is not executable or not found."
            fi
            ;;
        
        10)
            echo "Exiting..."
            exit 0
            ;;
        clear)
            clear
            ;;
        q)
            echo -e "$(whoami) had a succesful logoff on $(date '+%Y-%m-%d %H:%M:%S') " >> activity.log

            exit
            ;;
       
        help)
            echo -e "\n\n\033[1;34mToolkit Help - Detailed Guide\033[0m"
            echo -e "\033[1;34m====================================================================\033[0m"
            echo -e "\033[1;34mDescription:\033[0m"
            echo -e "\033[1;32mThis toolkit provides a streamlined interface for executing complex\033[0m"
            echo -e "\033[1;32mnetwork troubleshooting commands. It's designed to simplify tasks\033[0m"
            echo -e "\033[1;32msuch as IP management, DNS lookups, packet analysis, and port scanning,\033[0m"
            echo -e "\033[1;32mby offering a menu-driven approach. Each tool within the toolkit\033[0m"
            echo -e "\033[1;32mis tailored for specific networking needs, ensuring efficiency\033[0m"
            echo -e "\033[1;32mand precision in your daily network management tasks.\033[0m"
            echo -e "\033[1;34m====================================================================\033[0m"

            echo -e "\033[1;34mFeatures:\033[0m"
            echo -e "\033[1;33m1. IP Flush:\033[0m"
            echo -e "\033[1;37m   - Description: Disables and re-enables your network interface,\033[0m"
            echo -e "\033[1;37m     effectively refreshing your IP address.\033[0m"
            echo -e "\033[1;37m   - Use Case: Helpful when you need to obtain a new IP address\033[0m"
            echo -e "\033[1;37m     without rebooting your system or router.\033[0m"
            
            echo -e "\033[1;33m2. DNS Lookup:\033[0m"
            echo -e "\033[1;37m   - Description: Performs a DNS lookup for a specified domain,\033[0m"
            echo -e "\033[1;37m     returning its IP address and other DNS records.\033[0m"
            echo -e "\033[1;37m   - Use Case: Useful for verifying domain resolution or troubleshooting\033[0m"
            echo -e "\033[1;37m     DNS-related issues.\033[0m"
            
            echo -e "\033[1;33m3. Ping Test:\033[0m"
            echo -e "\033[1;37m   - Description: Tests the connectivity to a specific IP address\033[0m"
            echo -e "\033[1;37m     by sending ICMP echo requests (pings).\033[0m"
            echo -e "\033[1;37m   - Use Case: Helps determine whether a host is reachable and\033[0m"
            echo -e "\033[1;37m     measures the round-trip time of the packets.\033[0m"
            
            echo -e "\033[1;33m4. TCPDump Toolkit:\033[0m"
            echo -e "\033[1;37m   - Description: A suite of tools for capturing and analyzing\033[0m"
            echo -e "\033[1;37m     network traffic using tcpdump.\033[0m"
            echo -e "\033[1;37m   - Options:\033[0m"
            echo -e "\033[1;37m     a. Available NIC's: Lists all available network interfaces.\033[0m"
            echo -e "\033[1;37m     b. Run 50 Packet Dump: Captures 50 packets based on a specified\033[0m"
            echo -e "\033[1;37m        protocol or all traffic. Option to save packets in pcap format.\033[0m"
            echo -e "\033[1;37m     c. Packets from Source: Filters and captures packets originating\033[0m"
            echo -e "\033[1;37m        from a specified source IP.\033[0m"
            echo -e "\033[1;37m     d. Packets from Dest: Filters and captures packets destined\033[0m"
            echo -e "\033[1;37m        for a specified destination IP.\033[0m"
            
            echo -e "\033[1;33m5. Clear:\033[0m"
            echo -e "\033[1;37m   - Description: Clears the terminal screen to remove clutter.\033[0m"
            echo -e "\033[1;37m   - Use Case: Useful for maintaining a clean workspace, especially\033[0m"
            echo -e "\033[1;37m     during extended troubleshooting sessions.\033[0m"
            
            echo -e "\033[1;33m6. NMAP Toolkit:\033[0m"
            echo -e "\033[1;37m   - Description: Provides a set of tools for scanning and analyzing\033[0m"
            echo -e "\033[1;37m     open ports on a network using Nmap.\033[0m"
            echo -e "\033[1;37m   - Options:\033[0m"
            echo -e "\033[1;37m     a. Run port scan on fixed ports: Scans ports 1-1024 on the local\033[0m"
            echo -e "\033[1;37m        machine to identify open services and potential vulnerabilities.\033[0m"

            echo -e "\033[1;33m7. Port Analyzer:\033[0m"
            echo -e "\033[1;37m   - Description: Executes a script to analyze processes associated\033[0m"
            echo -e "\033[1;37m     with specific ports and provides an option to terminate them.\033[0m"
            echo -e "\033[1;37m   - Use Case: Essential for identifying and managing services that\033[0m"
            echo -e "\033[1;37m     are occupying important ports, especially during conflict resolution.\033[0m"

            echo -e "\033[1;34m====================================================================\033[0m"
            echo -e "\033[1;34mUsage Instructions:\033[0m"
            echo -e "\033[1;32m1. Select an Option:\033[0m"
            echo -e "\033[1;37m   - At the menu prompt, enter the number corresponding to the tool\033[0m"
            echo -e "\033[1;37m     you wish to use. For example, to perform a DNS lookup, you would\033[0m"
            echo -e "\033[1;37m     type '2' and press Enter.\033[0m"
            
            echo -e "\033[1;32m2. Follow the Prompts:\033[0m"
            echo -e "\033[1;37m   - After selecting a tool, you may be asked to provide additional\033[0m"
            echo -e "\033[1;37m     information, such as a domain name or IP address. Follow the prompts\033[0m"
            echo -e "\033[1;37m     to enter the required details.\033[0m"
            
            echo -e "\033[1;32m3. Review the Output:\033[0m"
            echo -e "\033[1;37m   - The toolkit will display the results of your chosen command\033[0m"
            echo -e "\033[1;37m     directly in the terminal. The output will also be logged to the\033[0m"
            echo -e "\033[1;37m     specified log file for later review.\033[0m"
            
            echo -e "\033[1;34m====================================================================\033[0m"
            echo -e "\033[1;34mAdditional Commands:\033[0m"
            echo -e "\033[1;32m- clear:\033[0m"
            echo -e "\033[1;37m   - Clears the terminal screen.\033[0m"
            echo -e "\033[1;32m- q:\033[0m"
            echo -e "\033[1;37m   - Quits the toolkit and logs off the user.\033[0m"
            echo -e "\033[1;32m- help:\033[0m"
            echo -e "\033[1;37m   - Displays this detailed help information.\033[0m"
            echo -e "\033[1;34m====================================================================\033[0m"
            echo -e "\033[1;34mConclusion:\033[0m"
            echo -e "\033[1;32mThis toolkit is designed to make your network troubleshooting more\033[0m"
            echo -e "\033[1;32mefficient by encapsulating complex commands into a simple interface.\033[0m"
            echo -e "\033[1;32mWith features that cover a wide range of network management tasks,\033[0m"
            echo -e "\033[1;32mthis toolkit is your go-to tool for maintaining a secure and stable\033"
            echo -e "\033[1;32mnetwork environment. We hope you find it valuable for your daily\033[0m"
            echo -e "\033[1;32mtasks and troubleshooting needs. If you encounter any issues or have\033[0m"
            echo -e "\033[1;32msuggestions for improvements, please don't hesitate to reach out.\033[0m"
            echo -e "\033[1;34m====================================================================\033[0m"
            echo -e "\033[1;34mThank you for using the Toolkit!\033[0m"
            echo -e "\033[1;34m====================================================================\033[0m"
            
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done
