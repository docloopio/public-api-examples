#!/bin/bash

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
  while IFS= read -r HEADER; do
    HEADER=$(echo "$HEADER" | tr -d '\r')
    [ -z "$HEADER" ] && break
    echo "$HEADER" >&2
    if echo "$HEADER" | grep -iq "^Content-Length:"; then
      CONTENT_LENGTH=$(echo "$HEADER" | awk -F': ' '{print $2}' | tr -d '[:space:]')
    fi
  done

  # Read body if present
  if [ "$CONTENT_LENGTH" -gt 0 ] 2>/dev/null; then
    BODY=$(dd bs=1 count="$CONTENT_LENGTH" 2>/dev/null)
    echo "" >&2
    echo "--- Body ---" >&2
    echo "$BODY" >&2
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

PORT=${1:-5555}

echo "Starting HTTP server on port $PORT using socat..."
echo "Press Ctrl+C to stop."
echo "---"

# We use EXEC to call THIS exact script ($0) and pass the "handle_request" argument.
# This completely bypasses the /bin/sh exported function stripping issue.
socat TCP-LISTEN:"$PORT",reuseaddr,fork EXEC:"bash $0 handle_request"