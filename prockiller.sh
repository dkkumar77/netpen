#!/bin/bash

sudo nmap -p 1-65535 localhost | grep "open" | awk '{print "\033[34m" $0 "\033[0m"}'

read -p "Enter port # for more details: " pc

echo -e "\033[34m$(lsof -i :$pc)\033[0m"
pid=$(lsof -i :$pc | grep LISTEN | awk '{print $2}')

if [ -z "$pid" ]; then
    echo "No process is listening on port $pc."
    exit 1
fi

read -p "Do you want to kill this process? (y/n): " kill_command

if [ "$kill_command" = "y" ] || [ "$kill_command" = "Y" ]; then
    echo -e "\033[31mNote: It is generally not safe to kill a process if you do not know what it does."
    echo -e "\033[31mKilling unknown processes can lead to service disruption, data loss, system instability, and security issues."
    echo -e "\033[31mPlease ensure you understand the role of the process before terminating it.\033[0m"
    read -p "Are you sure you want to kill this process? (y/n): " confirm

    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        sudo kill -9 $pid
        echo "Process $pid has been killed."
    else
        echo "Operation canceled."
    fi
else
    echo "Operation canceled."
fi
