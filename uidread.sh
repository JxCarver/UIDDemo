#!/bin/bash

PM3="/home/jcarver/proxmark3/pm3"
PORT="/dev/ttyACM0"  

# JC's UID
INPUT_FILE="UID.txt"
DATA=`cat $INPUT_FILE`
# Loop forever
while true; do
    # Send command to Proxmark3
    OUTPUT=$(echo "hf search" | "$PM3" -p "$PORT")

    # Look for UID match
    echo "$INPUT_FILE"
    if echo "$OUTPUT" | grep -q "$DATA"; then
        echo "Access Granted"
        zenity --info --text="Launching  Missiles" --title="Access Granted"
        sleep 1
    else
        zenity --info --text="Access Denied" --title="Idiot"

        sleep 0.3
    fi
done


