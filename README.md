# Docloop Public API Examples

This repository provides a collection of examples and tools for interacting with the Docloop Public API. It includes scripts for both API v1 and v2, using different tools like Bash and Hurl, along with a utility for testing webhooks.

## Repository Structure

```text
├── resources/              # Sample documents for testing (PDFs)
├── tooling/                # Utility scripts (e.g., webhook listener)
├── v1/
│   └── bash/               # API v1 Bash examples
└── v2/
    ├── bash/               # API v2 Bash examples
    └── hurl/               # API v2 Hurl test examples
```

## Prerequisites

To use these examples, you will need:
- `bash` and `curl`
- `base64` (for document encoding)
- `jq` (optional, but highly recommended for parsing JSON responses)
- `socat` (optional, for the webhook listener tool)
- [Hurl](https://hurl.dev/) (optional, for running Hurl tests)

## Getting Started

### API v2 (Recommended)

API v2 simplifies authentication by using your API Key directly as a Bearer token.

#### Bash Examples
1. Navigate to `v2/bash/`.
2. Copy `.env-dist` to `.env` and fill in your `API_KEY`.
3. Run an extraction:
   ```bash
   ./create-extraction.sh <usecaseid> <documenttype> <filepath>
   ```

#### Hurl Examples
1. Navigate to `v2/hurl/`.
2. Copy `.env-dist` to `.env` and fill in your `API_KEY`.
3. Run the extraction test:
   ```bash
   ./run-extraction.sh <usecaseid> <documenttype> <filepath>
   ```

### API v1

API v1 requires an explicit authentication step to exchange an API Key for an access token.

1. Navigate to `v1/bash/`.
2. Edit `api-v1-example.sh` and replace `YOUR_API_KEY` with your actual key.
3. Run the script:
   ```bash
   ./api-v1-example.sh
   ```

## Webhook Testing

If you need to test asynchronous extractions that send results to a webhook, you can use the provided listener:

1. Navigate to `tooling/`.
2. Start the listener:
   ```bash
   ./webhook-listener.sh 5555
   ```
3. Use the public URL of this listener (e.g., via ngrok or a direct IP) as your `WEBHOOK_URL` in your API requests.

## Sample Resources

The `resources/` directory contains example documents you can use for testing:
- `example_invoice.pdf`: A sample commercial invoice.
- `example_transport_order.pdf`: A sample road transport order.

## Documentation

For more detailed information, please refer to the README files in each subdirectory:
- [Tooling Documentation](./tooling/README.md)
- [API v2 Bash Documentation](./v2/bash/README.md)
- [API v2 Hurl Documentation](./v2/hurl/README.md)
