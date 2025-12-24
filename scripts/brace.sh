#!/usr/bin/env bash

# Function to generate brace expansion from a list of items
generate_brace_expansion() {
    local input="$1"
    
    # Sort the input items
    local sorted=$(echo "$input" | tr ' ' '\n' | sort -V | tr '\n' ' ')
    
    # Extract prefix and suffix pattern, and numeric parts
    declare -A groups
    
    for item in $sorted; do
        # Match pattern: PREFIX + NUMBERS + SUFFIX
        if [[ $item =~ ^([^0-9]*)([0-9]+)(.*)$ ]]; then
            prefix="${BASH_REMATCH[1]}"
            number="${BASH_REMATCH[2]}"
            suffix="${BASH_REMATCH[3]}"
            key="${prefix}|${suffix}"
            
            # Store numbers for each prefix-suffix combination
            if [[ -z "${groups[$key]}" ]]; then
                groups[$key]="$number"
            else
                groups[$key]="${groups[$key]} $number"
            fi
        fi
    done
    
    # Generate brace expansions for each group
    declare -A standalone_items
    local all_ranges=()
    
    for key in "${!groups[@]}"; do
        IFS='|' read -r prefix suffix <<< "$key"
        numbers=(${groups[$key]})
        
        # Sort numbers numerically
        IFS=$'\n' numbers=($(sort -n <<<"${numbers[*]}"))
        unset IFS
        
        # Find consecutive ranges, splitting when crossing magnitude boundaries
        local start=${numbers[0]}
        local prev=${numbers[0]}
        
        for ((i=1; i<${#numbers[@]}; i++)); do
            curr=${numbers[$i]}
            
            # Get the number of digits without leading zeros
            local prev_val=$((10#$prev))
            local curr_val=$((10#$curr))
            local prev_magnitude=${#prev_val}
            local curr_magnitude=${#curr_val}
            
            # Check if consecutive AND same magnitude (number of significant digits)
            if (( curr_val == prev_val + 1 )) && (( prev_magnitude == curr_magnitude )); then
                prev=$curr
            else
                # End of range
                if [[ $start == $prev ]]; then
                    # Standalone item - save for grouping later
                    if [[ -z "${standalone_items[$key]}" ]]; then
                        standalone_items[$key]="$start"
                    else
                        standalone_items[$key]="${standalone_items[$key]} $start"
                    fi
                else
                    # Range - generate brace expansion
                    local common_prefix=""
                    local start_stripped=$start
                    local prev_stripped=$prev
                    
                    # Extract leading zeros that are common
                    while [[ ${start_stripped:0:1} == "0" ]] && [[ ${prev_stripped:0:1} == "0" ]]; do
                        common_prefix="${common_prefix}0"
                        start_stripped=${start_stripped:1}
                        prev_stripped=${prev_stripped:1}
                    done
                    
                    # Remove leading zeros from the range values
                    start_stripped=$((10#$start))
                    prev_stripped=$((10#$prev))
                    
                    # Pad to the correct length
                    local range_len=$((${#start} - ${#common_prefix}))
                    printf -v start_stripped "%0${range_len}d" $start_stripped
                    printf -v prev_stripped "%0${range_len}d" $prev_stripped
                    
                    all_ranges+=("${prefix}${common_prefix}{${start_stripped}..${prev_stripped}}${suffix}")
                fi
                start=$curr
                prev=$curr
            fi
        done
        
        # Handle last range
        if [[ $start == $prev ]]; then
            # Standalone item
            if [[ -z "${standalone_items[$key]}" ]]; then
                standalone_items[$key]="$start"
            else
                standalone_items[$key]="${standalone_items[$key]} $start"
            fi
        else
            # Range
            local common_prefix=""
            local start_stripped=$start
            local prev_stripped=$prev
            
            # Extract leading zeros that are common
            while [[ ${start_stripped:0:1} == "0" ]] && [[ ${prev_stripped:0:1} == "0" ]]; do
                common_prefix="${common_prefix}0"
                start_stripped=${start_stripped:1}
                prev_stripped=${prev_stripped:1}
            done
            
            # Remove leading zeros from the range values
            start_stripped=$((10#$start))
            prev_stripped=$((10#$prev))
            
            # Pad to the correct length
            local range_len=$((${#start} - ${#common_prefix}))
            printf -v start_stripped "%0${range_len}d" $start_stripped
            printf -v prev_stripped "%0${range_len}d" $prev_stripped
            
            all_ranges+=("${prefix}${common_prefix}{${start_stripped}..${prev_stripped}}${suffix}")
        fi
    done
    
    # Now process standalone items - group them by prefix/suffix
    for key in "${!standalone_items[@]}"; do
        IFS='|' read -r prefix suffix <<< "$key"
        items=(${standalone_items[$key]})
        
        if (( ${#items[@]} > 1 )); then
            # Multiple standalone items - use comma-separated list
            local item_list=$(IFS=,; echo "${items[*]}")
            all_ranges+=("${prefix}{${item_list}}${suffix}")
        else
            # Single standalone item
            all_ranges+=("${prefix}${items[0]}${suffix}")
        fi
    done
    
    # Output all ranges
    clean=$(echo "${all_ranges[@]}" | tr " " "\n" | sort -n | tr "\n" " ")
	printf "\n$clean\n"
}

# Main script
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 \"ITEM1 ITEM2 ITEM3 ...\""
    echo "Example: $0 \"NOISO0012-15 NOISO007-15 NOISO008-15 NOISO009-15\""
    exit 1
fi

generate_brace_expansion "$1"