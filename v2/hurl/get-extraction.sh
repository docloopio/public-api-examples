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
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <jobId>"
    exit 1
fi

JOB_ID=$1

# Run the hurl test
hurl --variables-file "$SCRIPT_DIR/.env" --variable job_id="$JOB_ID" "$SCRIPT_DIR/get_extraction.hurl"
