#!/bin/bash

# count sequences and filesizes of BGE plates and display mkdir and mv commands
# using BGE-platenumber and BOLD process IDs as dictionary from input CSV file

# Check if a CSV file was provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <csv_file>"
    echo "CSV format should be: BGE_plate,Sample_range"
    echo "Example: BGE00417,BGLIB{1521..1615}-24"
    exit 1
fi
# STILL NEEDS TO BE TESTED IF LINE IN CSV WORKS LIKE
# add_entry "BGE00417"	"BGLIB{1521..1615}-24"
# IN THE PREVIOUS INCARNATION
# AND IF SPACES ARE NO ISSUE
# add_entry "BGE00501"	"BSCRO00{1..9}-24 BSCRO0{10..95}-24"
# example: "BGE00501,BSCRO00{1..9}-24 BSCRO0{10..95}-24"

CSV_FILE="$1"

# Check if the file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: CSV file '$CSV_FILE' not found"
    exit 1
fi

# Dictionary of ranges and an array to track order
declare -A my_dict
ordered_keys=()

# Define dictionary and capture keys in order
add_entry() {
    key=$1
    value=$2
    my_dict["$key"]="$value"
    ordered_keys+=("$key")
}

# Read entries from CSV file
while IFS=, read -r key value || [ -n "$key" ]; do
    # Skip empty lines and lines starting with #
    if [ -z "$key" ] || [[ "$key" == \#* ]]; then
        continue
    fi
    # Remove any trailing whitespace or carriage returns
    key=$(echo "$key" | tr -d '\r' | xargs)
    value=$(echo "$value" | tr -d '\r' | xargs)
    add_entry "$key" "$value"
done < "$CSV_FILE"

# Print table headers with printf for perfect alignment
printf "%-12s %-38s %-14s %-10s\n" "BGE_plate" "Sample_range" "Sample_count" "Total_size"
printf "%-12s %-38s %-14s %-10s\n" "----------" "----------" "------------" "----------"

# Loop over the ordered keys for count and size
for key in "${ordered_keys[@]}"; do
    range="${my_dict[$key]}"
    # Expand the range using eval and brace expansion
    expanded_range=$(eval echo "$range" | tr " " "|")
    # Run the ls -1 | egrep command
    matching_files=$(ls -1 | egrep "$expanded_range" 2>/dev/null || echo "")
    
    # Check if there are any matching files
    if [ -z "$matching_files" ]; then
        count=0
        total_size="0"
    else
        count=$(echo "$matching_files" | wc -l)
        # Only calculate size if we have matches
        total_size=$(echo "$matching_files" | xargs du -hc 2>/dev/null | grep total | awk '{print $1}')
        # If for some reason total_size is empty, set it to 0
        total_size=${total_size:-0}
    fi
    
    # Print the result with proper column alignment
    printf "%-12s %-38s %-14s %-10s\n" "$key" "$range" "$count" "$total_size"
done

echo ""
echo "# Directory creation command (not executed, for reference only)"
echo "# ----------------------------------------"

# Build the mkdir command dynamically
mkdir_command="mkdir -p"
for key in "${ordered_keys[@]}"; do
    mkdir_command+=" $key"
done
echo "$mkdir_command"

echo ""
echo "# Move commands (not executed, for reference only)"
echo "# ----------------------------------------"

# Loop over the ordered keys for mv commands
for key in "${ordered_keys[@]}"; do
    range="${my_dict[$key]}"
    echo "mv \$(ls -1 | egrep \$(echo $range | tr \" \" \"|\")) $key"
done

echo ""
echo "# NC prefix move commands (not executed, for reference only)"
echo "# ----------------------------------------"

# Loop over the ordered keys for NC prefix move commands
for key in "${ordered_keys[@]}"; do
    echo "mv *NC-$key $key"
done

echo ""
echo "# Copy checksums to the BGE subdirs (not executed, for reference only)"
echo "# ----------------------------------------"

# Loop over the ordered keys for copying checksums
for key in "${ordered_keys[@]}"; do
    if [ -d "$key" ]; then
        echo "cp checksums* $key/"
    else
        echo "Directory $key does not exist. Skipping."
    fi
done