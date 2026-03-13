#!/bin/bash

# Load environment variables from .env if it exists
if [ -f .env ]; then
  source .env
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

# Extract filename from filepath
FILENAME=$(basename "$FILE_PATH")

# Create a temporary variables file for Hurl to avoid "Argument list too long"
VARS_FILE=$(mktemp)

# Write variables to the temporary file
# We use printf to avoid issues with large strings in some shell built-ins
printf "usecase_id=%s\n" "$USECASE_ID" > "$VARS_FILE"
printf "document_type=%s\n" "$DOCUMENT_TYPE" >> "$VARS_FILE"
printf "filename=%s\n" "$FILENAME" >> "$VARS_FILE"
printf "file_data=" >> "$VARS_FILE"
base64 -w 0 "$FILE_PATH" >> "$VARS_FILE"
printf "\n" >> "$VARS_FILE"

# Run the hurl test using both the .env and the temporary variables file
hurl --very-verbose --variables-file .env --variables-file "$VARS_FILE" extraction.hurl

# Capture exit code
EXIT_CODE=$?

# Cleanup
rm "$VARS_FILE"

exit $EXIT_CODE
