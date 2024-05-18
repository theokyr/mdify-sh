#!/bin/bash

# Usage: ./mdify <directory> <output_file> <extensions>

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <directory> <output_file> <extensions>"
    echo "Example: $0 ./src output.md cpp,hpp"
    exit 1
fi

DIRECTORY=$1
OUTPUT_FILE=$2
EXTENSIONS=$3

# Check if the specified directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "The specified directory does not exist."
    exit 1
fi

# Prepare the output file, clearing it if it already exists
> "$OUTPUT_FILE"

# Convert comma-separated extensions to find format
IFS=',' read -r -a EXTENSIONS_ARRAY <<< "$EXTENSIONS"

# Build the find command with the specified extensions
find_command="find \"$DIRECTORY\" \( -false"
for ext in "${EXTENSIONS_ARRAY[@]}"; do
    find_command+=" -o -name \"*.$ext\""
done
find_command+=" \) -print0"

# Execute the find command and process the files
eval $find_command | while IFS= read -r -d $'\0' file; do
    echo "**\`$file\`:**" >> "$OUTPUT_FILE"
    echo '```'${file##*.} >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo >> "$OUTPUT_FILE"
done

echo "The contents of all specified files have been written to $OUTPUT_FILE in Markdown format."

