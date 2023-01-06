# Imports.
import subprocess
import json

command = [ "gh", "api", "-H", "Accept: application/vnd.github+json", "/notifications" ]

# Try to connect to GitHub server and get notification count.
try:
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr = subprocess.DEVNULL).stdout.decode('utf-8')
    json_object = json.loads(result)
    print(len(json_object))

# Could not connect.
except(json.JSONDecodeError):
    print(" ")
