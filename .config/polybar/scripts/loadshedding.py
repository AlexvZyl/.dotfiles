import json
import datetime
import pytz


def get_current_time():
    return datetime.datetime.now(pytz.timezone("Africa/Johannesburg"))


def no_loadshedding(events):
    return len(events) == 0


def find_next_event(events):
    now = get_current_time()
    index = 0
    next = events[index]
    start = datetime.datetime.fromisoformat(next["start"])
    end = datetime.datetime.fromisoformat(next["end"]) - datetime.timedelta(minutes=30)
    duration = end - start

    while ((start < now) and (now > end)) or (duration <= datetime.timedelta(minutes=30)):
        index += 1
        next = events[index]
        start = datetime.datetime.fromisoformat(next["start"])
        end = datetime.datetime.fromisoformat(next["end"]) - datetime.timedelta(minutes=30)
        duration = end - start

    # Loadshedding currently busy.
    if (now >= start) and (now <= end):
        time_left = end - now
        hours, remainder = divmod(int(time_left.total_seconds()), 3600)
        minutes, _ = divmod(remainder, 60)
        print("%{F#db4b4b} %{F#e0af68}󱎫 %{F-}" + f"{hours:02d}:{minutes:02d}" + " %{F#db4b4b}")

    # Display next loadshedding.
    else:
        duration = end - start
        print("%{F#e0af68}%{F-} " + start.strftime("%H:%M") + " %{F#e0af68}󱎫 %{F-}" + str(int(duration.total_seconds()/3600)) + "h")


def main():
    try:
        with open(
            "/home/alex/.config/polybar/scripts/loadshedding.json", "r"
        ) as file:
            # Load data.
            events = json.loads(json.load(file))["events"]

            if no_loadshedding(events):
                print("%{F#9ece6a}%{F-} None %{F#9ece6a}%{F-}")
                return

            find_next_event(events)

    except Exception:
        print("%{F#e0af68}%{F-} 󰧠 ")


if __name__ == "__main__":
    main()
