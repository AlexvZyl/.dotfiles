from time import sleep
import a2s

# Config.
MIN_PLAYERS = 0
TIMEOUT = 1
RETRIES = 5

SERVERS = [
    ["102.182.203.60", 27015],
    ["129.151.169.190", 27017],
    ["129.151.169.190", 27015],
]


# Get the number of players on the server.
def get_server_status(server):
    for _ in range(RETRIES):
        try:
            return a2s.info((server[0], server[1]), timeout=TIMEOUT)
        except (TimeoutError):
            sleep(0.1)
    return False


def Main():
    # Find optimal server.
    max = 0
    max_cap = 0
    for server in SERVERS:
        status = get_server_status(server)
        if status and status.player_count > MIN_PLAYERS:
            print(status.player_count)
            max = status.player_count
            max_cap = status.max_players

    # Print status.
    if max == 0 or max < MIN_PLAYERS:
        print("󰒎 ")
    else:
        print(f"󰒍 {max:02}/{max_cap:02}")


Main()
