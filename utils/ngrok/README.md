# ngrok utility

This utility provides a simple way to run **ngrok** using Docker to expose your local webhook receiver to the internet.

## Prerequisites

- **Docker** installed and running.
- An **ngrok account** and an **authtoken**. You can get one for free at [ngrok.com](https://ngrok.com/).

## Setup

1. Copy the environment template:
   ```bash
   cp .env-dist .env
   ```
2. Edit `.env` and provide your ngrok authtoken:
   - `NGROK_AUTHTOKEN`: Your personal ngrok authtoken.
   - `WEBHOOK_PORT`: The local port where your webhook receiver is listening (default: `5555`).

## Usage

### Start ngrok

Starts ngrok in a detached Docker container and displays the public URL.

```bash
make start
```

### Check Status

Displays the current public Webhook URL and the local Dashboard URL.

```bash
make status
```

### Stop ngrok

Stops and removes the ngrok Docker container.

```bash
make stop
```
