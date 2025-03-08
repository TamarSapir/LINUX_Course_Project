#!/bin/bash

selected_file=""

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
#create new csv that the user want
    create_csv() {
        read -p "Enter new CSV filename: " filename
        echo "Plant,Hieght,Leaf Count,Dry Weight"> "$filename" #empty csv file
        selected_file="$filename"
        echo "Created file: $selected_file and set as current file."
    }
#choose one csv to work with
    choose_csv() {
        while true; do
            read -p "Enter existing CSV filename (searching in project): " filename
            filepath=$(find . -type f -name "$filename" 2>/dev/null)

            if [[ -n "$filepath" ]]; then
                selected_file="$filepath"
                echo "File selected: $selected_file"
                break
            else
                echo "Error: File '$filename' not found in the project. Please try again."
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
#view the csv that the user choose
    view_csv() {
        validate_file_selected || return
        cat "$selected_file"
    }

#add plant to the csv
    add_plant() {
        validate_file_selected || return

        read -p "Plant name: " plant
        read -p "Heights (space-separated): " height
        read -p "Leaf counts (space-separated): " leaf_count
        read -p "Dry weight (space-separated): " dry_weight

        echo "$plant,\"$height\",\"$leaf_count\",\"$dry_weight\"" >> "$selected_file"
        echo "Added row to $selected_file"
    }

#run the new plant.py file 
run_python() {
    validate_file_selected || return

    while true; do
        read -p "Select a plant for analysis: " plant
        plant_data=$(grep "^$plant," "$selected_file")

        if [[ -n "$plant_data" ]]; then
            # pull out the data from the file
            heights=$(echo "$plant_data" | cut -d',' -f2 | tr -d '"')
            leaf_counts=$(echo "$plant_data" | cut -d',' -f3 | tr -d '"')
            dry_weights=$(echo "$plant_data" | cut -d',' -f4 | tr -d '"')

            python3 Work/Q2/plant.py --plant "$plant" --height $heights --leaf_count $leaf_counts --dry_weight $dry_weights

            echo "Parameters saved to requirements.txt:"
            cat requirements.txt
            break
        else
            echo "Error: Plant '$plant' not found in $selected_file. Please try again."
        fi
    done
}


#update data of one plant that the user choose
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

#delete one plant from the csv
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

#finding the max of the leaf
    max_leaf_count() {
        validate_file_selected || return

        max_leaf=$(awk -F "," 'NR>1 {gsub(/"/, "", $3); split($3, arr, " "); for (i in arr) if (arr[i] > max) { max = arr[i]; plant = $1 }} END {print plant, max}' "$selected_file")

        if [[ -z "$max_leaf" ]]; then
            echo "No data found in $selected_file."
        else
            echo "Plant with the highest leaf count: $max_leaf"
        fi
    }

#the menu himself when we run the file we will see it
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