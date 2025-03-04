#!/bin/bash

echo "Select an action:"
echo "1) Create an empty CSV file"
echo "2) Select an existing CSV file"
echo "3) Display CSV content"
echo "4) Add a new row for a plant"
echo "5) Run Python script for plant analysis"
echo "6) Update a row in the CSV"
echo "7) Delete a row by plant name"
echo "8) Find the plant with the highest leaf count"
echo "0) Exit"

read -p "Enter your choice: " choice

create_csv() {
    read -p "Enter new CSV filename: " filename
    echo "Plant,Height,Leaf Count,Dry Weight" > "$filename"
    echo "Created file: $filename"
}

choose_csv() {
    while true; do
        read -p "Enter existing CSV filename: " filename
        if [[ -f "$filename" ]]; then
            echo "File selected: $filename"
            break
        else
            echo "Error: File '$filename' not found. Please enter a valid filename."
        fi
    done
}

view_csv() {
    while true; do
        read -p "Enter CSV filename to view: " filename
        if [[ -f "$filename" ]]; then
            cat "$filename"
            break
        else
            echo "Error: File '$filename' not found. Please enter a valid filename."
        fi
    done
}

add_plant() {
    while true; do
        read -p "Enter CSV filename: " filename
        if [[ -f "$filename" ]]; then
            break
        else
            echo "Error: File '$filename' not found. Please enter a valid filename."
        fi
    done

    read -p "Plant name: " plant
    read -p "Heights (space-separated): " height
    read -p "Leaf counts (space-separated): " leaf_count
    read -p "Dry weight (space-separated): " dry_weight

    echo "$plant,\"$height\",\"$leaf_count\",\"$dry_weight\"" >> "$filename"
    echo "Added row to $filename"
}

run_python() {
    while true; do
        read -p "Enter CSV filename: " filename
        if [[ -f "$filename" ]]; then
            break
        else
            echo "Error: File '$filename' not found. Please enter a valid filename."
        fi
    done

    while true; do
        read -p "Select a plant for analysis: " plant
        if grep -q "^$plant," "$filename"; then
            python3 DOWNLOADS/LINUX_COURSE_WORK-downloads/plant.py --plant "$plant"
            break
        else
            echo "Error: Plant '$plant' not found in $filename. Please try again."
        fi
    done
}

update_plant() {
    while true; do
        read -p "Enter CSV filename: " filename
        if [[ -f "$filename" ]]; then
            break
        else
            echo "Error: File '$filename' not found. Please enter a valid filename."
        fi
    done

    while true; do
        read -p "Plant name to update: " plant
        if grep -q "^$plant," "$filename"; then
            break
        else
            echo "Error: Plant '$plant' not found in $filename. Please try again."
        fi
    done

    read -p "New Heights (space-separated): " height
    read -p "New Leaf Counts (space-separated): " leaf_count
    read -p "New Dry Weights (space-separated): " dry_weight

    awk -v name="$plant" -v h="$height" -v l="$leaf_count" -v d="$dry_weight" -F "," '
    BEGIN {OFS=","}
    {
        if ($1 == name) {
            $2 = "\"" h "\""
            $3 = "\"" l "\""
            $4 = "\"" d "\""
        }
        print
    }' "$filename" > temp.csv && mv temp.csv "$filename"

    echo "Row updated successfully."
}

delete_plant() {
    while true; do
        read -p "Enter CSV filename: " filename
        if [[ -f "$filename" ]]; then
            break
        else
            echo "Error: File '$filename' not found. Please enter a valid filename."
        fi
    done

    while true; do
        read -p "Plant name to delete: " plant
        if grep -q "^$plant," "$filename"; then
            grep -v "^$plant," "$filename" > temp.csv && mv temp.csv "$filename"
            echo "Row deleted."
            break
        else
            echo "Error: Plant '$plant' not found in $filename. Please try again."
        fi
    done
}

max_leaf_count() {
    while true; do
        read -p "Enter CSV filename: " filename
        if [[ -f "$filename" ]]; then
            break
        else
            echo "Error: File '$filename' not found. Please enter a valid filename."
        fi
    done

    max_leaf=$(awk -F "," 'NR>1 {gsub(/"/, "", $3); split($3, arr, " "); for (i in arr) if (arr[i] > max) { max = arr[i]; plant = $1 }} END {print plant, max}' "$filename")

    if [[ -z "$max_leaf" ]]; then
        echo "No data found in $filename."
    else
        echo "Plant with the highest leaf count: $max_leaf"
    fi
}


case $choice in
    1) create_csv ;;
    2) choose_csv ;;
    3) view_csv ;;
    4) add_plant ;;
    5) run_python ;;
    6) update_plant ;;
    7) delete_plant ;;
    8) max_leaf_count ;;
    0) exit ;;
    *) echo "Invalid choice." ;;
esac
