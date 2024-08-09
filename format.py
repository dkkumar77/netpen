import csv
from datetime import datetime

with open('output.csv', 'r') as infile, open('formatted.csv', 'w', newline='') as outfile:
    reader = csv.reader(infile)
    writer = csv.writer(outfile)
    
    header = next(reader)
    writer.writerow(header)
    
    for row in reader:
        timestamp = row[1].replace(' EDT', '')
        
        if '.' in timestamp:
            timestamp = timestamp.split('.')[0] + '.' + timestamp.split('.')[1][:2]
        else:
            timestamp = timestamp + '.00'
        
        try:
            dt = datetime.strptime(timestamp, "%b %d, %Y %H:%M:%S.%f")
            
            formatted_time = dt.strftime("%H:%M:%S.%f")[:-3] 
        except ValueError:
            formatted_time = timestamp
        
        row[1] = formatted_time
        writer.writerow(row)
