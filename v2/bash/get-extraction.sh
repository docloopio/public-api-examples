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
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <jobId>"
    exit 1
fi

JOB_ID=$1

# Environment variables validation
if [ -z "$API_KEY" ] || [ -z "$BASE_URL_API" ]; then
    echo "Error: API_KEY and BASE_URL_API must be defined in .env file or environment."
    exit 1
fi

if [[ ! "$BASE_URL_API" =~ ^https?:// ]]; then
    echo "Error: BASE_URL_API must be a valid URL starting with http:// or https://"
    exit 1
fi

echo "Retrieving extraction for job $JOB_ID..."
echo ""
echo "--- Request Headers ---"
echo "Authorization: Bearer ${API_KEY:0:10}..."
echo "Content-Type: application/json"
echo ""
echo "-----------------------"

# Prepare temporary files for headers and body
HEADERS_FILE=$(mktemp)
BODY_FILE=$(mktemp)

# Execute request and capture HTTP code
set +e
HTTP_CODE=$(curl -S -s -o "$BODY_FILE" -D "$HEADERS_FILE" -w "%{http_code}" -X GET "$BASE_URL_API/extractions/$JOB_ID" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" 2>curl_error.log
)
CURL_EXIT_CODE=$?
set -e

if [ $CURL_EXIT_CODE -ne 0 ]; then
    echo "Error: Curl request failed with exit code $CURL_EXIT_CODE"
    cat curl_error.log
    rm -f curl_error.log "$HEADERS_FILE" "$BODY_FILE"
    exit $CURL_EXIT_CODE
fi
rm -f curl_error.log

echo ""

if [ "$HTTP_CODE" -lt 200 ] || [ "$HTTP_CODE" -gt 299 ]; then
    echo "--- Response Headers ---"
    cat "$HEADERS_FILE"
    echo ""
    echo "--- Response Body ---"
    if command -v jq >/dev/null 2>&1 && jq -e . >/dev/null 2>&1 < "$BODY_FILE"; then
        jq . < "$BODY_FILE"
    else
        cat "$BODY_FILE"
    fi
    rm -f "$HEADERS_FILE" "$BODY_FILE"
    exit 1
fi

echo "--- Response Headers ---"
cat "$HEADERS_FILE"
echo ""
echo "--- Response Body ---"
if command -v jq >/dev/null 2>&1 && jq -e . >/dev/null 2>&1 < "$BODY_FILE"; then
    jq . < "$BODY_FILE"
else
    cat "$BODY_FILE"
fi

# Clean up
rm -f "$HEADERS_FILE" "$BODY_FILE"
