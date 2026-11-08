import json
import os
import sys
import time
import subprocess
import urllib.request
import urllib.error

PROJECT_ID = "prm-projects"
DATABASE_ID = "(default)"
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/{DATABASE_ID}/documents"

def get_access_token():
    """Retrieves or refreshes Google OAuth access token from Firebase CLI config."""
    config_path = os.path.expanduser("~/.config/configstore/firebase-tools.json")
    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Firebase credentials not found at {config_path}. Please run 'firebase login' first.")

    with open(config_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    tokens = data.get("tokens", {})
    expires_at = tokens.get("expires_at", 0) / 1000.0
    access_token = tokens.get("access_token")

    # If token expires within 60 seconds or is missing, refresh via firebase CLI
    if not access_token or time.time() >= (expires_at - 60):
        print("[*] Access token expired or missing. Refreshing via 'firebase projects:list'...")
        subprocess.run(["firebase", "projects:list"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
        with open(config_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        tokens = data.get("tokens", {})
        access_token = tokens.get("access_token")

    return access_token

def to_firestore_value(val):
    """Converts a standard Python value to Firestore REST API typed format."""
    if val is None:
        return {"nullValue": None}
    elif isinstance(val, bool):
        return {"booleanValue": val}
    elif isinstance(val, int):
        return {"integerValue": str(val)}
    elif isinstance(val, float):
        return {"doubleValue": float(val)}
    elif isinstance(val, str):
        return {"stringValue": val}
    elif isinstance(val, list):
        return {"arrayValue": {"values": [to_firestore_value(x) for x in val]}}
    elif isinstance(val, dict):
        return {"mapValue": {"fields": {k: to_firestore_value(v) for k, v in val.items()}}}
    else:
        return {"stringValue": str(val)}

def get_doc_id(col_name, item):
    """Determines document ID based on collection conventions."""
    if "id" in item:
        return str(item["id"])
    if "apartmentId" in item:
        return str(item["apartmentId"])
    if "appointmentId" in item:
        return str(item["appointmentId"])
    raise ValueError(f"No document ID found in item for collection '{col_name}': {item}")

def upload_document(token, collection, doc_id, data):
    """Uploads/updates a single document to Firestore using REST API PATCH."""
    fields = {k: to_firestore_value(v) for k, v in data.items()}
    url = f"{BASE_URL}/{collection}/{doc_id}"
    payload = json.dumps({"fields": fields}).encode("utf-8")

    req = urllib.request.Request(
        url,
        data=payload,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        },
        method="PATCH"
    )

    try:
        with urllib.request.urlopen(req) as resp:
            return resp.status in (200, 201)
    except urllib.error.HTTPError as e:
        error_msg = e.read().decode("utf-8", errors="replace")
        print(f"    [!] Error uploading {collection}/{doc_id}: HTTP {e.code}: {error_msg}")
        return False

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    seed_file_path = os.path.join(project_root, "firestore.seed.json")

    if not os.path.exists(seed_file_path):
        print(f"Error: {seed_file_path} not found.")
        sys.exit(1)

    print(f"[*] Reading seed file: {seed_file_path}")
    with open(seed_file_path, "r", encoding="utf-8") as f:
        seed_data = json.load(f)

    print("[*] Authenticating with Firebase credentials...")
    token = get_access_token()
    print("[*] Authentication successful!")

    total_uploaded = 0
    total_failed = 0

    for collection_name, items in seed_data.items():
        if not isinstance(items, list):
            print(f"[*] Skipping non-list key: {collection_name}")
            continue

        print(f"\n[*] Seeding collection '{collection_name}' ({len(items)} documents)...")
        for item in items:
            doc_id = get_doc_id(collection_name, item)
            success = upload_document(token, collection_name, doc_id, item)
            if success:
                total_uploaded += 1
                print(f"  [+] Seeded: {collection_name}/{doc_id}")
            else:
                total_failed += 1

    print("\n" + "=" * 50)
    print(f"[*] Seeding Complete!")
    print(f"    - Successfully uploaded: {total_uploaded} documents")
    print(f"    - Failed: {total_failed} documents")
    print(f"[*] You can now check your Firebase Console:")
    print(f"    https://console.firebase.google.com/project/{PROJECT_ID}/firestore")
    print("=" * 50)

if __name__ == "__main__":
    main()
