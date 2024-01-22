#!/bin/bash

# Extracts metrics from the worker metrics file
# unless provided as input
# then prints out the average value, leaving out the last entry

STATSFILE=$1

# log file does not exist - extract it from the worker's metrics
# and store it in 

if [ ! -f "$STATSFILE" ]; then
    input=$(ls -t /var/log/storm/workers-artifacts/ | head -n 1)
    mkdir -p stats
    STATSFILE=stats/$STATSFILE.log
    cat /var/log/storm/workers-artifacts/$input/6700/worker.log.metrics  | grep average_persec | grep -v received=0.0 > $STATSFILE
fi

total_received=0
count=0

echo "Parsing $STATSFILE"

while IFS= read -r log_line; do
    if [ -n "$log_line" ]; then
        received_value=$(echo -e "$log_line" | awk -F'received=' '{print $2}' | sed 's/[^0-9.]//g' | awk -F'.' '{print $1}')
        if [ -n "$received_value" ]; then
            total_received=$(awk "BEGIN{print $total_received + $received_value}")
            ((count++))
        fi
    fi
done < <(head -n -1 "$STATSFILE")


if [ "$count" -gt 0 ]; then
    average_received=$(awk "BEGIN{print $total_received / $count}")
    echo "Average Received value: $average_received"
else
    echo "No valid 'received' values found in the log file."
fi
