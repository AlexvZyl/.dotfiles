import a2s
from tf2_za_server_list import servers

min_players = 0

# Try to get most populated server.
try:
    # Get the number of players on the server with the highest player count.
    max_players = max(a2s.info((server[0], server[1])).player_count for server in servers)
   # Display the info.
    print((f"{max_players:02}" if (max_players >= min_players) else "󰅛 "))

# Could not connect.
except (TimeoutError, OSError):
    print(" ")
