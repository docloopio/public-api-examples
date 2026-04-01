# Docloop Public API v2 Hurl Examples

This directory contains [Hurl](https://hurl.dev/) test examples for the Docloop Public API v2.

## Prerequisites

- [Hurl](https://hurl.dev/docs/installation.html) installed.

## Setup

1. Copy the template environment file:
   ```bash
   cp .env-dist .env
   ```
2. Update `.env` with your actual credentials and configuration (you can create your API keys at https://app.docloop.io/admin/api_keys):
   - `BASE_URL_API`: The base URL of the API (default: `https://app.docloop.io/public-api/v2`).
   - `API_KEY`: Your API key.
   - `WEBHOOK_URL`: The URL where the API will send the extraction results.
   - `WEBHOOK_PORT`: The port for the local webhook listener (default: `5555`).
   - `WEBHOOK_SECRET`: Your webhook secret for signature verification.

## Usage

### Create an Extraction

Submit a document for extraction using the helper shell script which handles file encoding.

```bash
./create-extraction.sh <usecaseid> <documenttype> <filepath>
```

- `usecaseid`: The ID of the use case to use.
- `documenttype`: The type of document being uploaded.
- `filepath`: Path to the local file to extract.

Example:
```bash
./create-extraction.sh my-usecase invoice ../../resources/example_invoice.pdf
```

### Get an Extraction

Retrieve the status and results of a specific extraction. This script includes a retry loop that waits for the extraction to be completed.

```bash
./get-extraction.sh <jobId>
```

- `jobId`: The ID returned by the `create-extraction.sh` script.

Example:
```bash
./get-extraction.sh 12345-67890
```
