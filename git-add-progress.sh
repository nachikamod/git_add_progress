#!/bin/bash

# Get the total number of files in the directory
TOTAL_FILES=$(find . -type f | wc -l)
STAGED_FILES=0
START_TIME=$(date +%s)  # Capture the start time

# Print initial file count
echo "Total files to be staged: $TOTAL_FILES"
echo "Starting git add..."

# Function to format time in HH:MM:SS
format_time() {
    local seconds=$1
    printf "%02d:%02d:%02d" $((seconds/3600)) $(((seconds%3600)/60)) $((seconds%60))
}

# Function to display progress bar with estimated time remaining
progress_bar() {
    local elapsed=$(( $(date +%s) - START_TIME ))  # Time elapsed

    if [ "$STAGED_FILES" -gt 10 ]; then
        local estimated_total_time=$((elapsed * TOTAL_FILES / STAGED_FILES))
        local remaining_time=$((estimated_total_time - elapsed))
    else
        local remaining_time="Calculating..."  # Prevent unstable estimates at start
    fi

    local progress=$((STAGED_FILES * 100 / TOTAL_FILES))
    local bar_length=$((progress / 2))  # Scale to fit 50 characters
    local bar=$(printf "%-${bar_length}s" "#" | tr ' ' '#')
    local spaces=$((50 - bar_length))
    local empty=$(printf "%-${spaces}s" " " | tr ' ' '-')

    echo -ne "[${bar}${empty}] ${progress}% ($STAGED_FILES / $TOTAL_FILES) | ETA: $(format_time ${remaining_time:-0})\r"
}

# Run 'git add -v *' and process staged files in real-time
git add -v * | grep -oE "add '.*'" | while read -r line; do
    # Extract file path using regex
    FILE=$(echo "$line" | sed -E "s/add '(.*)'/\1/")

    # Increment staged file count
    STAGED_FILES=$((STAGED_FILES + 1))

    # Display progress bar with estimated time remaining
    progress_bar
done

# Final confirmation
echo -e "\nAll files have been staged successfully in $(format_time $(( $(date +%s) - START_TIME )))!"
