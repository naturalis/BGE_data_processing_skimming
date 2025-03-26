#!/bin/bash

# Automate range extraction from BGE pool sheets.
# Note the pool sheet needs to be downloaded as csv.
# Make sure the first data in excel is on line 11 and
# the negative control is on line 106 (i.e. the excel
# sheet is properly formatted)
# the output should be:
# BGE-platenumber (=NC), first sample, last sample.

# usage:    BGE_range_extract.sh $1=BGE_pool_sheet.csv


# Input CSV file
INPUT_FILE="$1"

# Check if the file is provided and exists
if [ -z "$INPUT_FILE" ] || [ ! -f "$INPUT_FILE" ]; then
    echo "Usage: $0 <csv_file>"
    exit 1
fi

# Start from the initial lines and step by 96
LINES=(106 11 105)
STEP=96

# Read until the first empty line
while true; do
    OUTPUT=""
    for LINE in "${LINES[@]}"; do
        VALUE=$(sed -n "${LINE}p" "$INPUT_FILE" | cut -d',' -f4)
        # Stop if the line is empty
        if [ -z "$VALUE" ]; then
            exit 0
        fi
        OUTPUT+="$VALUE	"
    done
    # Remove trailing tab and print
    echo -e "${OUTPUT%\t}"
    # Increment line numbers by STEP
    for i in "${!LINES[@]}"; do
        LINES[$i]=$((LINES[$i] + STEP))
    done
done
