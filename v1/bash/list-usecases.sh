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

# Use the access token to retrieve a list of Usecases with their Documents Types
echo "Getting list of Usecases..."
curl -s -X GET "$BASE_URL_API/usecases" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq '.'
