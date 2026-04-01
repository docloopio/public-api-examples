# Docloop Public API v2 Bash Examples

This directory contains Bash script examples for interacting with the Docloop Public API v2.

## Prerequisites

- `bash`
- `curl`
- `base64`
- `jq` (optional, for formatted JSON output)
- `socat` (required for `webhook-receiver.sh`)
- `openssl` (required for `webhook-receiver.sh` signature verification)

## Installation of socat

To run the `webhook-receiver.sh` script, you need `socat` installed:

* **Debian/Ubuntu:** `sudo apt install socat`
* **CentOS/RHEL:** `sudo yum install socat`
* **macOS:** `brew install socat`

## Setup

1. Copy the template environment file:
   ```bash
   cp .env-dist .env
   ```
2. Edit `.env` and provide your credentials (you can create your API keys at https://app.docloop.io/admin/api_keys):
  - `API_KEY`: Your Docloop API key.
  - `BASE_URL_API`: The base URL for the API (default: `https://app.docloop.io/public-api/v2`).
  - `WEBHOOK_URL`: Your webhook URL where extraction results will be sent.
  - `WEBHOOK_PORT`: The port for the local webhook listener (default: `5555`).
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

### Webhook Receiver

Start a local HTTP server to receive and log extraction results sent by webhooks.

```bash
./webhook-receiver.sh [port]
```

- `port`: (Optional) Port to listen on (default: `5555`).

This requires `socat` to be installed. It will log incoming POST requests, including headers and JSON bodies, to your terminal.
