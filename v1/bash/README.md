# Docloop Public API v1 Bash Examples (Deprecated)

> [!WARNING]
> This API version is deprecated and will be decommissioned soon. Please use [API v2](../../v2/bash/README.md) for all new implementations.

This directory contains Bash script examples for interacting with the Docloop Public API v1.

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
   - `BASE_URL_API`: The base URL for the API (default: `https://app.docloop.io/public-api/v1`).

## Usage

### List Usecases

Retrieve a list of available use cases and their document types.

```bash
./list-usecases.sh
```

### Upload a Document

Submit a document for extraction.

```bash
./upload-document.sh <usecaseid> <documenttype> <filepath>
```

- `usecaseid`: The ID of the use case to use.
- `documenttype`: The type of document being uploaded.
- `filepath`: Path to the local file to extract.

Example:
```bash
./upload-document.sh 69319dbf7ddf4a4a93301e51 ROAD_TRANSPORT_ORDER ../../resources/example_transport_order.pdf
```

### Get an Extraction

Retrieve the status and results of a specific document extraction.

```bash
./get-extraction.sh <documentId>
```

- `documentId`: The ID returned by the `upload-document.sh` script.

Example:
```bash
./get-extraction.sh 69319dbf7ddf4a4a93301e51
```
