import json
import datetime
import pytz

with open("/home/alex/.config/polybar/scripts/loadshedding.json", "r") as file:
    response = json.loads(json.load(file))
    next = response["events"][0]
    start = datetime.datetime.fromisoformat(next["start"]).replace(tzinfo=pytz.timezone("Africa/Johannesburg"))
    end = datetime.datetime.fromisoformat(next["end"]).replace(tzinfo=pytz.timezone("Africa/Johannesburg"))
    now = datetime.datetime.now(pytz.timezone("Africa/Johannesburg"))
    if (now >= start) and (now <= end):
        time_left = end - now
        hours, remainder = divmod(int(time_left.total_seconds()), 3600)
        minutes, _ = divmod(remainder, 60)
        print(f"{hours:02d}:{minutes:02d}")
    else:
        duration = end - start
        print(start.strftime("%H:%M") + " [" + str(int(duration.total_seconds()/3600)) + "]")
