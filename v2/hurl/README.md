# Hurl V2 Examples

This directory contains [Hurl](https://hurl.dev/) tests for the V2 API.

## Prerequisites

- [Hurl](https://hurl.dev/docs/installation.html) installed.
- Access to the API and a valid API key.

## Setup

1. Copy `.env-dist` to `.env`:
   ```bash
   cp .env-dist .env
   ```
2. Update `.env` with your actual credentials and configuration:
   - `BASE_URL_API`: The base URL of the API.
   - `API_KEY`: Your API key.
   - `WEBHOOK_URL`: The URL where the API will send the extraction results.

## Running the tests

You can run the extraction test using the helper shell script:

```bash
./run-extraction-test.sh <usecaseid> <documenttype> <filepath>
```

Example:
```bash
./run-extraction-test.sh my-usecase-id invoice ../../resources/example_invoice.pdf
```
