# Imports.
import subprocess
from collections import Counter

# Sync.
command1 = [ "yay", "-Syy" ]
subprocess.run(command1, stdout=subprocess.PIPE, stderr = subprocess.DEVNULL).stdout.decode('utf-8')

# Get updates.
command2 = [ "yay", "-Qu" ]
updates = subprocess.run(command2, stdout=subprocess.PIPE, stderr = subprocess.DEVNULL).stdout.decode('utf-8')

# Count packages.
count = Counter(updates)['\n']
if count < 10:
    print(f"00{count}")
elif count < 100:
    print(f"0{count}")
else:
    print(f"{count}")

