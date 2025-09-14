#!/bin/bash

input_file="inputs.txt"
output_file="Prover.toml"

# Function to convert hex string to decimal array
hex_to_dec_array() {
    local hexstr=$1
    local is_signature=$2
    
    # Remove 0x prefix if present
    hexstr=${hexstr#0x}
    
    # For signatures, remove the last byte (v value) if it's 65 bytes
    if [ "$is_signature" = true ] && [ ${#hexstr} -eq 130 ]; then  # 65 bytes = 130 hex chars
        hexstr=${hexstr:0:128}  # Keep first 64 bytes (128 hex chars)
    fi
    
    local len=${#hexstr}
    local result="["
    
    for ((i = 0; i < len; i += 2)); do
        if [ $i -ne 0 ]; then
            result+=","
        fi
        result+="\"$((0x${hexstr:$i:2}))\""
    done
    
    result+="]"
    echo "$result"
}

# Read values from input file
hashed_message=$(grep '^hashed_message' "$input_file" | cut -d'=' -f2 | tr -d '[:space:]"')
pub_key_x=$(grep '^pub_key_x' "$input_file" | cut -d'=' -f2 | tr -d '[:space:]"')
pub_key_y=$(grep '^pub_key_y' "$input_file" | cut -d'=' -f2 | tr -d '[:space:]"')
signature=$(grep '^signature' "$input_file" | cut -d'=' -f2 | tr -d '[:space:]"')

# Convert to decimal arrays
hashed_message_arr=$(hex_to_dec_array "$hashed_message" false)
pub_key_x_arr=$(hex_to_dec_array "$pub_key_x" false)
pub_key_y_arr=$(hex_to_dec_array "$pub_key_y" false)
signature_arr=$(hex_to_dec_array "$signature" true)

# Write to Prover.toml
cat > "$output_file" <<EOF
hashed_message = $hashed_message_arr
pub_key_x = $pub_key_x_arr
pub_key_y = $pub_key_y_arr
signature = $signature_arr
EOF

echo "Wrote $output_file"