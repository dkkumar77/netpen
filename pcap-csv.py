import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

df = pd.read_csv('formatted.csv')

df.columns = df.columns.str.strip()

df['frame.time'] = pd.to_datetime(df['frame.time'], format='%H:%M:%S.%f', errors='coerce')
df = df.dropna(subset=['frame.time'])

df['time_hundredth'] = df['frame.time'].dt.round('100L')  
request_counts = df['time_hundredth'].value_counts().sort_index()
if not request_counts.empty:
    plt.figure(figsize=(12, 6))
    plt.plot(request_counts.index, request_counts.values, marker='o', linestyle='-', markersize=8)
    plt.xticks(rotation=90)
    plt.xlabel('Time (HH:MM:SS)')
    plt.ylabel('Number of Requests')
    plt.title('Requests per Hundredth of a Second')

    plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%H:%M:%S.%f'))
    plt.xlim([request_counts.index.min(), request_counts.index.max()])
    plt.grid(True)
    plt.tight_layout()
    plt.show()
else:
    print("No data to plot.")
