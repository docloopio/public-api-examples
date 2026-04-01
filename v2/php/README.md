# Docloop Public API v2 PHP Examples

This directory contains PHP script examples for interacting with the Docloop Public API v2.

## Prerequisites

- `php 8.x`
- `curl` extension enabled in PHP.

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
   - `WEBHOOK_SECRET`: Your webhook secret for signature verification.

## Usage

### Create an Extraction

Submit a document for extraction.

```bash
php create_extraction.php <usecaseid> <documenttype> <filepath>
```

- `usecaseid`: The ID of the use case to use.
- `documenttype`: The type of document being uploaded.
- `filepath`: Path to the local file to extract.

### Get an Extraction

Retrieve the status and results of a specific extraction.

```bash
php get_extraction.php <jobId>
```

- `jobId`: The ID returned by the `create_extraction.php` script.

### Webhook Receiver

Start a local HTTP server to receive and log extraction results sent by webhooks.

```bash
php webhook_receiver.php [port]
```

- `port`: (Optional) Port to listen on (default: `5555` or `WEBHOOK_PORT` from `.env`).

This uses PHP's built-in web server. It will log incoming POST requests, including headers and JSON bodies, to your terminal, and verify the `X-Docloop-Signature` header.
