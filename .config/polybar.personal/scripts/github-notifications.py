# Imports.
import subprocess
import json

# Command string.
command = "gh"
arg0 = "api"
arg1 = "-H" 
arg2 = "Accept: application/vnd.github+json"
arg3 = "/notifications"

# Run command.
result = subprocess.run([command, arg0, arg1, arg2, arg3], stdout=subprocess.PIPE).stdout.decode('utf-8')
json_object = json.loads(result)
print(len(json_object))
