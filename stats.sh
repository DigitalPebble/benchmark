#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 <CRAWLNAME> <STATSFILE> [LOGDIR]"
    exit 1
fi

CRAWLNAME=$1
STATSFILE=$2
LOGDIR=${3:-/var/log/storm/workers-artifacts/}

if [ -z "$CRAWLNAME" ] || [ -z "$STATSFILE" ]; then
    echo "Error: Both CRAWLNAME and STATSFILE must be provided."
    exit 1
fi

mkdir -p stats

log_file=stats/$STATSFILE.log

cat $LOGDIR/$CRAWLNAME/6700/worker.log.metrics  | grep average_persec | grep -v received=0.0 > $log_file

if [ ! -f "$log_file" ]; then
    echo "Error: File not found: $log_file"
    exit 1
fi

total_received=0
count=0

echo "Parsing $log_file"

while IFS= read -r log_line; do
    if [ -n "$log_line" ]; then
        received_value=$(echo -e "$log_line" | awk -F'received=' '{print $2}' | sed 's/[^0-9.]//g' | awk -F'.' '{print $1}')
        if [ -n "$received_value" ]; then
            total_received=$(awk "BEGIN{print $total_received + $received_value}")
            ((count++))
        fi
    fi
done < <(head -n -1 "$log_file")


if [ "$count" -gt 0 ]; then
    average_received=$(awk "BEGIN{print $total_received / $count}")
    echo "Average Received value: $average_received"
else
    echo "No valid 'received' values found in the log file."
fi
