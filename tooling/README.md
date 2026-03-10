# Simple Netcat JSON Server

This project contains a lightweight, minimalist Bash script that uses `nc` (netcat) to spin up a basic HTTP server. It listens on a specific port and responds to any incoming request with a `200 OK` HTTP status and a static JSON payload.

It is highly useful for quick debugging, testing webhooks, or mocking an API endpoint without needing to install heavy dependencies like Node.js or Python.

## Prerequisites

To run this script, you need a Unix-like environment (Linux or macOS) with **netcat** installed. 
Depending on your Linux distribution, you might need to install it:

* **Debian/Ubuntu:** `sudo apt install netcat-openbsd`
* **CentOS/RHEL:** `sudo yum install nc`

## Usage

```bash
./webhook-listener.sh
```