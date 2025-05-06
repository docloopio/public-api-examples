#!/bin/bash

set -e

# Docloop API base URL
BASE_URL="https://app.docloop.io/public-api/v1"
# Your Docloop API credentials
API_KEY="YOUR_API_KEY"


### Authentication ###

# Obtain an access token
echo "Getting new access token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/apikey" \
  -H "Content-Type: application/json" \
  -d '{
        "apiKey": "'"$API_KEY"'"
      }')
# Extract the access token using jq
ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.accessToken')
# Check if the access token was obtained successfully
if [ -z "$ACCESS_TOKEN" ] || [ "$ACCESS_TOKEN" == "null" ]; then
  echo "Failed to obtain access token"
  exit 1
fi
echo "Access token obtained: $ACCESS_TOKEN"


### Usecases Listing ###

# Use the access token to retrieve a list of Usecases with their Documents Types
echo "Getting list of Usecases..."
USECASES_RESPONSE=$(curl -s -X GET "$BASE_URL/usecases" \
  -H "Authorization: Bearer $ACCESS_TOKEN")
echo $USECASES_RESPONSE | jq '.'


### Upload Document ###

# Select Usecase ID and Document Type for document upload
USECASE_ID="6703ecaa78f03d3eceef642e"
DOCUMENT_TYPE="ROAD_TRANSPORT_ORDER"

# Converte invoice PDF Document binary to base64
echo "Generate base64 invoice pdf file..."
PDF_DOCUMENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_64_PDF_DOCUMENT=$(base64 -w 0 $PDF_DOCUMENT_DIR/../resources/example_transport_order.pdf)

# Create payload file for large argument (base64 file data)
echo "Create request upload document payload"
cat <<EOF > payload.json
{
  "usecaseId": "$USECASE_ID",
  "documentType": "$DOCUMENT_TYPE",
  "filename": "example_transport_order.pdf",
  "fileData": "$BASE_64_PDF_DOCUMENT"
}
EOF

# Upload Document
echo "Uploading document..."
UPLOAD_RESPONSE=$(curl -s -X POST "$BASE_URL/documents" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  --data-binary "@payload.json")
echo $UPLOAD_RESPONSE | jq
rm payload.json


### Retrieve Document Extraction ###

sleep 10
DOCUMENT_ID=$(echo "$UPLOAD_RESPONSE" | jq -r '.id')
echo "Getting Document Extraction..."
DOCUMENT_EXTRACTION=$(curl -s -X GET "$BASE_URL/documents/$DOCUMENT_ID/extraction" \
  -H "Authorization: Bearer $ACCESS_TOKEN")
echo $DOCUMENT_EXTRACTION | jq
