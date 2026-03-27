#!/bin/bash

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load .env file
if [ -f "$SCRIPT_DIR/.env" ]; then
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/.env"
elif [ -f "$SCRIPT_DIR/.env-dist" ]; then
    echo "Warning: .env file not found. Using .env-dist for demo purposes."
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/.env-dist"
else
    echo "Error: .env file not found in $SCRIPT_DIR. Using environment variables."
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
FILE_DATA=$(base64 < "$FILE_PATH" | tr -d '[:space:]')

# Environment variables validation
if [ -z "$API_KEY" ] || [ -z "$BASE_URL_API" ]; then
    echo "Error: API_KEY and BASE_URL_API must be defined in .env file or environment."
    exit 1
fi

# Obtain an access token
echo "Getting new access token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL_API/auth/apikey" \
  -H "Content-Type: application/json" \
  -d '{
        "apiKey": "'"$API_KEY"'"
      }')

# Extract the access token using jq
ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.accessToken')

# Check if the access token was obtained successfully
if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" == "null" ]; then
  echo "Failed to obtain access token"
  echo "$TOKEN_RESPONSE" | jq '.'
  exit 1
fi

echo "Access token obtained."

# Upload Document
echo "Uploading document $FILENAME..."
PAYLOAD_FILE=$(mktemp)
cat <<EOF > "$PAYLOAD_FILE"
{
  "usecaseId": "$USECASE_ID",
  "documentType": "$DOCUMENT_TYPE",
  "filename": "$FILENAME",
  "fileData": "$FILE_DATA"
}
EOF

UPLOAD_RESPONSE=$(curl -s -X POST "$BASE_URL_API/documents" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary "@$PAYLOAD_FILE")

rm -f "$PAYLOAD_FILE"

echo "$UPLOAD_RESPONSE" | jq '.'
