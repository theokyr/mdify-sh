#!/bin/bash
# Usage: ./mdify.sh <directory> <output_file> <extensions> [blocklist]
# Example:
#   ./mdify.sh ./src output.md cpp,hpp ./src/ignore,./src/exclude.txt

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
    echo "Usage: $0 <directory> <output_file> <extensions> [blocklist]"
    echo "Example: $0 ./src output.md cpp,hpp ./src/ignore,./src/exclude.txt"
    exit 1
fi

DIRECTORY=$1
OUTPUT_FILE=$2
EXTENSIONS=$3
BLOCKLIST=${4:-}

if [ ! -d "$DIRECTORY" ]; then
    echo "The specified directory does not exist."
    exit 1
fi

# Convert the main directory to an absolute path.
DIRECTORY=$(realpath "$DIRECTORY")

# Truncate the output file.
> "$OUTPUT_FILE"

# Read comma-separated lists.
IFS=',' read -r -a EXTENSIONS_ARRAY <<< "$EXTENSIONS"
if [ -n "$BLOCKLIST" ]; then
    IFS=',' read -r -a BLOCKLIST_ARRAY <<< "$BLOCKLIST"
else
    BLOCKLIST_ARRAY=()
fi

echo "Directory: $DIRECTORY"
echo "Output File: $OUTPUT_FILE"
echo "Extensions: ${EXTENSIONS_ARRAY[*]}"
if [ "${#BLOCKLIST_ARRAY[@]}" -gt 0 ]; then
    echo "Blocklist: ${BLOCKLIST_ARRAY[*]}"
else
    echo "Blocklist: None"
fi

# Separate blocklist entries into directories and files.
BLOCKLIST_DIRS=()
BLOCKLIST_FILES=()
for blocked in "${BLOCKLIST_ARRAY[@]}"; do
    # Get absolute path (ignore errors if the blocklist entry does not exist)
    normalized_blocked=$(realpath "$blocked" 2>/dev/null)
    if [ -d "$normalized_blocked" ]; then
        BLOCKLIST_DIRS+=("$normalized_blocked")
    elif [ -f "$normalized_blocked" ]; then
        BLOCKLIST_FILES+=("$normalized_blocked")
    fi
done

# Construct the find command.
# The structure is:
#   find <DIRECTORY> [prune blocklisted directories] -o ( match extensions [exclude blocklisted files] ) -print0
find_command="find \"$DIRECTORY\" "

# Add directory-pruning for blocklisted directories.
if [ "${#BLOCKLIST_DIRS[@]}" -gt 0 ]; then
    find_command+="\\( "
    for d in "${BLOCKLIST_DIRS[@]}"; do
        # Match the directory itself and everything within it.
        find_command+="-path \"$d\" -o -path \"$d/*\" -o "
    done
    # Remove trailing " -o "
    find_command="${find_command% -o }"
    find_command+=" \\) -prune -o "
fi

# Add the extension matching clause.
find_command+="\\( "
for ext in "${EXTENSIONS_ARRAY[@]}"; do
    find_command+="-name \"*.$ext\" -o "
done
find_command="${find_command% -o }"
find_command+=" \\) "

# Exclude blocklisted files (if any) by adding a -not clause.
if [ "${#BLOCKLIST_FILES[@]}" -gt 0 ]; then
    find_command+="-a -not \\( "
    for f in "${BLOCKLIST_FILES[@]}"; do
        find_command+="-path \"$f\" -o "
    done
    find_command="${find_command% -o }"
    find_command+=" \\) "
fi

find_command+="-print0"

echo "Constructed find command: $find_command"

# Run the find command.
eval $find_command | while IFS= read -r -d $'\0' file; do
    filesize=$(stat --printf="%s" "$file")
    if [ "$filesize" -gt 102400 ]; then
        echo "Warning: The file '$file' exceeds 100KB and might be difficult for LLMs to digest."
    fi

    echo "**\`$file\`:**" >> "$OUTPUT_FILE"
    echo '```'${file##*.} >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo >> "$OUTPUT_FILE"
done

echo "The contents of all specified files have been written to $OUTPUT_FILE in Markdown format."

output_filesize=$(stat --printf="%s" "$OUTPUT_FILE")
if [ "$output_filesize" -gt 102400 ]; then
    echo "Warning: The output file '$OUTPUT_FILE' exceeds 100KB and might be difficult for LLMs to digest."
fi
