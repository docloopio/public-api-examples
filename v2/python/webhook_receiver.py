import os
import hmac
import hashlib
import json
import sys
from http.server import HTTPServer, BaseHTTPRequestHandler

def load_env():
    """
    Load .env from the script's directory and export to os.environ.
    """
    script_dir = os.path.dirname(os.path.abspath(__file__))
    file_path = os.path.join(script_dir, ".env")
    
    if not os.path.exists(file_path):
        return
    with open(file_path, 'r') as f:
        for line in f:
            if '=' in line and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                os.environ[key] = value

class WebhookHandler(BaseHTTPRequestHandler):
    """
    Handler for incoming Webhook POST requests.
    """
    def do_POST(self):
        # 1. Load webhook secret from environment for verification
        webhook_secret = os.getenv("WEBHOOK_SECRET")
        if not webhook_secret:
            print("Error: WEBHOOK_SECRET not set in environment.")
            self.send_response(500)
            self.end_headers()
            return

        # 2. Get signature from headers
        signature = self.headers.get('x-docloop-signature')
        if not signature:
            print("Error: x-docloop-signature header missing.")
            self.send_response(401)
            self.end_headers()
            return

        # Strip sha256= prefix if present (Docloop prefix)
        if signature.startswith("sha256="):
            signature = signature[7:]

        # 3. Read raw request body for signature calculation
        content_length = int(self.headers.get('Content-Length', 0))
        raw_body = self.rfile.read(content_length)

        # 4. Compute HMAC SHA-256 hash using the raw body and webhook secret
        computed_signature = hmac.new(
            webhook_secret.encode('utf-8'),
            raw_body,
            hashlib.sha256
        ).hexdigest()

        # 5. Compare signatures (using constant-time comparison to prevent timing attacks)
        if hmac.compare_digest(signature, computed_signature):
            print("\n✅ Signature verified!")
            
            # Parse and display the JSON payload
            payload = json.loads(raw_body.decode('utf-8'))
            print("Payload received:")
            print(json.dumps(payload, indent=2))
            
            # Respond with 200 OK
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"Verified")
        else:
            print("\n❌ Invalid signature!")
            self.send_response(401)
            self.end_headers()
            self.wfile.write(b"Invalid Signature")

def run(port=None):
    """
    Starts the local HTTP server.
    """
    load_env()
    
    # Priority: Command line arg > Env var > Default 5555
    if port is None:
        port = int(os.getenv("WEBHOOK_PORT", 5555))
    
    server_address = ('', port)
    httpd = HTTPServer(server_address, WebhookHandler)
    
    print(f"Starting webhook receiver on port {port}...")
    print("Use a tool like ngrok to expose this port to the internet.")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping server...")
        httpd.server_close()

if __name__ == "__main__":
    # Allow port to be passed as a command line argument
    port = None
    if len(sys.argv) > 1:
        port = int(sys.argv[1])
    run(port)
