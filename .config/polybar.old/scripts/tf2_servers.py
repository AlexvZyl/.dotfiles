from time import sleep
import a2s
from tf2_za_server_list import servers

# Constants.
MIN_PLAYERS = 0
SUCCESS = False
TIMEOUT = 1
RETRIES = 5

# Get the number of players on the server.
def status(server):
    for _ in range(RETRIES):
        try:
            server = a2s.info((server[0], server[1]), timeout = TIMEOUT)
            global SUCCESS
            SUCCESS = True
            return server
        except (TimeoutError, OSError):
            sleep(0.1)
    return False

# Find optimal server.
max = 0
max_cap = 0
name = ""
for server in servers:
    s = status(server)
    if s and s.player_count > MIN_PLAYERS:
        max = s.player_count
        max_cap = s.max_players
        name = s.server_name

# Print status.
if SUCCESS:
    if max == 0 or max < MIN_PLAYERS:
        print("󰒎  Offline")
    else:
        print(f"󰒍  {name}: {max:02}/{max_cap:02}")
else:
    print("  Error")
