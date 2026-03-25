# Docloop Public API v2 Bash Examples

This directory contains Bash script examples for interacting with the Docloop Public API v2.

## Prerequisites

- `bash`
- `curl`
- `base64`
- `jq` (optional, for formatted JSON output)

## Setup

1. Copy the template environment file:
   ```bash
   cp .env-dist .env
   ```
2. Edit `.env` and provide your credentials:
   - `API_KEY`: Your Docloop API key.
   - `BASE_URL_API`: The base URL for the API (default: `https://app.docloop.io/public-api/v2`).
   - `WEBHOOK_URL`: Your webhook URL where extraction results will be sent.

## Usage

### Create an Extraction

Submit a document for extraction.

```bash
./create-extraction.sh <usecaseid> <documenttype> <filepath>
```

- `usecaseid`: The ID of the use case to use.
- `documenttype`: The type of document being uploaded.
- `filepath`: Path to the local file to extract.

Example:
```bash
./create-extraction.sh my-usecase invoice ./invoice.pdf
```

### Get an Extraction

Retrieve the status and results of a specific extraction.

```bash
./get-extraction.sh <documentId>
```

- `documentId`: The ID returned by the `create-extraction.sh` script.

Example:
```bash
./get-extraction.sh 12345-67890
```
