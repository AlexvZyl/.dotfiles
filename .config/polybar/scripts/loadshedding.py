import json
import datetime
import pytz

with open("/home/alex/.config/polybar/scripts/loadshedding.json", "r") as file:
    # Setup.
    response = json.loads(json.load(file))
    now = datetime.datetime.now(pytz.timezone("Africa/Johannesburg"))

    # Look for next shedding.
    index = 0
    next = response["events"][index]
    start = datetime.datetime.fromisoformat(next["start"])
    while start < now:
        index+=1
        next = response["events"][index]
        start = datetime.datetime.fromisoformat(next["start"])
    end = datetime.datetime.fromisoformat(next["end"])
    end = end - datetime.timedelta(minutes=30)

    # Display information, dpenedant on if currently loadshedding.
    if (now >= start) and (now <= end):
        time_left = end - now
        hours, remainder = divmod(int(time_left.total_seconds()), 3600)
        minutes, _ = divmod(remainder, 60)
        print(f"{hours:02d}:{minutes:02d}")
    else:
        duration = end - start
        print(start.strftime("%H:%M") + " [" + str(int(duration.total_seconds()/3600)) + "]")
