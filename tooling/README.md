# Simple Socat HTTP Server for Webhooks

This project contains a lightweight, minimalist Bash script that uses `socat` to spin up a basic HTTP server. It listens on a specific port and responds to any incoming request with a `200 OK` HTTP status and a static JSON payload.

It is highly useful for quick debugging, testing webhooks, or mocking an API endpoint without needing to install heavy dependencies like Node.js or Python.

## Features

- **Multi-threaded/Forking**: Handles multiple requests simultaneously using `socat`'s `fork` option.
- **Request Logging**: Prints the request line, headers, and body directly to your terminal.
- **JSON Pretty-Printing**: Automatically formats JSON request bodies if `jq` is installed.
- **Minimalist**: No complex setup required; just a single Bash script and `socat`.

## Prerequisites

To run this script, you need a Unix-like environment (Linux or macOS) with **socat** installed. 

* **Debian/Ubuntu:** `sudo apt install socat`
* **CentOS/RHEL:** `sudo yum install socat`
* **macOS:** `brew install socat`

Optional but recommended:
* **jq**: For pretty-printing JSON bodies (`sudo apt install jq` or `brew install jq`).

## Usage

### Using .env file

You can create a `.env` file (copying from `.env-dist`) to set the default port:

```bash
cp .env-dist .env
./webhook-listener.sh
```

### Command line

Start the server on the default port (5555):

```bash
./webhook-listener.sh
```

Or specify a custom port:

```bash
./webhook-listener.sh 8080
```

### Testing the Listener

You can test the listener using `curl` from another terminal:

```bash
curl -X POST http://localhost:5555/test \
     -H "Content-Type: application/json" \
     -d '{"foo": "bar", "hello": "world"}'
```

The listener will output the full request details to your terminal.
