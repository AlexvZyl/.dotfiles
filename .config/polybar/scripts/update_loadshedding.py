# Imports.
import subprocess
import json
import os
"""
Get location:

```
command = [ "curl", "--location", "--request", "GET",
            'https://developer.sepush.co.za/business/2.0/areas_nearby?lat=-33.932106&lon=18.860151',
            "--header", f"token: {key}" ]
```
"""

key = os.environ.get("ESKOM_SE_PUSH_KEY")
region = "eskme-2-stellenboschstellenboschwesterncape"

command = ["curl", "--location", "--request", "GET",
           "https://developer.sepush.co.za/business/2.0/area?id="+region,
           "--header", f"token: {key}"]

try:
    response = subprocess.run(command, stdout=subprocess.PIPE, stderr = subprocess.DEVNULL).stdout.decode('utf-8')
    if 'error' in response: print("Error: " + response)
    elif 'timeout' in response: pass
    else:
        with open("/home/alex/.config/polybar/scripts/loadshedding.json", 'w') as file:
            json.dump(response, file)

# Could not connect.
except(json.JSONDecodeError) as e:
    print("Error: " + str(e))
