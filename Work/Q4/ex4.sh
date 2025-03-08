#!/bin/bash

LOG_FILE="process_log.log"
ERROR_LOG_FILE="process_error.log"
VENV_DIR="../venv"
OUTPUT_DIR="Diagrams"
CSV_FILE=""
BACKUP="no"
LOG_LEVEL="info"

#find requirment.txt
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/plant.py"
if [[ ! -f "$PYTHON_SCRIPT" ]]; then
    PYTHON_SCRIPT="/root/LINUX_Course_Project/Work/Q2/plant.py"
fi
if [[ ! -f "$PYTHON_SCRIPT" ]]; then
    echo "Error: Could not find plant.py in Work/Q2!" | tee -a "$ERROR_LOG_FILE"
    exit 1
fi

echo "Using plant.py file: $PYTHON_SCRIPT" | tee -a "$LOG_FILE"

#go throw the data we got from the user
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--path) CSV_FILE="$2"; shift 2 ;;  # Path to the CSV file (user-specified instead of searching for it)
        -o|--output-dir) OUTPUT_DIR="$2"; shift 2 ;;  # Custom directory for saving output diagrams
        -l|--log-level) LOG_LEVEL="$2"; shift 2 ;;  # Logging level: "info" (default), "error", or "debug"
        -b|--backup) BACKUP="$2"; shift 2 ;;  # Enable automatic backup of the output directory ("yes" or "no")
        -t|--temp-dir) TEMP_DIR="$2"; shift 2 ;;  # Temporary working directory (if needed)
        -r|--reuse-venv) REUSE_VENV="yes"; shift 1 ;;  # Reuse an existing virtual environment instead of creating a new one
        -s|--silent) SILENT_MODE="yes"; shift 1 ;;  # Silent mode: suppress console output, only log to files
        *) echo "Unknown parameter: $1"; exit 1 ;;  # Handle unknown flags
    esac
done


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

#dependencies from requirments.txt
echo "Installing dependencies from requirements.txt..." | tee -a "$LOG_FILE"
pip install --upgrade pip 2>>"$ERROR_LOG_FILE"
pip install -r ~/LINUX_Course_Project/requirements.txt 2>>"$ERROR_LOG_FILE"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to install dependencies!" | tee -a "$ERROR_LOG_FILE"
    exit 1
fi
echo "Dependencies installed successfully." | tee -a "$LOG_FILE"

# run code for every line in csv
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
while IFS=',' read -r plant heights leaf_counts dry_weights; do
    [[ "$plant" == "Plant" ]] && continue  

    echo "Processing plant: $plant" | tee -a "$LOG_FILE"
    mkdir -p "$OUTPUT_DIR/$plant"

    python3 "$PYTHON_SCRIPT" --plant "$plant" --height $(echo $heights | tr -d '"') --leaf_count $(echo $leaf_counts | tr -d '"') --dry_weight $(echo $dry_weights | tr -d '"') >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"

    if [[ $? -eq 0 ]]; then
        mv "${plant}_scatter.png" "${plant}_histogram.png" "${plant}_line_plot.png" "Diagrams/$plant/" 2>/dev/null
        echo "Diagrams for $plant saved in Diagrams/$plant/" | tee -a "$LOG_FILE"
    else
        echo "Error processing $plant. Check $ERROR_LOG_FILE for details." | tee -a "$ERROR_LOG_FILE"
    fi
done < "$CSV_FILE"

#save data 
if [[ "$BACKUP" == "yes" ]]; then
    TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
   mkdir -p /root/LINUX_Course_Project/BACKUPS
   tar -czvf "/root/LINUX_Course_Project/BACKUPS/Plants_Backup_$TIMESTAMP.tar.gz" -C "$(dirname "$OUTPUT_DIR")" "$(basename "$OUTPUT_DIR")" >> "$LOG_FILE" 2>> "$ERROR_LOG_FILE"
   echo "Backup created in /root/LINUX_Course_Project/BACKUPS."
fi

echo "======== Processing Completed ========" | tee -a "$LOG_FILE"
