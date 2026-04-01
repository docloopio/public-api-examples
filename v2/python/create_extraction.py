import os
import base64
import json
import sys
import requests

def load_env(file_path=".env"):
    """
    Simple .env file loader that exports key=value pairs to os.environ.
    """
    if not os.path.exists(file_path):
        return
    with open(file_path, 'r') as f:
        for line in f:
            # Ignore comments and empty lines
            if '=' in line and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                os.environ[key] = value

def create_extraction(usecase_id, document_type, file_path):
    """
    Submit a document to the Docloop API for extraction.
    """
    load_env()
    api_key = os.getenv("API_KEY")
    base_url = os.getenv("BASE_URL_API")
    webhook_url = os.getenv("WEBHOOK_URL")

    # Validate environment variables
    if not api_key or not base_url or not webhook_url:
        print("Error: API_KEY, BASE_URL_API, and WEBHOOK_URL must be defined.")
        sys.exit(1)

    # Validate file existence
    if not os.path.exists(file_path):
        print(f"Error: File {file_path} not found.")
        sys.exit(1)

    # Prepare file data: API v2 expects base64 encoded string
    filename = os.path.basename(file_path)
    with open(file_path, "rb") as f:
        file_data = base64.b64encode(f.read()).decode("utf-8")

    # Build the JSON payload
    payload = {
        "usecaseId": usecase_id,
        "documentType": document_type,
        "filename": filename,
        "fileData": file_data,
        "webhookUrl": webhook_url
    }

    # API v2 uses Bearer Token authentication
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }

    print(f"Create extraction for {filename}...")
    url = f"{base_url}/extractions"
    
    # Perform the POST request
    response = requests.post(url, headers=headers, json=payload)

    # Output response details
    print("\n--- Response ---")
    print(f"Status Code: {response.status_code}")
    try:
        print(json.dumps(response.json(), indent=2))
    except ValueError:
        # Fallback if response is not JSON
        print(response.text)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python create_extraction.py <usecaseid> <documenttype> <filepath>")
        sys.exit(1)
    
    create_extraction(sys.argv[1], sys.argv[2], sys.argv[3])
