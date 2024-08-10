#!/bin/bash

echo "Starting Cleanup"
mv *.pcap pcap 

for file in *; do  
    if [[ $file != "format.py" && $file != "pcap-csv.py" && $file != "setup.sh" && $file != "tkl.log" && $file != "netpen.sh" && $file != "cleaner.sh" && $file != "pcap" && $file != "prockiller.sh" ]]; then
        mv "$file" old/
    fi
done