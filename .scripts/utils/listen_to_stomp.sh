#!/usr/bin/env -S bash -e


Main() {
    local card_full
    card_full=$(pactl list cards short | grep "Stomp" | awk '{print $2}')
    local card
    card=${card_full//alsa_card./}
    local source
    source=$(pactl list sources short | grep "$card" | grep "input" | awk '{print $2}')

    
    pactl set-card-profile "$card_full" "pro-audio"
    pactl load-module module-loopback \
        source="$source" \
        latency_msec=0 
}



Main "$@"
