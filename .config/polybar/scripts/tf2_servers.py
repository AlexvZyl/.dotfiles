import a2s
from tf2_za_server_list import servers

# Meta data.
min_players = 0
success = False
timeout = 2

# Get the number of players on the server.
def get_server(server):
    try:
        server = a2s.info((server[0], server[1]), timeout = timeout)
        global success
        success = True
        return server
    except (TimeoutError, OSError):
        return False

# Get most populated server and print info.
max = 0
max_cap = 0
name = ""
for server in servers:
    s = get_server(server)
    if s and s.player_count > min_players:
        max = s.player_count
        max_cap = s.max_players
        name = s.server_name

if success:
    if max == 0 or max < min_players:
        print("󰒎  Offline")
    else:
        print(f"󰒍  {name}: {max:02}/{max_cap:02}")
else:
    print("  Error")
