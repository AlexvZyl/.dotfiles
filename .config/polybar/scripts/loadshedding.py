import json
import datetime
import pytz

try:
    with open("/home/alex/.config/polybar/scripts/loadshedding.json", "r") as file:
        # Setup.
        response = json.loads(json.load(file))
        now = datetime.datetime.now(pytz.timezone("Africa/Johannesburg"))
    
        # Look for next shedding.
        index = 0
        next = response["events"][index]
        start = datetime.datetime.fromisoformat(next["start"])
        end = datetime.datetime.fromisoformat(next["end"]) - datetime.timedelta(minutes=30)
        while (start < now) and (now > end):
            index+=1
            next = response["events"][index]
            start = datetime.datetime.fromisoformat(next["start"])
            end = datetime.datetime.fromisoformat(next["end"]) - datetime.timedelta(minutes=30)
    
        # Loadshedding currently busy.
        if (now >= start) and (now <= end):
            time_left = end - now
            hours, remainder = divmod(int(time_left.total_seconds()), 3600)
            minutes, _ = divmod(remainder, 60)
            print("%{F#BF616A}%{F-} " + f"{hours:02d}:{minutes:02d}")
        # Display next loadshedding.
        else:
            duration = end - start
            print("%{F#EBCB8B}%{F-} " + start.strftime("%H:%M") + " [" + str(int(duration.total_seconds()/3600)) + "]")

except:
    print("%{F#EBCB8B}%{F-}  ")
