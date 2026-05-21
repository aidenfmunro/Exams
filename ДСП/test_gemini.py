import json
import urllib.request
import os

creds_path = os.path.expanduser('~/.gemini/oauth_creds.json')
with open(creds_path, 'r') as f:
    creds = json.load(f)
token = creds['access_token']

url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent'
headers = {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}
data = {
    'contents': [{'parts': [{'text': 'Hello, are you there?'}]}]
}
req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers=headers)
try:
    with urllib.request.urlopen(req) as response:
        print(response.read().decode('utf-8'))
except Exception as e:
    print('Error:', e)
    if hasattr(e, 'read'):
        print(e.read().decode('utf-8'))
