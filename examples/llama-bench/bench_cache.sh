#!/bin/bash

# add executable path 
LLAMA_BENCH_PATH="/home/mingxuanyang/my_llama.cpp"

# Define the command to run llama-bench
LLAMA_BENCH_CMD="$LLAMA_BENCH_PATH/build_debug/bin/llama-bench -m $LLAMA_BENCH_PATH/models/llama-7b-f16.gguf -sm none -r 1 -pg 395,344 -p 395 -n 344 -b 1024"

# Function to clear the page cache
clear_page_cache() {
    sudo sync
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
}

# Array to store load times
load_times=()

# Iterate 10 times
for i in {1..2}; do
    echo "Iteration $i"
    
    # Clear the page cache
    clear_page_cache
    
    # Run the llama-bench command and capture the output
    output=$($LLAMA_BENCH_CMD)
    
    # Extract the load time from the output
    load_time=$(echo "$output" | grep "Test Model Load time:" | awk '{print $5}')
    
    # Add the load time to the array
    load_times+=($load_time)
done

# Create a JSON file with the load times
json_output="{\"load_times\": ["
for time in "${load_times[@]}"; do
    json_output+="$time, "
done
json_output="${json_output%, }"
json_output+="]}"

# Save the JSON output to a file
echo "$json_output" > load_times.json

echo "Load times saved to load_times.json"
