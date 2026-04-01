# Docloop Public API Examples

This repository provides a collection of examples and tools for interacting with the Docloop Public API. It includes scripts for both API v1 and v2, using different tools like Bash, Python, PHP, and Hurl, along with utility tools for testing webhooks.

## Repository Structure

```text
├── resources/              # Sample documents for testing (PDFs)
├── utils/
│   └── ngrok/              # Utility for exposing local webhook receiver (Docker)
├── v1/
│   └── bash/               # API v1 Bash examples
└── v2/
    ├── bash/               # API v2 Bash examples
    ├── python/             # API v2 Python examples
    ├── php/                # API v2 PHP examples
    └── hurl/               # API v2 Hurl test examples
```

## Prerequisites

To use these examples, you will need:
- `bash` and `curl`
- `base64` (for document encoding)
- `jq` (optional, for parsing JSON responses)
- `python 3.x` (for Python examples)
- `php 8.x` (for PHP examples)
- `socat` (required for Bash webhook receiver)
- `openssl` (required for signature verification in Bash)
- [Hurl](https://hurl.dev/) (optional, for running Hurl tests)
- **Docker** (optional, for the ngrok utility)

## Getting Started

### API v2 (Recommended)

API v2 simplifies authentication by using your API Key directly as a Bearer token. You can manage your API keys at [https://app.docloop.io/admin/api_keys](https://app.docloop.io/admin/api_keys).

Navigate to the directory for your preferred language (e.g., `v2/bash/`, `v2/python/`, or `v2/php/`) and follow the instructions in the corresponding `README.md`.

Generally, you will:
1. Copy `.env-dist` to `.env`.
2. Fill in your `API_KEY` and other configuration.
3. Run the scripts according to the documentation.

### API v1 (Deprecated)

> [!WARNING]
> API v1 is deprecated and will be decommissioned soon. We strongly recommend migrating to API v2.

API v1 requires an explicit authentication step to exchange an API Key for an access token.

Navigate to `v1/bash/` and follow the instructions in the `README.md`.

## Webhook Testing

To test asynchronous extractions that send results to a webhook, you need a way to receive requests from the internet on your local machine.

1. **Start a receiver:** Choose one of the receivers in `v2/bash/`, `v2/python/`, or `v2/php/`.
   - For example, `v2/bash/webhook-receiver.sh` will start a server on port `5555`.
2. **Expose it to the internet:** Use the ngrok utility in `utils/ngrok/`.
   - Run `make start` in that directory to get a public URL.
3. **Configure your API call:** Use the public ngrok URL as your `WEBHOOK_URL` in your API requests.

## Sample Resources

The `resources/` directory contains example documents you can use for testing:
- `example_invoice.pdf`: A sample commercial invoice.
- `example_transport_order.pdf`: A sample road transport order.

## Documentation

For more detailed information, please refer to the README files in each subdirectory:
- [API v2 Bash Documentation](./v2/bash/README.md)
- [API v2 Python Documentation](./v2/python/README.md)
- [API v2 PHP Documentation](./v2/php/README.md)
- [API v2 Hurl Documentation](./v2/hurl/README.md)
- [ngrok Utility Documentation](./utils/ngrok/README.md)
