import subprocess
import json

command = [ "gh", "api", "-H", "Accept: application/vnd.github+json", "/notifications" ]

try:
    # Get notification count.
    # result = subprocess.run(command, stdout=subprocess.PIPE, stderr = subprocess.DEVNULL).stdout.decode('utf-8')
    # json_object = json.loads(result)
    # count = len(json_object)
    # print(f"{count:01}")
    print("0")

except(json.JSONDecodeError):
    print("󰧠 ")
