#!/bin/bash
#eval "$($(which conda) 'shell.bash' 'hook')"
#eval "$(/home/mingxuanyang/miniconda3/condabin/conda shell.bash hook)"
#/home/mingxuanyang/miniconda3/condabin/conda init
#/home/mingxuanyang/miniconda3/condabin/conda activate vllm
source /home/mingxuanyang/miniconda3/etc/profile.d/conda.sh
conda activate vllm
#TRANSFORMERS_CACHE=/home/mingxuanyang/.cache/huggingface
#echo "TRANSFORMERS_CACHE: $TRANSFORMERS_CACHE"
#echo "HF_HOME: $HF_HOME"
#printenv | grep conda
# add executable path

#export HF_HOME="/home/mingxuanyang/.cache/huggingface/hub"
#export HF_DATASETS_CACHE=\my_drive\hf\datasets
export TRANSFORMERS_CACHE="/dev/shm"
#/home/mingxuanyang/.cache/huggingface/hub"
LLAMA_BENCH_PATH="/home/mingxuanyang/my_llama.cpp"

# Define the command to run llama-bench
LLAMA_BENCH_CMD="$LLAMA_BENCH_PATH/build_debug/bin/llama-bench -m $LLAMA_BENCH_PATH/models/llama-7b-f16.gguf -sm none -r 1 -pg 395,344 -p 395 -n 344 -b 1024"
PYTORCH_BENCH_CMD="/usr/bin/env /home/mingxuanyang/miniconda3/envs/vllm/bin/python /home/mingxuanyang/my_llama.cpp/examples/llama-bench/benchmark_vllm.py --model meta-llama/Llama-2-7b-chat-hf --dataset /home/mingxuanyang/my_llama.cpp/examples/llama-bench/ShareGPT_V3_unfiltered_cleaned_split.json --backend hf --hf-max-batch-size 1 --num-prompts 100 --set-input-len 395 --set-output-len 344"
#PYTORCH_BENCH_CMD="/home/mingxuanyang/miniconda3/envs/vllm/bin/python3 benchmark_vllm.py --model meta-llama/Llama-2-7b-chat-hf --dataset ./ShareGPT_V3_unfiltered_cleaned_split.json --backend hf --hf-max-batch-size 1 --num-prompts 100 --set-input-len 395 --set-output-len 344"
# Function to clear the page cache
clear_page_cache() {
    sudo sync
    sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
}

# Array to store load times
load_times=()

# Iterate 10 times
for i in {1..100}; do
    echo "Iteration $i"
    
    # Clear the page cache
    clear_page_cache
    
    # Run the llama-bench command and capture the output
    #output=$($LLAMA_BENCH_CMD)
    output=$($PYTORCH_BENCH_CMD)
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
