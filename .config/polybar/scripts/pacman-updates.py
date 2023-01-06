# Imports.
import subprocess
from collections import Counter

# Sync.
command1 = ["sudo", "pacman", "-Syy"]
subprocess.run(command1, stdout=subprocess.PIPE, stderr = subprocess.DEVNULL).stdout.decode('utf-8')

# Get updates.
command2 = ["pacman", "-Qu"]
updates = subprocess.run(command2, stdout=subprocess.PIPE, stderr = subprocess.DEVNULL).stdout.decode('utf-8')

# Count packages.
count = Counter(updates)['\n']
print(count)
