#!/bin/bash
# Helper script to suspend and set RTC wake time
# Usage: rtc-suspend.sh "wake_time_description"

if [ $# -ne 1 ]; then
    echo "Usage: $0 'wake_time_description'"
    echo "Example: $0 '15:00 today'"
    exit 1
fi

wake_time="$1"
wake_timestamp=$(date -d "$wake_time" +%s)

if [ $? -ne 0 ]; then
    echo "Error: Invalid time format '$wake_time'"
    exit 1
fi

echo "Setting RTC wake for: $(date -d @$wake_timestamp)"

# Set the RTC wake time first (before suspend)
sudo rtcwake -m mem -t $wake_timestamp

#    echo "RTC wake time set successfully"
    # Small delay then suspend
#    sleep 2
#    systemctl suspend
#else
#    echo "Error: Failed to set RTC wake time"
#    exit 1
#fi
