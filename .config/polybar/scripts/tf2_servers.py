import a2s
from tf2_za_server_list import servers

# Meta data.
min_players = 0
success = False
timeout = 2

# Get the number of players on the server.
def get_players(server):
    try:
        players = a2s.info((server[0], server[1]), timeout = timeout).player_count
        global success
        success = True
        return players
    except (TimeoutError, OSError):
        return False

# Get most populated server and print info.
max_players = max(get_players(server) for server in servers)
if success:
    print((f"{max_players:02}" if (max_players >= min_players) else "󰅛 "))
else:
    print(" ")
