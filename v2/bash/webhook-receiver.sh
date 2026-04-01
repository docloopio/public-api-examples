#!/bin/bash

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load .env file if it exists
if [ -f "$SCRIPT_DIR/.env" ]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/.env"
fi

# ==========================================
# 1. HANDLER LOGIC (Runs when called by socat)
# ==========================================
if [ "$1" == "handle_request" ]; then
  # Read request line
  read -r REQUEST_LINE
  REQUEST_LINE=$(echo "$REQUEST_LINE" | tr -d '\r')

  # IMPORTANT: We add >&2 to all echo statements.
  # This sends logs to your terminal instead of sending them to the HTTP client!
  echo "" >&2
  echo "=== New Request $(date) ===" >&2
  echo "Request: $REQUEST_LINE" >&2
  echo "" >&2
  echo "--- Headers ---" >&2

  # Read headers
  CONTENT_LENGTH=0
  SIGNATURE=""
  while IFS= read -r HEADER; do
    HEADER=$(echo "$HEADER" | tr -d '\r')
    [ -z "$HEADER" ] && break
    echo "$HEADER" >&2
    if echo "$HEADER" | grep -iq "^Content-Length:"; then
      CONTENT_LENGTH=$(echo "$HEADER" | awk -F': ' '{print $2}' | tr -d '[:space:]')
    fi
    if echo "$HEADER" | grep -iq "^x-docloop-signature:"; then
      SIGNATURE=$(echo "$HEADER" | awk -F': ' '{print $2}' | tr -d '[:space:]')
    fi
  done

  # Read body if present
  if [ "$CONTENT_LENGTH" -gt 0 ] 2>/dev/null; then
    BODY=$(dd bs=1 count="$CONTENT_LENGTH" 2>/dev/null)
    echo "" >&2
    echo "--- Body ---" >&2
    
    # Signature Verification
    if [ -n "$WEBHOOK_SECRET" ]; then
      # Strip sha256= prefix if present
      CLEAN_SIGNATURE="${SIGNATURE#sha256=}"
      COMPUTED_SIGNATURE=$(echo -n "$BODY" | openssl dgst -sha256 -hmac "$WEBHOOK_SECRET" | sed 's/^.* //')
      if [ "$CLEAN_SIGNATURE" == "$COMPUTED_SIGNATURE" ]; then
        echo "✅ Signature verified!" >&2
      else
        echo "❌ Invalid signature!" >&2
        echo "   Received: $SIGNATURE" >&2
        echo "   Computed: $COMPUTED_SIGNATURE" >&2
      fi
    else
      echo "⚠️ WEBHOOK_SECRET not set, skipping signature verification." >&2
    fi

    if command -v jq >/dev/null 2>&1 && echo "$BODY" | jq -e . >/dev/null 2>&1; then
      echo "$BODY" | jq . >&2
    else
      echo "$BODY" >&2
    fi
  fi

  echo "================" >&2

  # Send the actual HTTP response to stdout (this goes back to the client via socat)
  RESPONSE_BODY='{"status":"ok","message":"Request received"}'
  printf "HTTP/1.1 200 OK\r\n"
  printf "Content-Type: application/json\r\n"
  printf "Content-Length: %d\r\n" "${#RESPONSE_BODY}"
  printf "Connection: close\r\n"
  printf "\r\n"
  printf "%s" "$RESPONSE_BODY"
  
  # Exit so it doesn't run the server startup block below
  exit 0
fi

# ==========================================
# 2. MAIN SERVER STARTUP
# ==========================================

# Check if socat is installed before proceeding
if ! command -v socat &> /dev/null; then
  echo "⚠️ Error: 'socat' is not installed on this system." >&2
  echo "Please install it to run this server." >&2
  echo "  - Debian/Ubuntu: sudo apt install socat" >&2
  echo "  - CentOS/RHEL:   sudo yum install socat" >&2
  echo "  - macOS:         brew install socat" >&2
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "⚠️ Warning: 'jq' is not installed. JSON bodies will not be pretty-printed." >&2
fi

PORT=${1:-${WEBHOOK_PORT:-5555}}

echo "Starting HTTP server on port $PORT using socat..."
echo "Press Ctrl+C to stop."
echo "---"

# We use EXEC to call THIS exact script ($0) and pass the "handle_request" argument.
# This completely bypasses the /bin/sh exported function stripping issue.
socat TCP-LISTEN:"$PORT",reuseaddr,fork EXEC:"bash $0 handle_request"
