#!/bin/bash

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load .env file
if [ -f "$SCRIPT_DIR/.env" ]; then
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/.env"
else
    echo "Error: .env file not found in $SCRIPT_DIR. Using environment variables."
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

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File $FILE_PATH not found."
    exit 1
fi

FILENAME=$(basename "$FILE_PATH")
FILE_DATA=$(base64 -w 0 "$FILE_PATH")

# Environment variables validation
if [ -z "$API_KEY" ] || [ -z "$BASE_URL_API" ] || [ -z "$WEBHOOK_URL" ]; then
    echo "Error: API_KEY, BASE_URL_API, and WEBHOOK_URL must be defined in .env file or environment."
    exit 1
fi

echo "Create extraction for $FILENAME..."

EXTRACTION_RESPONSE=$(curl -s -X POST "$BASE_URL_API/extractions" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  --data-binary @- <<EOF
{
  "usecaseId": "$USECASE_ID",
  "documentType": "$DOCUMENT_TYPE",
  "filename": "$FILENAME",
  "fileData": "$FILE_DATA",
  "webhookUrl": "$WEBHOOK_URL"
}
EOF
)

echo "$EXTRACTION_RESPONSE" | jq '.'
