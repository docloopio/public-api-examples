#!/bin/bash

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load environment variables from .env if it exists
if [ -f "$SCRIPT_DIR/.env" ]; then
  source "$SCRIPT_DIR/.env"
else
  echo ".env file not found, please copy .env-dist to .env and configure it."
  exit 1
fi

# Parameters validation
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <usecaseid> <documenttype> <filepath>"
    exit 1
fi

USECASE_ID=$1
DOCUMENT_TYPE=$2
FILE_PATH=$3

# Check if the file exists
if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File $FILE_PATH not found."
  exit 1
fi

FILENAME=$(basename "$FILE_PATH")

# Create a temporary variables file for Hurl
VARS_FILE=$(mktemp)
printf "usecase_id=%s\n" "$USECASE_ID" > "$VARS_FILE"
printf "document_type=%s\n" "$DOCUMENT_TYPE" >> "$VARS_FILE"
printf "filename=%s\n" "$FILENAME" >> "$VARS_FILE"
printf "file_data=" >> "$VARS_FILE"
base64 -w 0 "$FILE_PATH" >> "$VARS_FILE"
printf "\n" >> "$VARS_FILE"

# Run the hurl test
hurl --variables-file "$SCRIPT_DIR/.env" --variables-file "$VARS_FILE" "$SCRIPT_DIR/create_extraction.hurl"

EXIT_CODE=$?
rm "$VARS_FILE"
exit $EXIT_CODE
