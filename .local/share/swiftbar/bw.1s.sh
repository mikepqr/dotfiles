#!/usr/bin/env bash

# Hardcode possible path because intel homebrew is not on default macOS PATH
if [ -e /opt/homebrew/bin/ifstat ]; then
    ifstat=/opt/homebrew/bin/ifstat
else
    ifstat=ifstat
fi

# Final two numbers are total down and up in kilobits per second
# -b = bits not byes
# -T = show total
# 0.1 = minimal delay
# 1 = run once
ifstat_out=$($ifstat -b -T 0.1 1 | tail -n 1)

mbps_down=$(
    echo "$ifstat_out" | awk '{$(NF-1)/=1024;printf "%.2f",$(NF-1)}'
)
mbps_up=$(
    echo "$ifstat_out" | awk '{$(NF)/=1024;printf "%.2f",$(NF)}'
)

echo "$mbps_down ↓ $mbps_up ↑|font='FiraCode Nerd Font'"
