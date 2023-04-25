# Imports.
import subprocess
import json
import os

key = os.environ.get("ESKOM_SE_PUSH_KEY")
region = "westerncape-2-universityofstellenbosch"

command = [ "curl", "--location", "--request", "GET",  
            "https://developer.sepush.co.za/business/2.0/area?id="+region,
            "--header", f"token: {key}" ]

try:
    response = subprocess.run(command, stdout=subprocess.PIPE, stderr = subprocess.DEVNULL).stdout.decode('utf-8')
    if 'error' in response: 
        print("Error: " + response)
    else:
        with open("/home/alex/.config/polybar/scripts/loadshedding.json", 'w') as file:
            json.dump(response, file)

# Could not connect.
except(json.JSONDecodeError) as e:
    print("Error: " + str(e))
