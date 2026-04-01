# Docloop Public API v2 Python Examples

This directory contains Python script examples for interacting with the Docloop Public API v2.

## Prerequisites

- `python 3.x`
- `requests` library

```bash
pip install requests
```

## Setup

1. Copy the template environment file:
   ```bash
   cp .env-dist .env
   ```
2. Edit `.env` and provide your credentials:
   - `API_KEY`: Your Docloop API key.
   - `BASE_URL_API`: The base URL for the API (default: `https://app.docloop.io/public-api/v2`).
   - `WEBHOOK_URL`: Your webhook URL where extraction results will be sent.
   - `WEBHOOK_SECRET`: Your webhook secret key used to verify the signature.

## Usage

### Create an Extraction

Submit a document for extraction.

```bash
python create_extraction.py <usecaseid> <documenttype> <filepath>
```

- `usecaseid`: The ID of the use case to use.
- `documenttype`: The type of document being uploaded.
- `filepath`: Path to the local file to extract.

### Get an Extraction

Retrieve the status and results of a specific extraction.

```bash
python get_extraction.py <jobId>
```

- `jobId`: The ID returned by the `create_extraction.py` script.

### Receive Webhook & Verify Signature

This example starts a simple HTTP server that receives POST requests from Docloop and verifies the `x-docloop-signature` header using your `WEBHOOK_SECRET`. It listens on port `5555` by default (configurable via `WEBHOOK_PORT` in `.env`).

```bash
python webhook_receiver.py [port]
```

#### Verification Logic

The signature is an HMAC-SHA256 hash of the **raw request body** using your **Webhook Secret** as the key.

```python
import hmac
import hashlib

computed_signature = hmac.new(
    webhook_secret.encode('utf-8'),
    raw_body,
    hashlib.sha256
).hexdigest()

if hmac.compare_digest(signature, computed_signature):
    # Valid signature
    ...
```
