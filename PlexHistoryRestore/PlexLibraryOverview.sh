#!/bin/bash

# Check if the required argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <database_file>"
    exit 1
fi

# Capture user input
database_file="$1"

# Check if the database file exists
if [ ! -f "$database_file" ]; then
    echo "Error: Database file not found."
    exit 1
fi

# Generate SQL query for count per library_section_id
sql_query="SELECT library_section_id, COUNT(*) AS entry_count FROM metadata_item_views GROUP BY library_section_id;"

# Execute the query using sqlite3 and display the results
echo "Overview of entry count per library_section_id:"
sqlite3 "$database_file" "$sql_query"

