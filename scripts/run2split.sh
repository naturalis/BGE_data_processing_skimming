#!/bin/bash

# count sequences and filesizes of BGE plates and display mkdir and mv commands
# using BGE-platenumber and BOLD process IDs as dictionary

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

# Add entries in desired order
# add_entry "BGE00100" "BBIOP{1901..1995}-24"
# add_entry "BGE00101" "BBIOP{1996..2090}-24"
# add_entry "BGE00102" "BBIOP{2186..2280}-24"
# add_entry "BGE00103" "BBIOP{2091..2185}-24"
# add_entry "BGE00181" "BGENL{1711..1805}-24"
# add_entry "BGE00196" "BGENL{2661..2755}-24"
# add_entry "BGE00301" "BGSNL{951..1045}-24"
# add_entry "BGE00302" "BGSNL{1046..1140}-24"
# add_entry "BGE00303" "BGSNL{1141..1235}-24"
# add_entry "BGE00315" "BGSNL{2091..2185}-24"
# add_entry "BGE00413" "BGLIB{1046..1140}-24"
# add_entry "BGE00415" "BGLIB{1236..1330}-24"
# add_entry "BGE00416" "BGLIB{1426..1520}-24"
# add_entry "BGE00588" "BBIOP{1806..1900}-24"
# add_entry "BGE00589" "BBIOP{1711..1805}-24"
# add_entry "BGE00590" "BBIOP{1616..1710}-24"

# Add entries in desired order
add_entry "BGE00417"	"BGLIB{1521..1615}-24"
add_entry "BGE00418"	"BGLIB{1616..1710}-24"
add_entry "BGE00431"	"UNIFI{951..1045}-24"
add_entry "BGE00501"	"BSCRO00{1..10}24 BSCRO0{11..95}-24"
add_entry "BGE00414"	"BGLIB{1331..1425}-24"
add_entry "BGE00300"	"BGSNL{856..950}-24"
add_entry "BGE00193"	"BGENL{2471..2565}-24"
add_entry "BGE00432"	"UNIFI{1046..1140}-24"
add_entry "BGE00194"	"BGENL{2566..2660}-24"
add_entry "BGE00316"	"BGSNL{2186..2280}-24"
add_entry "BGE00320"	"BGSNH{381..475}-24"
add_entry "BGE00502"	"BSCRO0{96..99}-24 BSCRO{100..190}-24"
add_entry "BGE00105"	"BBIOP{2376..2470}-24"
add_entry "BGE00104"	"BBIOP{2281..2375}-24"
add_entry "BGE00188"	"BGENL{2851..2945}-24"
add_entry "BGE00191"	"BGENL{2281..2375}-24"


# First output the original count and size information
echo "# Original count and size information"
echo "# BGE_plate	Sample_range	Sample_count	Total_size"
echo "# ----------------------------------------"

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
    
    # Print the result with proper tab spacing
    printf "%s\t%s\t%s\t%s\n" "$key" "$range" "$count" "$total_size"
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

echo ""
echo "# Move BGE folder to top folder of BGE-input (not executed, for reference only)"
echo "# ----------------------------------------"
echo "mv BGE* /data/dick.groenenberg/BGE-input"