#!/bin/bash

# Check if the required arguments are provided
if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <database_file> <old_library_section_id1> <new_library_section_id1> [<old_library_section_id2> <new_library_section_id2> ...]"
    exit 1
fi

# Capture user inputs
database_file="$1"
log_file="update_log.txt"

# Check if the database file exists
if [ ! -f "$database_file" ]; then
    echo "Error: Database file not found." | tee -a "$log_file"
    exit 1
fi

# Create or append to the log file
echo "Log for database update on $(date)" > "$log_file"

# Prompt for confirmation before proceeding
read -p "This will update the library_section_id in the database. Are you sure? (y/n): " confirm
echo "User input: $confirm" | tee -a "$log_file"
if [ "$confirm" != "y" ]; then
    echo "Operation canceled." | tee -a "$log_file"
    exit 0
fi

# Update the database using sqlite3 for each library_section_id pair
while [ "$#" -ge 2 ]; do
    old_library_section_id="$2"
    new_library_section_id="$3"
    
    # Generate SQL query for update
    sql_query="UPDATE metadata_item_views SET library_section_id = $new_library_section_id WHERE library_section_id = $old_library_section_id;"

    # Log the SQL query to the main log file
    echo "SQL query to be executed:" >> "$log_file"
    echo "$sql_query" >> "$log_file"

    # Update the database using sqlite3 and log each step
    echo "Updating library_section_id in the database for pair $old_library_section_id to $new_library_section_id..." | tee -a "$log_file"
    updated_rows=$(sqlite3 "$database_file" "$sql_query SELECT changes();" | tee -a "$log_file")
    echo "Library_section_id updated successfully. Rows updated: $updated_rows" | tee -a "$log_file"

    # Shift to the next pair
    shift 2
        
done

echo "Log saved to: $log_file"
