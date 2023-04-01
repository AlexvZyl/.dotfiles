import a2s

servers = [
    ["156.38.224.119",  29010],
    ["129.151.163.124", 27015]
]

current_players = 0
max_players = 0

try:
    for server in servers:
        info = a2s.info((server[0], server[1]))
        player_count = info.player_count
        if player_count > current_players:
            current_players = player_count
            max_players = info.max_players
    
    if max_players != 0:
        print(f"{current_players}/{max_players}")
    else:
        print("")

# Could not connect.
except:
    print(" ")
