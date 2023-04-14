import a2s
from tf2_za_server_list import servers

# Meta data.
min_players = 0
success = False
timeout = 2

# Get the number of players on the server.
def get_players(server):
    try:
        server = a2s.info((server[0], server[1]), timeout = timeout)
        global success
        success = True
        return server.player_count, server.max_players
    except (TimeoutError, OSError):
        return 0, 0

# Get most populated server and print info.
max = 0
max_cap = 0
for server in servers:
    players, cap = get_players(server)
    if players > max:
        max = players
        max_cap = cap

if success:
    print((f"{max:02}/{max_cap:02}" if (max >= min_players) else "󰅛 "))
else:
    print(" ")
