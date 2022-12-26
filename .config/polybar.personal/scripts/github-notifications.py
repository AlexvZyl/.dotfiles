# Imports.
from os import devnull
import subprocess
import json

# Command string.
command = "gh"
arg0 = "api"
arg1 = "-H" 
arg2 = "Accept: application/vnd.github+json"
arg3 = "/notifications"

# Try to connect to GitHub server and get notiication count.
try:
    result = subprocess.run([command, arg0, arg1, arg2, arg3], stdout=subprocess.PIPE, stderr = subprocess.DEVNULL).stdout.decode('utf-8')
    json_object = json.loads(result)
    print(len(json_object))
# Could not connect.
except(json.JSONDecodeError):
    print(" ")
