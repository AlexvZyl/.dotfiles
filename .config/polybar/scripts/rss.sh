#!/bin/bash

OUTPUT=$(newsboat -x reload print-unread)

if echo "$OUTPUT" | grep -q "Error"; then
    :
else
    echo "$OUTPUT" | grep -o '[0-9]*'
fi
