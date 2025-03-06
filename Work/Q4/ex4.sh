#!/bin/bash

LOG_FILE="process_log.log"
ERROR_LOG_FILE="process_error.log"
VENV_DIR="../venv"
#find requirment.txt
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/requirements.txt"
if [[ ! -f "$PYTHON_SCRIPT" ]]; then
    PYTHON_SCRIPT="/root/LINUX_Course_Project/requirements.txt"
fi
if [[ ! -f "$PYTHON_SCRIPT" ]]; then
    echo "Error: Could not find requirements.txt in script directory or project root!" | tee -a "$ERROR_LOG_FILE"
    exit 1
fi

echo "Using requirements file: $PYTHON_SCRIPT" | tee -a "$LOG_FILE"

echo "======== Starting CSV Processing ========" | tee -a "$LOG_FILE"

#get the csv
CSV_FILE=$1
if [[ -z "$CSV_FILE" || ! -f "$CSV_FILE" ]]; then
    CSV_FILE=$(find ~/LINUX_Course_Project -type f -name "plants.csv"| head -n 1)
fi
if [[ -z "$CSV_FILE" || ! -f "$CSV_FILE" ]]; then
    echo "Error: Could not find any valid CSV file in the project!" | tee -a "$ERROR_LOG_FILE"
    exit 1
fi

echo "Using CSV file: $CSV_FILE" | tee -a "$LOG_FILE"

# making a venv 
if [[ ! -d "$VENV_DIR" ]]; then
    echo "Creating virtual environment at $VENV_DIR" | tee -a "$LOG_FILE"
    python3 -m venv "$VENV_DIR"
fi

# start venv
source "$VENV_DIR/bin/activate"
if [[ $? -ne 0 ]]; then
    echo "Failed to activate virtual environment!" | tee -a "$ERROR_LOG_FILE"
    exit 1
fi
echo "Virtual environment activated." | tee -a "$LOG_FILE"

# run code for every line in csv
mkdir -p Diagrams
while IFS=',' read -r plant heights leaf_counts dry_weights; do
    [[ "$plant" == "Plant" ]] && continue  

    echo "Processing plant: $plant" | tee -a "$LOG_FILE"
    mkdir -p "Diagrams/$plant"

    python3 "$PYTHON_SCRIPT" --plant "$plant" --height $(echo $heights | tr -d '"') --leaf_count $(echo $leaf_counts | tr -d '"') --dry_weight $(echo $dry_weights | tr -d '"') >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"

    if [[ $? -eq 0 ]]; then
        mv "${plant}_scatter.png" "${plant}_histogram.png" "${plant}_line_plot.png" "Diagrams/$plant/" 2>/dev/null
        echo "Diagrams for $plant saved in Diagrams/$plant/" | tee -a "$LOG_FILE"
    else
        echo "Error processing $plant. Check $ERROR_LOG_FILE for details." | tee -a "$ERROR_LOG_FILE"
    fi

done < "$CSV_FILE"

echo "======== Processing Completed ========" | tee -a "$LOG_FILE"
