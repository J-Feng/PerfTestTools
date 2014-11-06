#!/bin/bash

## Some util functions
calc_delta_ms()
{
    echo $1 $2 | awk '{printf("%.0f", $2-$1)}'
}

get_time_ms()
{
    echo `date --date=""$1"" +%s` `date --date=""$1"" +%N` | awk '{printf("%.0f", $1*(1000)+$2/(1000000))}'
}


## Use macros to record input vars
# TODO: this should be input parameters, or get from a config file
LOG_TAG=$1
LOG_FILE=$2
START_LOG=$3
END_LOG=$4
PACKAGE_NAME=$5
COMPONENT_NAME=$6


## Test and capture log
adb root
adb remount

adb logcat -c
adb logcat -v threadtime $LOG_TAG:V *:S > $LOG_FILE &
logcat_pid=$!

# TODO: test mode should be configured, reboot or just relaunch the app
cnt=$7
while [ $cnt -gt 0 ]
do
    adb shell am start -W -n $PACKAGE_NAME/$COMPONENT_NAME
    adb shell sleep 2
    adb shell kill `adb shell ps | grep $PACKAGE_NAME | awk '{print $2}'`
    adb shell sleep 2
    ((cnt-=1))
done

# Testing is over, kill logcat
sudo kill -9 $logcat_pid


## Data processing
IFSOLD=$IFS
IFS=$'\n'

# Get start time values in ms
idx=0
for r in `grep $LOG_TAG": "$START_LOG $LOG_FILE`
do
    tmp=`echo $r | awk '{print $2}'`
    start_time_ms[idx]=`get_time_ms $tmp`
    ((idx+=1))
done

# Get end time values in ms
idx=0
for r in `grep $LOG_TAG": "$END_LOG $LOG_FILE`
do
    tmp=`echo $r | awk '{print $2}'`
    end_time_ms[idx]=`get_time_ms $tmp`
    ((idx+=1))
done

IFS=$IFS.OLD

# Debug echo
## TODO: Format print
total=0
for ((i=idx-1; i>=0; i--))
do
    delta=`calc_delta_ms ${start_time_ms[i]} ${end_time_ms[i]}`
    ((total+=delta))
    echo "${end_time_ms[$i]}     ${start_time_ms[$i]}       $delta"
done

echo "Total    $total"
echo "Average  $((total/idx))"
