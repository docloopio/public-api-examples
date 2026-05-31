import os
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
            if '=' in line and not line.startswith('#'):
                key, value = line.strip().split('=', 1)
                os.environ[key] = value

def get_usecase(usecase_id):
    """
    Retrieve a specific use case by its ID.
    """
    load_env()
    api_key = os.getenv("API_KEY")
    base_url = os.getenv("BASE_URL_API")

    # Validate environment variables
    if not api_key or not base_url:
        print("Error: API_KEY and BASE_URL_API must be defined.")
        sys.exit(1)

    # API v2 uses Bearer Token authentication
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }

    print(f"Retrieving use case {usecase_id}...")
    url = f"{base_url}/usecases/{usecase_id}"

    # Perform the GET request
    response = requests.get(url, headers=headers)

    print("\n--- Response ---")
    print(f"Status Code: {response.status_code}")
    try:
        print(json.dumps(response.json(), indent=2))
    except ValueError:
        print(response.text)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python get_usecase.py <usecaseId>")
        sys.exit(1)

    get_usecase(sys.argv[1])
