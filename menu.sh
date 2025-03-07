#!/bin/bash

selected_file=""
target_dir="$(pwd)/DOWNLOADS/LINUX_COURSE_WORK-downloads"

while true; do
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
        if [[ ! -d "$target_dir" ]]; then
            echo "Error: Target directory '$target_dir' does not exist."
            return
        fi

        read -p "Enter new CSV filename: " filename
        full_path="$target_dir/$filename"

        echo "Plant,Height,Leaf Count,Dry Weight" > "$full_path"
        echo "Created file: $full_path"
    }

    choose_csv() {
        while true; do
            read -p "Enter existing CSV filename: " filename
            full_path="$target_dir/$filename"

            if [[ -f "$full_path" ]]; then
                selected_file="$full_path"
                echo "File selected: $selected_file"
                break
            else
                echo "Error: File '$full_path' not found. Please enter a valid filename."
            fi
        done
    }

    validate_file_selected() {
        if [[ -z "$selected_file" ]]; then
            echo "Error: No file selected. Please choose a file using option 2 first."
            return 1
        fi
        return 0
    }

    view_csv() {
        validate_file_selected || return
        cat "$selected_file"
    }

    add_plant() {
        validate_file_selected || return

        read -p "Plant name: " plant
        read -p "Heights (space-separated): " height
        read -p "Leaf counts (space-separated): " leaf_count
        read -p "Dry weight (space-separated): " dry_weight

        echo "$plant,\"$height\",\"$leaf_count\",\"$dry_weight\"" >> "$selected_file"
        echo "Added row to $selected_file"
    }

    run_python() {
        validate_file_selected || return

        while true; do
            read -p "Select a plant for analysis: " plant
            if grep -q "^$plant," "$selected_file"; then
                python3 "$target_dir/plant.py" --plant "$plant"
                break
            else
                echo "Error: Plant '$plant' not found in $selected_file. Please try again."
            fi
        done
    }

    update_plant() {
        validate_file_selected || return

        while true; do
            read -p "Plant name to update: " plant
            if grep -q "^$plant," "$selected_file"; then
                break
            else
                echo "Error: Plant '$plant' not found in $selected_file. Please try again."
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
        }' "$selected_file" > temp.csv && mv temp.csv "$selected_file"

        echo "Row updated successfully."
    }

    delete_plant() {
        validate_file_selected || return

        while true; do
            read -p "Plant name to delete: " plant
            if grep -q "^$plant," "$selected_file"; then
                grep -v "^$plant," "$selected_file" > temp.csv && mv temp.csv "$selected_file"
                echo "Row deleted."
                break
            else
                echo "Error: Plant '$plant' not found in $selected_file. Please try again."
            fi
        done
    }

    max_leaf_count() {
        validate_file_selected || return

        max_leaf=$(awk -F "," 'NR>1 {gsub(/"/, "", $3); split($3, arr, " "); for (i in arr) if (arr[i] > max) { max = arr[i]; plant = $1 }} END {print plant, max}' "$selected_file")

        if [[ -z "$max_leaf" ]]; then
            echo "No data found in $selected_file."
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
        0) echo "Exiting..."; break ;;
        *) echo "Invalid choice. Please try again." ;;
    esac

    echo ""
done